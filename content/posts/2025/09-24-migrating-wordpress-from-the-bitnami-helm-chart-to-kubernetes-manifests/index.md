+++
title = "Migrating WordPress from Bitnami Helm Charts to Official Images"
description = "A step-by-step guide to migrating from Bitnami WordPress Helm Chart to Official Images"
date = "2025-09-24"

[taxonomies] 
tags = ["wordpress", "bitnami", "mariadb", "homelab"]

[extra]
cover_image="cover-image.png"
+++

This is a continuation of my previous post about [migrating from the Bitnami Postgres image](/posts/2025/09-19-migrating-from-bitnami-databases-using-the-nextcloud-community-chart/).  In that post I modified the helm values for a Nextcloud instance to point to a freshly deployed Postgres database.  

This post will explain how I moved away from the Bitnami Helm chart for WordPress and went with official images and straight manifests defining all of the infrastructure.  Like with my Postgres database for nextcloud, the reason for migrating away from the Bitnami images was Bitnami's recent shift to a paid model.

Here's a step by step guide on how I did the migration and defined my Kubernetes infrastructure.

## Prerequisites

- Ability to execute into pods with `kubectl`
- WordPress and MariaDB instances from the Bitnami Helm chart running in the `wordpress` namespace (you can modify commands to match your namespace if it's different)
- Once again a backup of all WordPress data before starting would be nice to also have
- Secrets containing the credentials for MariaDB and Wordpress.  These can be created with:

```bash
kubectl create secret generic wordpress-mariadb-secrets \
  --from-literal=MARIADB_ROOT_PASSWORD='MyRootPassword' \
  --from-literal=MARIADB_REPLICATION_PASSWORD='MyReplicationPassword' \
  --from-literal=MARIADB_PASSWORD='MyUserPassword' \
  -n wordpress-new
```

```bash
kubectl create secret generic wordpress-secrets \
  --from-literal=WORDPRESS_DB_PASSWORD='MyUserPassword' \
  -n wordpress-new
```

{% admonition(type="info", title="Namespace Info") %}

My original WordPress was deployed into the `wordpress` namespace.  Due to pod naming conventions I decided to create a new namespace called `wordpress-new`, and after everything was migrated and the old resources removed, I moved the new resources from `wordpress-new` to `wordpress`

{% end %}

## Step 1: Deploy MariaDB

First I created a simple StatefulSet in the `wordpress-new` namespace using this manifest:

```yaml
---
## MariaDB StatefulSet for WordPress
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: wordpress-mariadb
spec:
  selector:
    matchLabels:
      app: wordpress-mariadb
  serviceName: "wordpress-mariadb-svc"
  replicas: 1
  minReadySeconds: 10
  template:
    metadata:
      labels:
        app: wordpress-mariadb
    spec:
      containers:
      - name: mariadb
        image: mariadb:11.8 # Match whatever version you want
        envFrom:
          - secretRef:
              name: wordpress-mariadb-secrets
        ports:
        - containerPort: 3306
          name: tcp-mariadb

        volumeMounts:
        - name: wordpress-mariadb-data
          mountPath: /var/lib/mysql

      volumes:
        - name: wordpress-mariadb-data
          persistentVolumeClaim:
            claimName: wordpress-mariadb-data
---
# MariaDB service
apiVersion: v1
kind: Service
metadata:
    name: wordpress-mariadb-svc
    labels:
        app: wordpress-mariadb
spec:
    ports:
    - port: 3306
      name: tcp-mariadb
    selector:
        app: wordpress-mariadb
```

{% admonition(type="info", title="PVC Info") %}
Storage is handled with a previously created PVC in the same namespace named `wordpress-mariadb-data`.

The ReclaimPolicy for this PVC will need to be set to `Retain` if you intend to move it to a new namespace
{% end %}

Once that's up and running we're ready for step 2:

## Step 2: Prepare MariaDB for Migration

{% admonition(type="note", title="Note") %}
For this migration I'm going to be shelling into the pods and performing commands directly.  It's not the best approach, but in this case I wanted ease and simplicity.
{% end %}

### Shell into the Bitnami MariaDB pod inside the `wordpress` namespace

```bash
# Find out the name of the pod.  It'll likely be wordpress-mariadb-0
kubectl get pods -n wordpress
# Shell into the pod
kubectl -n wordpress exec -it <wordpress-mariadb-pod> -- bash
```

### Dump the MariaDB database inside the pod

```bash
mysqldump -u root -p bitnami_wordpress > /tmp/backup.sql
```

Enter the password for the database and it should dump without any problems.

### Copy the dumped database to local machine

Exit out of the pod and copy the database

```bash
# don't forget to exit the pod
exit
# copy the database
kubectl cp wordpress/<wordpress-mariadb-pod>:/tmp/backup.sql ./backup.sql
```

### Copy the dumped database to the new mariadb pod in the `wordpress-new` namespace

```bash
# Get the name of the new mariadb pod
kubectl get pods -n wordpress-new
# copy the database
kubectl cp ./backup.sql wordpress-new/<new-wordpress-mariadb-pod>:/tmp/backup.sql
```

### Shell into the new MariaDB pod and login to MariaDB

```bash
# Shell into the new MariaDB pod
kubectl -n wordpress-new exec -it <new-wordpress-mariadb-pod> bash
# login to mariadb
mariadb -u root -p
```

It will prompt you for the root password you set with `MARIADB_ROOT_PASSWORD`

### Create the new Database

```bash
# Create the WordPress DB, USER, and grant privileges to new user
CREATE DATABASE wordpress;
CREATE USER 'wordpress'@'%' IDENTIFIED BY 'MySuperSecurePassword';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'%';
FLUSH PRIVILEGES;
```

### Import the dumped database and exit out of the pod

```bash
# import the database
mariadb -u root -p wordpress < /tmp/backup.sql
# get out of the pod
exit
```

The database is now good to go and we can get WordPress up and running

## Step 3: Deploy WordPress in the `wordpress-new` namespace

Here is a simple manifest I used for the WordPress deployment.  It includes the deployment, service, and an ingress using my internal ingressclass.

```yaml
---
## WordPress Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wordpress
spec:
  replicas: 1
  selector:
    matchLabels:
      app: wordpress
  template:
    metadata:
      labels:
        app: wordpress
    spec:
      containers:
      - name: wordpress
        image: wordpress:6.8.2-apache # Use whichever image version you want
        imagePullPolicy: IfNotPresent
      
        env:
        # DB ENV
        - name: WORDPRESS_DB_HOST
          value: wordpress-mariadb-svc:3306
        - name: WORDPRESS_DB_NAME
          value: wordpress
        - name: WORDPRESS_DB_USER
          value: wordpress
       
        # Pull all other env from external secret (DB Password)
        envFrom:
        - secretRef:
            name: wordpress-secrets

        ports:
        - containerPort: 80
          name: http
          protocol: TCP
        - containerPort: 443
          name: https
          protocol: TCP
        readinessProbe:
          failureThreshold: 6
          httpGet:
            path: /wp-login.php
            port: http
            scheme: HTTP
          initialDelaySeconds: 60
          periodSeconds: 10
          successThreshold: 1
          timeoutSeconds: 5
        volumeMounts:
        - mountPath: /var/www/html/wp-content
          name: wordpress-data

      volumes:
      - name: wordpress-data
        persistentVolumeClaim:
          claimName: wordpress-wordpress-data
---
# WordPress service
apiVersion: v1
kind: Service
metadata:
    name: wordpress-wordpress-svc
spec:
    selector:
        app: wordpress
    ports:
    - name: http
      port: 80
      targetPort: 80
    - name: https
      port: 443
      targetPort: 443
---
# WordPress Ingress
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: wordpress
spec:
  ingressClassName: internal
  tls:
  - hosts:
    - wordpress.pawked.com
  rules:
  - host: wordpress.pawked.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: wordpress-wordpress-svc
            port:
              number: 80
```

{% admonition(type="info", title="PVC Info") %}
Again, storage is handled with a previously created PVC in the same namespace named `wordpress-wordpress-data`.

The ReclaimPolicy for this PVC will need to be set to `Retain` if you intend to move it to a new namespace
{% end %}

## Step 4: Import Uploaded Content from old instance

### Copy the uploads from the old pod

We'll need to get the name of the old WordPress pod first

```bash
# Get the name of the old WordPress pod
kubectl get pods -n wordpress
# copy the uploads folder to the local machine
kubectl cp wordpress/<old-wordpress-pod>:/bitnami/wordpress/wp-content/uploads ./uploads
```

### Copy the uploads into the new pod

We need to get the new pod name as well

```bash
# Get the name of the new WordPress pod
kubectl get pods -n wordpress-new
# copy the uploads folder to the new WordPress pod
kubectl cp ./uploads/. wordpress-new/<new-wordpress-pod>:/var/www/html/wp-content/uploads/
```

### Set the permissions on the uploads content

```bash
kubectl exec -n wordpress-new <new wordpress-pod> -- chown -R www-data:www-data /var/www/html/wp-content/uploads
```

{% admonition(type="warning", title="Warning") %}
If you edited any themes or plugins in your original instance it might be better to copy the entire `/bitnami/wordpress/wp-content/` (minus the wp-config.php) using the same commands.
{% end %}

## Conclusion

And now you should be able to navigate to your WordPress instance and be ready to go.  If you want you can change the namespace from `wordpress-new` to something else.  I went with `wordpress` because I'm creative.

This migration was slightly more difficult than the Postgres one I did last week because of needing to shell in to the pods and creating the database, as well as moving the uploaded content over, but it was still fairly simple and worth doing to get away from the Bitnami images.
