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

variable "create_service" {
  type        = bool
  default     = true
  description = "create a service for the app, if false, 'service' variable is required, if true, 'app' variable is required"
}

variable "app" {
  type = object({
    name = string
    port = number
  })
}

variable "service" {
  type = object({
    name      = string
    port_name = string
  })
  description = "service to use for ingress"
  default     = null
}
locals {
  service = var.create_service ? {
    name      = "${var.app.name}-svc"
    port_name = "http"
  } : var.service
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
