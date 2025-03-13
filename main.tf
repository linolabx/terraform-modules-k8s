terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

variable "cluster_url" {
  type = string
}

variable "namespace" {
  type = string
}

variable "forwards" {
  type = map(object({
    # pod, service, deployment
    type = string
    # resource name
    name = string
    # port: port number or name
    port = string
  }))
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "kubernetes_role_v1" "this" {
  metadata {
    name      = "tf-port-forward-${random_string.suffix.result}"
    namespace = var.namespace
  }

  rule {
    api_groups = [""]
    resources  = ["pods/portforward"]
    verbs      = ["get", "create"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "services"]
    verbs      = ["get", "list"]
  }

  rule {
    api_groups = ["apps"]
    resources  = ["deployments"]
    verbs      = ["get", "list"]
  }
}

resource "kubernetes_service_account" "this" {
  metadata {
    name      = "tf-port-forward-${random_string.suffix.result}"
    namespace = var.namespace
  }
}

resource "kubernetes_role_binding" "this" {
  metadata {
    name      = "tf-port-forward-${random_string.suffix.result}"
    namespace = var.namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.this.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.this.metadata[0].name
    namespace = var.namespace
  }
}

resource "kubernetes_secret" "this" {
  metadata {
    name      = "tf-port-forward-${random_string.suffix.result}"
    namespace = var.namespace
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account.this.metadata[0].name
    }
  }

  type                           = "kubernetes.io/service-account-token"
  wait_for_service_account_token = true
}

resource "local_sensitive_file" "kubeconfig" {
  filename = "${path.root}/.terraform/tmp/kubeconfig-${random_string.suffix.result}.yaml"
  content = yamlencode({
    apiVersion = "v1"
    kind       = "Config"
    clusters = [{
      name = "default"
      cluster = {
        server                     = var.cluster_url
        certificate-authority-data = base64encode(kubernetes_secret.this.data["ca.crt"])
      }
    }]
    users = [{
      name = "default"
      user = { token = kubernetes_secret.this.data["token"] }
    }]
    contexts = [{
      name = "default"
      context = {
        cluster   = "default"
        namespace = var.namespace
        user      = "default"
      }
    }]
    current-context = "default"
    preferences     = {}
  })
}

locals {
  script_file = "${path.root}/.terraform/tmp/script-${random_string.suffix.result}.sh"
}

resource "local_sensitive_file" "script" {
  filename = local.script_file
  content = <<EOF
#!/usr/bin/env bash
set -e

export KUBECONFIG=${local_sensitive_file.kubeconfig.filename}

rnd_port() {
  local min=10000
  local max=60000
  echo $((RANDOM % (max - min + 1) + min))
}

free_port() {
  local port
  while true; do
    port=$(rnd_port)
    if ! nc -z 127.0.0.1 "$port" >/dev/null 2>&1; then
      echo "$port"
      break
    fi
  done
}

declare -A srv2port

sessionname="tf-port-forward-${random_string.suffix.result}"
screen -S $sessionname -X quit &>/dev/null || true
screen -dmS $sessionname bash
screen_run() {
  screen -S $sessionname -X stuff "$1 ^M"
}

# forward key res port
forward() {
  local key=$1
  local res=$2
  local port=$3

  local_port=$(free_port)
  srv2port["$key"]="$local_port"

  screen_run "kubectl port-forward $res $local_port:$port &"
}

${join("\n", concat(
  [for key, value in var.forwards : "forward ${key} ${var.forwards[key].type}/${var.forwards[key].name} ${var.forwards[key].port}"]
))}


for key in "$${!srv2port[@]}"; do
    echo "$key $${srv2port[$key]}"
done | jq -R -s -c 'split("\n")[:-1] | map(split(" ")) | map({(.[0]): .[1]|tonumber}) | add | tostring | {"forward_ports": .}'

get_tf_pid() {
  cut -d' ' -f4 < /proc/self/stat \
    | xargs -I% sh -c 'cut -d" " -f4 < /proc/%/stat' \
    | xargs -I% sh -c 'cut -d" " -f4 < /proc/%/stat' \
    | xargs -I% sh -c 'cut -d" " -f4 < /proc/%/stat'
}

screen_run "clear_sensitive_files() { rm ${local.script_file} ${local_sensitive_file.kubeconfig.filename} || true; }"
screen_run "clear_background_jobs() { kill \$(jobs -p) || true; }"

screen_run "trap 'clear_sensitive_files && clear_background_jobs' EXIT"

screen_run "tail --pid=$(get_tf_pid) -f /dev/null; exit"

sleep 30
EOF
}

data "external" "port_forward" {
  depends_on = [local_sensitive_file.script]
  program    = ["bash", local.script_file]
  query      = {}
}

output "forward_ports" {
  value = jsondecode(data.external.port_forward.result.forward_ports)
}
