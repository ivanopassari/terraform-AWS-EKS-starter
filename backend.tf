# store the terraform state file in s3
#terraform {
#  backend "s3" {
#    bucket    = "test-bucket"
#    key       = "test-proj-ecs.tfstate"
#    region    = "us-east-1"
#    profile   = "terraform-user"
#  }
#}

terraform {
  backend "local" {
    path = "./state/terraform.tfstate"
  }
}
