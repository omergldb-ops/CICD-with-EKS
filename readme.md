Engineering Design Document: Cloud-Native EKS Ecosystem
This project implements a production-ready, highly available infrastructure on AWS. It demonstrates the integration of Infrastructure as Code (IaC), Immutable Deployments, and Observability-Driven Development.

🏗️ 1. Infrastructure Philosophy (Terraform)
The infrastructure is modularized to ensure reusability and isolation of state.

Networking Strategy: I utilized a Tiered VPC design.


Public Subnets: Reserved strictly for the AWS Network Load Balancer (NLB).


Private Subnets: All EKS Worker Nodes reside here. They have no public IP addresses, significantly reducing the attack surface. Egress traffic is handled via a NAT Gateway (optional for cost, but standard for production).



Security & IAM:


Principle of Least Privilege: Used specific IAM roles for the EKS Cluster and Worker Nodes, ensuring they only have the permissions necessary to manage networking and pull images from ECR.



State Management: Terraform state is stored in a Private S3 Bucket with "Block Public Access" enabled. I enabled Bucket Versioning to protect against accidental state corruption.

📦 2. Application Delivery (Docker & Helm)

Containerization: The Python Flask app is containerized using a multi-stage build (or slim base) to optimize image size and security.



Helm Orchestration: I chose Helm over raw Kubernetes manifests to manage the application as a single logical unit.



Reliability: Integrated Liveness and Readiness probes to ensure the Load Balancer only directs traffic to healthy pods.


Scalability: Used Horizontal Pod Autoscaling (HPA) logic within the chart to allow the app to respond to traffic spikes.

🤖 3. Unified CI/CD (GitHub Actions)
The pipeline is designed for High-Frequency Delivery with zero manual intervention.


Workflow A (Infra): Handles Terraform Plan/Apply to prevent "Configuration Drift".

Workflow B (App):


Immutability: Every build is tagged with the GITHUB_SHA. We never use the latest tag in production, ensuring 100% traceability.


Automated Deployment: Helm upgrades the release only after a successful Docker push.


Observability Sync: Automatically updates the Prometheus/Grafana stack to ensure monitoring matches the current deployment.

📈 4. Observability Stack (Bonus 2)
A "Black Box" application is a liability. I deployed a Prometheus and Grafana stack to provide full-stack visibility.


Metrics: Prometheus scrapes resource utilization (CPU/RAM) and application-level metrics.


Visualization: Grafana provides real-time dashboards for the SRE (Site Reliability Engineering) team to monitor latency and error rates.

🛠️ Operational Instructions
Setup AWS Environment
Credentials: Store AWS Access Keys in GitHub Secrets.


State: Create the S3 bucket manually to bootstrap the Terraform backend.

Deployment Flow
Bash

# 1. Provision Infrastructure
cd terraform && terraform apply -auto-approve

# 2. Deploy Application & Monitoring
# Handled automatically by GitHub Actions on 'git push'
Essential Outputs 


EKS Cluster Name: devops-eks-cluster 


EKS Endpoint: The internal API server address 


ECR Repository: The URI for image hosting 


Application URL: The dynamically generated LoadBalancer DNS 

💡 Interviewer FAQ (The "Deep Dive")
Why EKS? "It offloads the Control Plane management to AWS, allowing us to focus on application scaling rather than Kubernetes maintenance."

Why Helm? "It allows us to version our infrastructure and application together, making rollbacks a one-command operation."

Why Private Subnets? "To ensure that even if an application is compromised, the underlying host is not directly reachable from the public internet."