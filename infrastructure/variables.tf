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
    cluster_name = string
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

variable "activestorage" {
  type = object({
    s3_bucket = string
    region    = string
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

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "errors_email" {
  type        = string
  description = "Email that receives notifications when infrastructure fails to run properly"
}
