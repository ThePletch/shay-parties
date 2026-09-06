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

variable "turnstile" {
  type = object({
    site_key   = string
    secret_key = string
  })
  sensitive   = true
  description = "Cloudflare Turnstile site and secret keys for signup captcha"
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

variable "bootstrap" {
  type = object({
    image_transform_lambda   = optional(bool, false)
    ses_webhook_subscription = optional(bool, false)
  })
  default     = {}
  description = <<-EOT
    Two-phase apply flags. Leave the defaults for the first apply on a new environment, deploy,
    then set the relevant keys to true and apply again.

    image_transform_lambda: create the Lambda function for image transforms after the deploy workflow has pushed an image to ECR.
    ses_webhook_subscription: subscribe SNS to /webhooks/ses after the app is serving that endpoint
    (HTTPS subscriptions require a live SubscriptionConfirmation handshake).
  EOT
}
