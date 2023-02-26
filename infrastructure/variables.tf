variable "github" {
  type = object({
    organization       = string
    repository         = string
    auto_deploy_branch = optional(string, "master")
  })
}

variable "database" {
  type = object({
    host     = string
    port     = optional(number, 5432)
    username = string
    password = string
    database = string
  })
  sensitive = true
}

variable "name" {
  type = string
}

variable "root_domain" {
  type = string
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}