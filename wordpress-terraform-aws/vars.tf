variable aws_reg {
  description = "This is aws region"
  default     = "us-east-1"
  type        = string
}

variable stack {
  description = "this is name for tags"
  default     = "terraform-wordpress"
}

variable username {
  description = "DB username"
}

variable password {
  description = "DB password"
}

variable dbname {
  description = "db name"
}

variable ssh_key {
  default     = "files/id_rsa.pub"
  description = "Default pub key"
}

variable ssh_priv_key {
  default     = "files/id_rsa"
  description = "Default private key"
}

variable "ami_id" {
    type = string
    description = "ami id for amazon linux 2 in us-east-1 region."
}

variable "instance_type" {
    type = string
    description = "ec2 instance type."
}