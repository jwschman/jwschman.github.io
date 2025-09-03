+++
title = "Projects"
path = "projects"
+++

<div class="projects-list">
<div class="project-card" style="--bg: hsl(200,70%,45%); --accent: hsl(225,70%,50%)">
  <figure>
      <figcaption>
        <h3>Homelab</h3>
        <p class="project-subtitle">Self-hosted Multi-node Bare-metal Kubernetes Cluster</p>
        <p class="project-desc">Production-like environment built entirely with Infrasture-as-Code, from initial node provisioning to application deployment via GitOps</p>
        <div class="project-links">
          <a href="https://github.com/jwschman/homelabo">GitHub: https://github.com/jwschman/homelabo</a>
        </div>
        <div class="project-tech">
          <span>Kubernetes</span>
          <span>Ubuntu Server</span>
          <span>Cloud-init</span>
          <span>Ansible</span>
          <span>ArgoCD</span>
          <span>Helm</span>
          <span>Prometheus</span>
          <span>Grafana</span>
          <span>MetalLB</span>
          <span>Ingress-NGINX</span>
          <span>Hashicorp Vault</span>
        </div>
      </figcaption>
    </figure>
  </div>

  <div class="project-card" style="--bg: hsl(280,70%,50%); --accent: hsl(340,90%,55%)">
    <figure>
      <figcaption>
        <h3>The Cloud Resume Challenge</h3>
        <p class="project-subtitle">Serverless Cloud-Hosted Static Website</p>
        <p class="project-desc">Implemented Infrastructure-as-Code and CI/CD pipelines for automated deployments</p>
        <div class="project-links">
          <a href="https://github.com/jwschman/cloud-resume-challenge">GitHub: github.com/jwschman/cloud-resume-challenge</a>
          <a href="https:jwschman.click">Live Site: jwschman.click</a>
        </div>
        <div class="project-tech">
          <span>Terraform</span>
          <span>AWS</span>
          <span>Lambda</span>
          <span>DynamoDB</span>
          <span>CloudFront</span>
          <span>Route 53</span>
          <span>S3</span>
          <span>API Gateway</span>
          <span>Certificate Manager</span>
          <span>Github Actions</span>
          <span>HTML</span>
          <span>CSS</span>
          <span>Javascript</span>
        </div>
      </figcaption>
    </figure>
  </div>

<div class="project-card" style="--bg: hsl(160,50%,40%); --accent: hsl(90,50%,55%)">
  <figure>
      <figcaption>
        <h3>TrueNAS Gotify Adapter</h3>
        <p class="project-subtitle">Go Application for Centralized Alert Management</p>
        <p class="project-desc">A Go port of a Python script to implement a fake Slack webhook endpoint using Gin to capture TrueNAS alert webhooks and forward them to a Gotify instance. Built and deployed via GitHub Actions as a Docker image.</p>
        <div class="project-links">
          <a href="https://github.com/jwschman/truenas-gotify-adapter-golang">GitHub: https://github.com/jwschman/truenas-gotify-adapter-golang</a>
        </div>
        <div class="project-tech">
          <span>Go</span>
          <span>Gin Framework</span>
          <span>Docker</span>
          <span>Kubernetes</span>
          <span>GitHub Actions</span>
        </div>
      </figcaption>
    </figure>
  </div>

  <div class="project-card" style="--bg: hsl(20,70%,50%); --accent: hsl(350,90%,55%)">
    <figure>
      <figcaption>
        <h3>Simple Shelly Exporter</h3>
        <p class="project-subtitle">Minimal Prometheus Exporter for Shelly Plug US</p>
        <p class="project-desc">Lightweight Go-based exporter exposing only the active power (watts) from a single Shelly Plug US via Prometheus metrics, intended as a coding exercise with minimal dependencies.  Built and published as a Docker image to Docker Hub using GitHub Actions</p>
        <div class="project-links">
          <a href="https://github.com/jwschman/simple-shelly-exporter">GitHub: github.com/jwschman/simple-shelly-exporter</a>
        </div>
        <div class="project-tech">
          <span>Go</span>
          <span>Docker</span>
          <span>Prometheus</span>
          <span>Docker</span>
          <span>GitHub Actions</span>
          <span>REST API</span>
        </div>
      </figcaption>
    </figure>
  </div>

  <div class="project-card" style="--bg: hsl(320,70%,50%); --accent: hsl(260,90%,55%)">
    <figure>
      <figcaption>
        <h3>Jailhouse Roll Call</h3>
        <p class="project-subtitle">Go Application for Displaying TrueNAS Jail Information</p>
        <p class="project-desc">Fetches jail details from a TrueNAS server via API and renders them as an HTML table on a local web server using Go.</p>
        <div class="project-links">
          <a href="https://github.com/jwschman/jrc">GitHub: github.com/jwschman/jrc</a>
        </div>
        <div class="project-tech">
          <span>Go</span>
          <span>HTML</span>
          <span>TrueNAS API</span>
          <span>Gin Framework</span>
        </div>
      </figcaption>
    </figure>
  </div>
</div>
