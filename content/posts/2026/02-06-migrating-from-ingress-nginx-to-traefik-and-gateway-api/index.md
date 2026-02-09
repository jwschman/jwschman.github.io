+++
title = "Migrating from Ingress-NGINX to Traefik and Gateway API"
description = "How I migrated my Kubernetes homelab from Ingress to Gateway API using Traefik"
date = "2026-02-06"

[taxonomies] 
tags = ["kubernetes", "ingress-nginx", "traefik", "gateway-api", "ingress", "homelab"]

[extra]
cover_image="cover-image.png"
+++

It is 2026 and there is time for... Gateway API.

[Ingress-NGINX is deprecated](https://kubernetes.io/blog/2025/11/11/ingress-nginx-retirement/) and will no longer be getting any updates after March 2026.  I'm a little sad because I spent a lot of time when I initially set up my Kubernetes cluster deciding how I wanted to handle ingress, and Ingress-NGINX seemed like the perfect match.  I already had some experience with NGINX from my FreeBSD server, and still use it as a reverse proxy for some internal services, but it's time to say goodbye to it in my cluster.

[Traefik Proxy](https://doc.traefik.io/traefik/reference/install-configuration/providers/kubernetes/kubernetes-gateway/) seemed like the obvious choice for me.  I was already aware of it and interested since [it's one of the conformant implementations of Gateway API](https://gateway-api.sigs.k8s.io/implementations/) but never had the push to use it because things were already working great.  But Gateway APIs are where Kubernetes is heading, and so am I now.

## Requirements

I used split ingress with Ingress-NGINX, which meant two ingress controllers: one for internal traffic and one for external.  I wanted there to be no way for me to accidentally expose a service to the internet, and having an internal only ingress helped me do that.  I needed something like that with Traefik, and fortunately Gateways worked well for this.

I also wanted this to be a mostly drop in replacement.  Needing to rework all of my infrastructure would have been more than I wanted to do, but fortunately things were fairly simple.  I did have to write a lot of HTTPRoutes, but they were pretty easily derived from my existing ingresses.

## Implementation

Traefik has an official Helm chart available which made deployment as simple as anything else.  Since I'm switching entirely to Gateway API I disabled the ingressClass.  I could have made things extremely simple by just switching to that, but where's the fun in that?  I also disabled the default gateway since I would be defining my own for the split gateways.  The thing I love about Kubernetes is just being able to define things myself as code, and work on that as I go.  Here's a pared down example of my `values.yaml`

```yaml
# We will route with Gateway API instead.
ingressClass:
  enabled: false

# Enable Gateway API Provider & Disable the KubernetesIngress provider
providers:
  kubernetesGateway:
    enabled: true
  kubernetesIngress:
    enabled: false

## Disable the default gateway
gateway:
  enabled: false

# Enable Observability
logs:
  general:
    level: INFO
  access:
    enabled: true

# Enables Prometheus for metrics
metrics:
  prometheus:
    enabled: true

# Set up LoadBalancer service
service:
  enabled: true
  single: true
  type: LoadBalancer
  spec:
    externalTrafficPolicy: Local
```

With Ingress-NGINX, I ran two separate IngressController deployments with different IngressClasses, each with its own LoadBalancer service and IP--one for internal traffic and one for external.  This completely isolated them.

I tried the same approach with Traefik, but even though I had two separate deployments, they both register with the same GatewayClass controller.  This meant both instances tried to handle the same Gateway resources, causing the LoadBalancer IPs to hop between them unpredictably, making deployment this way impossible.

Instead, I use a single Traefik deployment with one LoadBalancer IP, separating internal and external traffic using different ports (8888/8444 for external, 80/443 for internal) assigned to each Gateway.

TLS is handled similarly to my old ingress classes.  Certs are managed by... well they're managed by cert-manager and applied directly at the gateway so I don't ever have to worry about them.  Here's how the external gateway is defined:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: external-gateway
  namespace: traefik
spec:
  gatewayClassName: traefik
  listeners:
    - name: web-ext         # matches port 'web'
      protocol: HTTP
      port: 8888
      allowedRoutes:
        namespaces:
          from: All

    - name: websecure-ext   # matches port 'websecure'
      protocol: HTTPS       
      port: 8444
      allowedRoutes:
        namespaces:
          from: All
      tls:                  # TLS terminates inside Traefik
        mode: Terminate 
        certificateRefs:    # TLS Certificate Reference
          - kind: Secret
            name: traefik-jwschman-wildcard-cert-secret
            group: ""
            namespace: "traefik"
```

And here is how I set up the external ports that I mentioned previously in my `values.yaml`.  You can see how they line up with my external Gateway listeners:

```yaml
ports:
  web-ext: # external web
    port: 8888
    redirections:
      entryPoint:
        to: websecure-ext # redirect all traffic to websecure-ext
        scheme: https
        permanent: true
    expose:
      default: true
    exposedPort: 8888
    middlewares:
      - traefik-external-ip-whitelist@kubernetescrd # cloudflare IP only whitelist

  websecure-ext:
    port: 8444
    expose:
      default: true
    exposedPort: 8444
    middlewares:
      - traefik-external-ip-whitelist@kubernetescrd # cloudflare IP only whitelist
```

One cool thing about Traefik is how it uses middlewares.  Because I was going to have externally facing services, as well as internal services, I was able to set up a whitelist middleware that only allowed Cloudflare Proxy IPs to the external gateway, and internal IPs to the internal services.  There was also a http redirect middleware (among loads of others) that let me redirect all http traffic to https, but I wound up using built in redirects inside the ports definitions themselves.  And since everything is applied directly to the ports themselves, I don't have to worry about them on any of my HTTPRoutes.  

Here's the middleware definition for the external access whitelist:

```yaml
---
# External IP Whitelist (cloudflare)
apiVersion: traefik.io/v1alpha1
kind: Middleware
metadata:
  name: external-ip-whitelist
  namespace: traefik
spec:
  ipAllowList:
    sourceRange:
      - "173.245.48.0/20"
      - "103.21.244.0/22"
      - "103.22.200.0/22"
      # Full Cloudflare IP ranges
```

Once the gateways, certs, and middlewares were up and running the only thing I needed to do was change all my ingresses to HTTPRoutes.  The format isn't too different and there was a lot of copy pasting, but everything just worked after the switch and I didn't have any troubles with any of my services.  I guess that's another cool thing about running things in Kubernetes, it doesn't care what the actual networking is, as long as it's there.

Here's an example of the old ingress I used for an internal service:

```yaml
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: gotify
  namespace: gotify
spec:
  ingressClassName: internal
  tls:
  - hosts:
    - gotify.pawked.com
  rules:
  - host: gotify.pawked.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: gotify
            port:
              number: 80
```

And here's the HTTPRoute that replaced it.  You can see that they're quite similar:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: gotify
  namespace: gotify
spec:
  parentRefs:
    - name: internal-gateway
      namespace: traefik
      kind: Gateway
  hostnames:
    - gotify.pawked.com
  rules:
    - matches:
        - path:
            type: PathPrefix
            value: /
      backendRefs:
        - name: gotify
          port: 80
          kind: Service
```

I started by converting a couple of test ingresses to HTTPRoutes to make sure everything worked as expected.  Once I confirmed those were functioning properly, I went ahead and switched all the remaining ingresses in one go.  Argo handled the deployment.  There may have been brief service interruptions during the change, but since these are all internal services I didn't notice any issues.

As usual, you can see how everything is configured [on my homelab GitHub repo.](https://github.com/jwschman/homelabo)

## Difficulties

The first difficulty I had was trying to do the dual deployments.  Once I saw the IP address bouncing between the two services I knew that wouldn't be feasible and it was easy to just choose dual gateways.  That makes more sense anyway.

Also, I discovered that some of my internal services weren't able to get Prometheus metrics.  After I thought about it for a minute, I realized that my internal whitelist was too strict and wasn't allowing the actual Kubernetes pods to communicate with each other.  Once I added my the IP range for my cluster to the whitelist, things just worked again.

I also had a little bit of problems with the default gateway's ports trying to overlap the ports on my defined gateways, but disabling the default gateway was an easy way to solve that.

The biggest hassle (and calling it a hassle is a stretch) is that most helm charts currently don't seem to support Gateway API out of the box, and you can't just set your gateway like you can with ingressClass.  It's not a problem to create the HTTPRoute in the templates, but it would be nice to start seeing helm charts support it.

## What I like

The built-in Prometheus metrics make monitoring great and everything shows up as expected.  The Traefik dashboard is also useful for troubleshooting, though it's not something I check very often.  Having an official Helm chart maintained by the Traefik team is also nice.

But honestly I mostly just like being on Gateway API rather than Ingresses since that's the way Kubernetes is going.  Setting up the traefik ports with attached middlewares and Kubernetes gateways means I don't have to worry about the security when I write my HTTPRoutes, because it's already handled for me.

## Conclusion

If you're still using Ingress-NGINX you should definitely consider making the switch as soon as possible, and Traefik is a great replacement.  If I were setting this up from scratch today, I'd skip Ingress entirely and go straight to Gateway API with Traefik.  The switch from Ingress to Gateway API was quite simple, and there are no noticeable changes in the usage of my services.  Things just still work, and that's exactly what I wanted.
