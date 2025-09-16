terraform {
  required_version = ">= 0.12.0"
}

provider "aws" {
  profile = var.profile
  region  = var.region
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

data "aws_availability_zones" "available" {
}

resource "aws_security_group" "worker_group_mgmt_one" {
  name_prefix = "worker_group_mgmt_one"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
    ]
  }
}

resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "all_worker_management"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 3.18.1"

  name                 = "${var.cluster_name}-vpc"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["10.0.3.0/24", "10.0.4.0/24"]
  public_subnets       = ["10.0.1.0/24", "10.0.2.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = false
#  one_nat_gateway_per_az = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "~> 18.0"
  cluster_name    = var.cluster_name
  cluster_version = var.kubernetes_version
  subnet_ids      = module.vpc.private_subnets

  # cluster_timeouts                = {}
  cluster_endpoint_private_access = true

  vpc_id = module.vpc.vpc_id

  eks_managed_node_group_defaults = {
    instance_types   = [var.instance_class]
    min_capacity     = 1
    max_capacity     = 2
    desired_capacity = 1
    capacity_type    = "ON_DEMAND"
  }

  eks_managed_node_groups = {
    "default-a" = {
      desired_capacity           = 1
      ami_type                   = "AL2_x86_64"
      instance_types             = [var.instance_class]
      subnets                    = [module.vpc.private_subnets[0]]
      enable_bootstrap_user_data = false
      k8s_labels = {
        network = "private"
      }
    }
    "default-b" = {
      desired_capacity           = 1
      ami_type                   = "AL2_x86_64"
      instance_types             = [var.instance_class]
      subnets                    = [module.vpc.private_subnets[1]]
      enable_bootstrap_user_data = false
      k8s_labels = {
        network = "private"
      }
    }
  }

  node_security_group_id = aws_security_group.all_worker_mgmt.id
  node_security_group_additional_rules = {
    ingress_allow_access_from_control_plane = {
      type                          = "ingress"
      protocol                      = "tcp"
      from_port                     = 9443
      to_port                       = 9443
      source_cluster_security_group = true
      description                   = "Allow access from control plane to webhook port of AWS load balancer controller"
    }
  }
  aws_auth_roles         = var.map_roles
  aws_auth_users         = var.map_users
  aws_auth_accounts      = var.map_accounts
}


#Provide certificate and kubeconfig.yaml configuration
provider "kubernetes" {
#  alias = "eks"
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}
