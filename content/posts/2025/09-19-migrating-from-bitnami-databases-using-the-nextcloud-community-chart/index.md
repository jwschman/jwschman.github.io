+++
title = "Migrating from Bitnami to Official PostgreSQL Images with the Nextcloud Community Chart"
description = "A step-by-step guide to migrating from Bitnami PostgreSQL images to official PostgreSQL when using the Nextcloud Community Helm Chart."
date = "2025-09-19"

[taxonomies] 
tags = ["nextcloud", "bitnami", "postgres", "homelab"]

[extra]
cover_image=""
+++

Bitnami Helm Charts have moved to a subscription model that is significantly out of my budget so I had to do some cleanup in my Homelab cluster to get rid of any Bitnami images that I was using.

Fortunately it wasn't many.  I was using the Bitnami chart for my centralized Redis instance, but that was easy enough to swap out with the official image.  But the Nextcloud Community Chart uses Bitnami images for databases, so I needed to move away from those.

First I disabled the Bitnami Redis instance included in the Nextcloud helm chart and pointed it towards my new Redis server in the `values.yaml`.

```yaml
redis:
  enabled: false
externalRedis:
  enabled: true
  ## Redis host
  host: "redis-svc.redis.svc.cluster.local"
  ## Redis port
  port: "6379"
  ## Use an existing secret
  existingSecret:
    enabled: true
    secretName: nextcloud-redis-secrets
    passwordKey: password
```

The second database was Postgres, which was going to be a little bit of work.  So let's see how I did it...

## Prerequisites

- Ability to execute into pods with `kubectl`
- Nextcloud and Postgres instances running in the `nextcloud` namespace (you can modify commands to match your namespace if it's different)
- A backup of all Nextcloud data before starting would also be a good idea

## Step 1: Get the new instance of Postgres up and running

Setting up a Postgres instance in Kubernetes is quite easy.  The only caveat here was that I had to prepare it for the Nextcloud migration, but that was simply setting a couple environment variables in the manifest.  Here's how it looks:

```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nextcloud-postgresql
spec:
  selector:
    matchLabels:
      app: nextcloud-postgresql
  replicas: 1
  template:
    metadata:
      labels:
        app: nextcloud-postgresql
    spec:
      containers:
      - name: postgres
        image: postgres:17 # Use whatever version tag you want
        ports:
        - containerPort: 5432
          name: tcp-postgres
        
        env:
        - name: POSTGRES_DB # nextcloud database name
          value: nextcloud
        - name: POSTGRES_USER # nextcloud username
          valueFrom:
            secretKeyRef:
              name: nextcloud-db-secret
              key: username
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: nextcloud-db-secret
              key: password
        
        - name: PGDATA # postgres data directory
          value: /var/lib/postgresql/data/pgdata
        
        volumeMounts:
        - name: nextcloud-postgres-data
          mountPath: /var/lib/postgresql/data

      volumes:
        - name: nextcloud-postgres-data
          persistentVolumeClaim:
            claimName: nextcloud-postgres-data
---
apiVersion: v1
kind: Service
metadata:
  name: nextcloud-postgresql-svc
  labels:
    app: nextcloud-postgresql
spec:
  ports:
  - port: 5432
    name: tcp-postgres
  selector:
    app: nextcloud-postgresql
```

You can see that I'm setting `POSTGRES_USER` and `POSTGRES_PASSWORD` from a secret that I already had created inside the nextcloud namespace, and just setting `POSTGRES_DB` to nextcloud.

The persistent data is also using a PVC named `nextcloud-postgres-data` created previously inside the nextcloud namespace.

{% admonition(type="tip", title="tip") %}
If you don't have a secret already you can easily create one with this:

```bash
kubectl -n nextcloud create secret generic nextcloud-db-secret \
  --from-literal=username=nextcloud \
  --from-literal=password=my-totally-secure-password
```
{% end %}

And the service is just type ClusterIP named nextcloud-postgresql-svc

{% admonition(type="warning", title="warning") %}
I'm only running a single instance of Postgres and don't need high-availability or scalability so I went with a Deployment.  This is not recommended for a robust scalable production environment where you should use a StatefulSet with volumeClaimTemplates.
{% end %}

Once that was up and running it was time for the next step.

## Step 2: Migrate the Postgres data

### Put Nextcloud in maintenance mode

```bash
kubectl -n nextcloud exec -it <nextcloud-pod> -- php occ maintenance:mode --on
```

### Dump the Postgres nextcloud database to local machine

```bash
kubectl -n nextcloud exec -it <bitnami-postgres-pod> -- pg_dump -U <nextcloud-username> -d <nextcloud-database-name> > nextcloud.sql
```

### Copy the local `nextcloud.sql` to the postgres pod

```bash
kubectl -n nextcloud cp ./nextcloud.sql <new-postgres-pod>:/tmp/nextcloud.sql
```

### Restore the database in the new Postgres pod

```bash
kubectl -n nextcloud exec -it <new-postgres-pod> -- psql -U <nextcloud-username> -d <nextcloud-database-name> -f /tmp/nextcloud.sql
```

## Step 3: Point Nextcloud to the new Postgres database

I just edited the `values.yaml` to disable the Bitnami Postgres and use `externalDatabase` and pointed the details to my new Postgres service and secret

```yaml
postgresql:
  enabled: false

externalDatabase:
  enabled: true
  type: postgresql
  host: nextcloud-postgresql-svc  # New instance's service name
  database: nextcloud
  existingSecret:
    enabled: true
    secretName: nextcloud-db-secret
    usernameKey: username
    passwordKey: password
```

After that you should be able to apply the Helm chart with the updated values and be good to go with the new database.

ArgoCD manages my helm deployments, but you may need to apply the helm chart with a command like this:

```bash
helm upgrade nextcloud nextcloud/nextcloud -f values.yaml -n nextcloud
```

{% admonition(type="failure", title="error: issue with Nextcloud's config.php") %}
After applying the Helm chart I found that it did not update the values of the `config.php` to the new database service.  This may be an issue with the Helm chart, the way the PVC is mounted, or maybe I didn't do something right.
{% end %}

### Fixing the `config.php` values

I decided to just manually edit the `config.php` in the Nextcloud pod to the updated values.  vi and nano weren't available, but sed was, so I used that to update

```bash
# create a backup first
kubectl -n nextcloud exec -it <nextcloud-pod> -- cp /var/www/html/config/config.php /var/www/html/config/config.php.BAK

# update dbhost
kubectl -n nextcloud exec -it <nextcloud-pod> -- sed -i "s/'dbhost' => '.*'/'dbhost' => 'nextcloud-postgresql-svc'/" /var/www/html/config/config.php
```

**Replace `nextcloud-postgresql-svc` with whatever your service name for Postgres is.**

Then I just recreated the pod, waited for it to report that it was up, and then went to the domain it's hosted at and saw that it was still up and in maintenance mode.

{% admonition(type="tip", title="tip") %}
If you run into any errors here, check your nextcloud logs with:

```bash
kubectl -n nextcloud exec -it <nextcloud-pod> -- less /var/www/html/data/nextcloud.log
```
{% end %}

## Step 4: Turn off maintenance mode

```bash
kubectl -n nextcloud exec -it <nextcloud-pod> -- php occ maintenance:mode --off
```

And with that you should be set up with your new Postgres instance that isn't using a Bitnami image.
