# cloudflare-tunnel

create cloudflare tunnel and map it to a k8s service

```hcl

module "world_tunnel" {
  source = "github.com/linolabx/terraform-modules-k8s//cloudflare-tunnel"

  tunnel = {
    account_id = "..."
    name       = "A Hello World Service"
  }

  agent = {
    namespace     = "..."
    replicas      = 2
    node_selector = { "kubernetes.io/hostname" = "..." }
  }

  ingress_rule = [{
    hostname = "hello.example.com"
    service  = "http://service-hello.namespace.svc.cluster.local"
  }, {
    hostname = "world.example.com"
    service  = "http://service-world.namespace.svc.cluster.local"
  }]

  records = {
    "hello" = {
      zone_id = "..."
      name    = "hello.example.com"
    }
    "world" = {
      zone_id = "..."
      name    = "world.example.com"
    }
  }
}
```
