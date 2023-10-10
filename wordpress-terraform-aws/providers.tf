provider "aws" {
  region = var.aws_reg
}

provider "template" {
    version = "~> 2.2.0"
}


