# Terraform AWS VPC + EKS Cluster

This project provisions an **Amazon VPC** and an **Amazon Elastic Kubernetes Service (EKS) cluster** using official Terraform community modules.

📖 Notes

Ensure your AWS profile is configured with proper IAM permissions.

The VPC is tagged for Kubernetes LoadBalancer support.

By default, this setup creates 2 managed node groups across 2 private subnets.

Modify variables for scaling, spot instances, or HA requirements.

---

## 💰 Costs

- **EKS control plane**: ~$0.10 USD/hour  
- **Extra costs**: EC2 worker nodes, NAT Gateways, and Load Balancers (ALB/NLB) are billed separately.  
- ⚠️ **Note**: NAT Gateways and Load Balancers can significantly increase monthly costs. Always clean up resources when not in use.

---

## 📦 Requirements

- [Terraform >= 0.12](https://www.terraform.io/downloads)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) with a configured profile
- An AWS account with sufficient permissions
- `kubectl` to interact with the EKS cluster

---

## ⚙️ Modules Used

- [terraform-aws-modules/vpc/aws](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest)  
- [terraform-aws-modules/eks/aws](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest)  

---

## 📂 Project Structure

- **VPC module**: Creates VPC, subnets (public + private), NAT gateways, and tags for Kubernetes.  
- **EKS module**: Creates EKS cluster, managed node groups, and applies networking/security settings.  
- **Security Groups**: Allows worker node management (SSH access limited to private CIDRs).  
- **Kubernetes Provider**: Automatically configures `kubeconfig` for access.

---

## 🚀 Usage

1. **Clone the repository** (or copy files locally).

2. **Initialize Terraform** (downloads providers and modules):
   ```bash
   terraform init

3. ** Terraform Plan**
   ```bash
      terraform plan -var="region=eu-central-1" -var="cluster_name=my-eks" -var="instance_class=t3.medium"

3. ** Create **
   ```bash
      terraform apply -auto-approve -var="region=eu-central-1" -var="cluster_name=my-eks" -var="instance_class=t3.medium"


3. **🧹 Cleanup** 

To destroy all resources (to avoid costs):
   ```bash
      terraform destroy -auto-approve