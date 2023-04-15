provider "aws" {
  profile = lookup(var.awsprops, "profile")
  region = lookup(var.awsprops, "region")

  default_tags {
    tags = {
      Name ="TEST SPOKE VPC"
      Managed = "Terraform"
   }
  }
}