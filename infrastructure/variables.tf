variable "github" {
  type = object({
    organization       = string
    repository         = string
    auto_deploy_branch = optional(string, "master")
  })
}

variable "database" {
  type = object({
    host         = string
    port         = optional(number, 5432)
    username     = string
    password     = string
    database     = string
  })
  sensitive = true
}

variable "name" {
  type = string
}

variable "environment" {
  type = string
  default = "production"
}

variable "activestorage" {
  type = object({
    s3_bucket = string
  })
  description = "Name of S3 bucket where ActiveStorage files are stored"
}

variable "smtp" {
  type = object({
    username = string
    password = string
  })
  description = "Credentials for SMTP server to use for email. Assumes SES."
}

variable "internal_port" {
  type        = number
  default     = 3030
  description = "Port the service listens on internally. Does not affect port exposed to users."
}

variable "root_domain" {
  type = string
}

variable "main_subdomain" {
  type        = string
  description = "Subdomain by which people will access the site. Do not include a dot."
}

variable "alias_subdomains" {
  type = list(string)
  default = []
}

variable "service_discovery_subdomain" {
  type = string
}

variable "include_root_domain_alias" {
  type = bool
  default = false
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
  description = <<-DESC
    IPv4 CIDR for the VPC. Arbitrary dummy value.
    Our infrastructure is IPv6-only, but AWS still requires an IPv4 CIDR to be specified
    on all VPCs.
  DESC
}

variable "errors_email" {
  type        = string
  description = "Email that receives notifications when infrastructure fails to run properly"
}

variable "create_image_transform_lambda" {
  type        = bool
  default     = false
  description = <<-EOT
    Create the image-transform Lambda function. Leave false for the first apply so Terraform can
    provision the ECR repository and GitHub deploy variables before any image exists. Run the deploy
    workflow to push the Lambda image, then set this to true and apply again.
  EOT
}
