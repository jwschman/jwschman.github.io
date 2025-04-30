+++
title = "Installing Paperless-NGX on Kubernetes with automated document ingestion from Nextcloud"
description = "Installing Paperless-NGX on my Kubernetes cluster"
date = "2025-04-29"

[taxonomies] 
tags = ["kubernetes", "homelab", "paperless-ngx", "guides", "nextcloud"]

[extra]
cover_image="paperless-cover-image.png"
+++

> **TL;DR**: This post walks through deploying Paperless-NGX on Kubernetes with a PostgreSQL + Redis backend and automatic document consumption from a Nextcloud folder using a CronJob + rclone.

## Background

I did my American taxes this week.  Even though I live in Japan, and all my income is in yen, I still get to have the joy of dealing with American taxes.  Doing them isn't too much of a hassle, and this time it gave me the idea that I should finally get Paperless-NGX installed to keep track of the many documents that I have scattered here and there.

Recently I've seen several videos on YouTube of people setting Paperless-NGX up in Docker, which means it should be pretty easy to convert to a Kubernetes deployment.  And since I also run Nextcloud I thought it would be a neat integration to be able to automatically consume documents from a Nextcloud folder directly.  That part wound up being a little trickier than anticipated, but I think I figured out a nice way to handle it.

## Deployments

My deployment of Paperless-NGX runs three pods in the paperless namespace: The actual Paperless-NGX app, a database, and redis.  Since I've been working with PostgreSQL a lot lately I decided to go with that for the database this time, but there are [examples on the Paperless-NGX github with other database backends](https://github.com/paperless-ngx/paperless-ngx/tree/main/docker/compose).  Actually I based my kubernetes deployments on [this docker compose file](https://github.com/paperless-ngx/paperless-ngx/blob/main/docker/compose/docker-compose.postgres.yml) that includes Postgres.

Here's a list of the environment variables I used in the deployments.  Variables marked with a 🔐 emoji are stored in a secret pulled from Hashicorp Vault.

### Paperless Environment Variables

| Name | Description |
|-|-|
| 🔐 `PAPERLESS_ADMIN_USER` | Admin username |
| 🔐 `PAPERLESS_ADMIN_PASSWORD` | Admin password |
| `PAPERLESS_URL` | FQDN of the Paperless instance |
| `PAPERLESS_CSRF_TRUSTED_ORIGINS` | CSRF origin check bypass for the UI |
| `PAPERLESS_DBHOST` | Paperless database host |
| `PAPERLESS_DBNAME` | Paperless database name in Postgres |
| `PAPERLESS_DBUSER` | Paperless database user in Postgres |
| 🔐 `PAPERLESS_DBPASS` | Password for Paperless DB in Postgres |
| `PAPERLESS_REDIS` | Redis host |

###  PostgreSQL Environment Variables

| Name | Description |
|-|-|
| `POSTGRES_DB` | Paperless database name in Postgres |
| `POSTGRES_USER`| Paperless database user in Postgres |
| 🔐  `POSTGRES_PASSWORD` | Password for Paperless DB in Postgres |
| `PGDATA` | Directory to use for postgres data |

And here are the Deployments used in the cluster.

### Paperless Deployment

```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: paperless-ngx
  namespace: paperless
spec:
  replicas: 1
  selector:
    matchLabels:
      app: paperless-ngx
  template:
    metadata:
      labels:
        app: paperless-ngx
    spec:
      initContainers:
      - name: wait-for-db
        image: busybox:1.37
        command: ['sh', '-c', 'until nc -z db 5432; do echo "Waiting for Postgres..."; sleep 5; done']
        imagePullPolicy: IfNotPresent
      containers:
      - name: paperless-ngx
        image: ghcr.io/paperless-ngx/paperless-ngx:latest
        imagePullPolicy: IfNotPresent
        env:
        - name: PAPERLESS_REDIS
          value: redis://redis:6379
        - name: PAPERLESS_DBHOST
          value: db
        - name: PAPERLESS_DBNAME
          value: paperless
        - name: PAPERLESS_DBUSER
          value: paperless
        - name: PAPERLESS_URL
          value: https://paperless.pawked.com
        - name: PAPERLESS_CSRF_TRUSTED_ORIGINS
          value: https://paperless.pawked.com
        - name: PAPERLESS_DBPASS
          valueFrom:
            secretKeyRef:
              name: paperless-ngx-secrets
              key: POSTGRES_PASSWORD
        - name: PAPERLESS_ADMIN_USER
          valueFrom:
            secretKeyRef:
              name: paperless-ngx-secrets
              key: PAPERLESS_ADMIN_USER
        - name: PAPERLESS_ADMIN_PASSWORD
          valueFrom:
            secretKeyRef:
              name: paperless-ngx-secrets
              key: PAPERLESS_ADMIN_PASSWORD
        ports:
        - containerPort: 8000
        volumeMounts:
        - name: media
          mountPath: /usr/src/paperless/media
        - name: consume
          mountPath: /usr/src/paperless/consume
        readinessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 10
          periodSeconds: 5
          failureThreshold: 3
          successThreshold: 1
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "500m"
      volumes:
      - name: media
        persistentVolumeClaim:
          claimName: paperless-ngx-media
      - name: consume
        persistentVolumeClaim:
          claimName: paperless-ngx-consume
```

