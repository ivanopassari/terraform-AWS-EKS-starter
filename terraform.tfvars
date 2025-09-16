region       = "eu-west-1"
profile      = "test-profile"
cluster_name = "my-eks-test"
instance_class = "t2.small"
kubernetes_version = "1.24"
map_accounts = ["123456789123"]
map_roles = [
  {
    rolearn  = "arn:aws:iam::123456789123:user/test-profile"
    username = "test-profile"
    groups   = ["system:masters"]
  },
]
map_users = [
  {
    userarn  = "arn:aws:iam::123456789123:user/test-profile"
    username = "test-profile"
    groups   = ["system:masters"]
  }
]