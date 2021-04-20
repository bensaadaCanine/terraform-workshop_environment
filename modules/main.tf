terraform {
  backend "s3" {
    bucket         = "danishemeshterraform"
    key            = "workshop-production-env-state/terraform.tfstate"
    dynamodb_table = "tf-workshop-env-locks"
    region         = "us-east-2"
  }
}

provider "aws" {
  region = "us-east-2"
}


module "workshop-app" {
  source       = "../workshop-app"
}


module "workshop-app2" {
  source       = "../workshop-app"
  cluster_name = "workshop-terraform-another"
}

module "rds-global" {
  source = "../rds-global"
}