### PostgreSQL Deployment

```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: db
  namespace: paperless
spec:
  replicas: 1
  selector:
    matchLabels:
      app: db
  template:
    metadata:
      labels:
        app: db
    spec:
      containers:
      - name: db
        image: postgres:14
        env:
        - name: POSTGRES_DB
          value: paperless
        - name: POSTGRES_USER
          value: paperless
        - name: PGDATA
          value: /var/lib/postgresql/data/pgdata
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: paperless-ngx-secrets
              key: POSTGRES_PASSWORD
        ports:
        - containerPort: 5432
        volumeMounts:
        - name: postgres-data
          mountPath: /var/lib/postgresql/data
        readinessProbe:
          exec:
            command:
              - sh
              - -c
              - pg_isready -U postgres
          initialDelaySeconds: 5
          periodSeconds: 10
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "500m"
      volumes:
      - name: postgres-data
        persistentVolumeClaim:
          claimName: paperless-ngx-postgres
```

### Redis Deployment

```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis
  namespace: paperless
spec:
  replicas: 1
  selector:
    matchLabels:
      app: redis
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
      - name: redis
        image: redis:7
        ports:
        - containerPort: 6379
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "512Mi"
            cpu: "250m"
```

## Networks

Networking is all pretty standard.  The only thing that would really need changing in a different setup is the ingress.

### `network.yaml`

```yaml
---
# paperles-ngx service
apiVersion: v1
kind: Service
metadata:
  name: paperless-ngx
  namespace: paperless
spec:
  ports:
  - port: 8000
    targetPort: 8000
  selector:
    app: paperless-ngx
---
# paperless-ngx ingress
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: paperless-ngx
  namespace: paperless
spec:
  ingressClassName: internal
  tls:
  - hosts:
    - paperless.pawked.com
  rules:
  - host: paperless.pawked.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: paperless-ngx
            port:
              number: 8000
---
# redis service
apiVersion: v1
kind: Service
metadata:
  name: redis
  namespace: paperless
spec:
  ports:
  - port: 6379
  selector:
    app: redis
---
# postgres service
apiVersion: v1
kind: Service
metadata:
  name: db
  namespace: paperless
spec:
  ports:
  - port: 5432
  selector:
    app: db
```

## Persistent Storage

