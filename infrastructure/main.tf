terraform {
  required_version = ">= 1.3"

  backend "s3" {
    encrypt = "true"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
    local = {
      source = "hashicorp/local"
      version = "~> 2.5"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

provider "aws" {
  alias  = "bucket"
  region = var.activestorage.region
}

provider "github" {}

provider "random" {}

provider "tls" {}

data "aws_region" "current" {}

data "local_sensitive_file" "master_key" {
  # assumes you're running from the `infrastructure/` directory,
  # since we can't look up the project root
  filename = "../config/credentials/production.key"
}
