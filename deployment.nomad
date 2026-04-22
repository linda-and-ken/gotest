variable "image" {
  type = string
}

variable "commit_id" {
  type    = string
  default = "unknown"
}

job "app-aaa" {
  datacenters = ["dc1"]
  type        = "service"
  constraint {
    attribute = "${meta.account_group}"
    operator  = "="
    value     = "old"
  }

  group "web" {
    count = 1

    network {
      port "http" {
        to = 8080
      }
    }

    task "app" {
      driver = "docker"

      config {
        image = var.image
        ports = ["http"]
        args  = ["nginx", "-g", "daemon off;"]
        extra_hosts = [
          "aaa.internal:${attr.unique.network.ip-address}",
          "bbb.internal:${attr.unique.network.ip-address}",
        ]
      }

      template {
        destination = "local/env.prod"
        change_mode = "restart"
        data = <<EOF
KKK=VVV
EOF
      }

      env {
        APP_ENV        = "dev"
        LOG_LEVEL      = "info"
        FEATURE_FLAG_X = "true"
        GIT_COMMIT     = var.commit_id
      }

      resources {
        cpu    = 200
        memory = 256
      }

      service {
        name = "app-aaa"
        port = "http"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.app-aaa.rule=Host(`aaa.internal`)",
          "traefik.http.routers.app-aaa.entrypoints=web",
        ]
      }
    }
  }
}