All of my storage for Paperless-NGX is handled by [Longhorn](https://github.com/longhorn/longhorn) PVCs.  I do things a little bit strange and declare the longhorn volumes directly.  This helps me keep things GitOps friendly which is one of the primary goals of my homelab.

To create volumes, PVs and PVCs I copied my `longhorn-storage.yaml` boilerplate and edited it to set up storage for the PostgreSQL database and paperless-ngx media and consume directories.  These volumes are backed up nightly by Longhorn to my TrueNAS server.

### `postgres-storage.yaml`

```yaml
---
apiVersion: longhorn.io/v1beta2
kind: Volume
metadata:
  labels:
    longhornvolume: paperless-ngx-postgres
  name: paperless-ngx-postgres
  namespace: longhorn-system
spec:
  numberOfReplicas: 2
  disableFrontend: false
  engineImage: longhornio/longhorn-engine:v1.8.1
  frontend: blockdev
  size: "3221225472"
  staleReplicaTimeout: 30
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: paperless-ngx-postgres
spec:
  capacity:
    storage: 3Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: longhorn
  csi:
    driver: driver.longhorn.io
    fsType: ext4
    volumeAttributes:
      numberOfReplicas: '2'
      staleReplicaTimeout: '30'
    volumeHandle: paperless-ngx-postgres
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: paperless-ngx-postgres
  namespace: paperless
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 3Gi
  volumeName: paperless-ngx-postgres
  storageClassName: longhorn
```

`media-storage.yaml` and `consume-storage.yaml` are exactly the same with different names and sizes.

Because these are Longhorn volumes they aren't technically empty directories which Postgres doesn't really like.  But this can be fixed by setting the `PGDATA` environment variable to a subpath in the mount.

## Secrets

I use [Hashicorp Vault](https://github.com/hashicorp/vault) for secret management and pull them in to Kubernetes with [External Secrets Operator](https://github.com/external-secrets/external-secrets).  The secrets I'm pulling from Vault are set as the environmet variables in the Paperless-NGX and Postgres pods as mentioned above.

## Integrating Nextcloud with Paperless-NGX Consume

I spent more time than I'd like to admit figuring out a good way to do this.  First I thought that I'd just run a rclone sidecar container with Paperless-NGX and have them share a volume, but becauese `rclone mount` uses FUSE for its filesystem, I wasn't able to easily get the files from one container to the other.

So I decided to do a Kubernetes CronJob that would execute an rclone move from the specified Nextcloud folder into a PVC mounted inside the Paperless-NGX pod.  I'm pretty sure using an emptyDir here would be fine, but the PVC gives me a little more comfort that no data will be lost in case something goes wrong.

The CronJob also pulls environemt variables from Vault.  Specifically, `RCLONE_CONFIG_NEXTCLOUD_URL`, `RCLONE_CONFIG_NEXTCLOUD_USER`, and `RCLONE_CONFIG_NEXTCLOUD_PASS`.  The `RCLONE_CONFIG_NEXTCLOUD_PASS` needs to be rclone encrypted before being saved as a secret in Vault, so on my Docker host I just ran `docker run --rm -it rclone/rclone obscure '<NEXTCLOUD-PASSWORD>'` and pasted the output into Vault.

Finally, because my PVCs are RWO I needed to run the job on the same node as Paperless-NGX which was solved with a simple PodAffinity.

### `cronjob.yaml`

```yaml
---
---
apiVersion: batch/v1
kind: CronJob
metadata:
  name: paperless-rclone-move
  namespace: paperless
spec:
  schedule: "*/5 * * * *" # every 5 minutes
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: Never
          affinity:
            podAffinity:
              requiredDuringSchedulingIgnoredDuringExecution:
                - labelSelector:
                    matchLabels:
                      app: paperless-ngx
                  topologyKey: kubernetes.io/hostname 
          containers:
            - name: rclone-move
              image: rclone/rclone:1.69.1
              imagePullPolicy: IfNotPresent
              args:
                - move
                - nextcloud:/Paperless/
                - /consume/
                - --transfers=1
                - --checkers=1
                - --no-traverse
                - --retries=3
                - --log-level=INFO
              env:
                - name: RCLONE_CONFIG_NEXTCLOUD_TYPE
                  value: webdav
                - name: RCLONE_CONFIG_NEXTCLOUD_URL
                  valueFrom:
                    secretKeyRef:
                      name: paperless-rclone-secrets
                      key: NEXTCLOUD_URL
                - name: RCLONE_CONFIG_NEXTCLOUD_VENDOR
                  value: nextcloud
                - name: RCLONE_CONFIG_NEXTCLOUD_USER
                  valueFrom:
                    secretKeyRef:
                      name: paperless-rclone-secrets
                      key: NEXTCLOUD_USER
                - name: RCLONE_CONFIG_NEXTCLOUD_PASS
                  valueFrom:
                    secretKeyRef:
                      name: paperless-rclone-secrets
                      key: NEXTCLOUD_PASS
              volumeMounts:
                - name: consume
                  mountPath: /consume
          volumes:
            - name: consume
              persistentVolumeClaim:
                claimName: paperless-ngx-consume

```

And with that Paperless-NGX is able to grab scanned documents from a folder in my Nextcloud called Paperless directly into Paperless-NGX.  I currently use an app called ClearScanner to take photos of documents which are auto-synced into the Paperless folder for consumption.  I'm not super happy with ClearScanner and am open to switching to a different app if I find one that works better.

## Conclusion

I'm feeling pretty good about things came together here with the Nextcloud integration and automatically ingesting documents from my phone couldn't be easier.  Also, everything else ties together nicely using GitOps, Vault, and Longhorn which keeps things clean and manageable.  I've already started moving a lot of my documents to Paperless and being able to just snap a shot with my phone removes a lot of friction that would make me not feel like doing it.

As I mentioned, I'm not in love with the ClearScanner app and would gladly switch to a different scanner app if I found one.

I'm also open to any comments or feedback about how I approached this.  If you know a better or simpler way of handling any part of it please feel free to let me know your thoughts.

## Links and Resources

- [Paperless-NGX Homepage](https://docs.paperless-ngx.com/)
- [Paperless-NGX Docker-Compose Examples](https://github.com/paperless-ngx/paperless-ngx/tree/main/docker/compose)
- [Kubernetes CronJob Documentation](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/)
- [Kubernetes Pod Affinity Documentation](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity)
- [Clear Scan on Google Play](https://play.google.com/store/apps/details?id=com.indymobileapp.document.scanner&hl=en&pli=1)