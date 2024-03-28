terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

variable "namespace" {
  type        = string
  description = "namespace to deploy to"
}

variable "app" {
  type = object({
    name = string
    port = number
  })
  default     = null
  description = "this module will create a service for the app, ignored if `service` variable is provided"
}

variable "service" {
  type = object({
    name = string
    port = map(any)
  })
  description = "service to use for ingress, if provided, `app` variable is ignored"
  default     = null
}
locals {
  service = var.service == null ? {
    name = "${var.app.name}-svc"
    port = { name = "http" }
  } : var.service

  service_port_name   = lookup(local.service.port, "name", null)
  service_port_number = lookup(local.service.port, "number", null)
}

variable "domain" { type = string }

variable "issuer" { type = string }
variable "tls" { type = object({
  hosts       = list(string)
  secret_name = string
}) }

variable "cors" {
  type = object({
    origins = list(string)
    methods = list(string)
  })
  default = null
}

variable "redirect_https" {
  type    = bool
  default = false
}
