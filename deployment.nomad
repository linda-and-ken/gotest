variable "image" {
  type = string
}

variable "commit_id" {
  type    = string
  default = "unknown"
}

job "linda-nihao" {
  datacenters = ["dc1"]
  type        = "service"
  constraint {
    attribute = "${meta.role}"
    operator  = "="
    value     = "worker"
  }

  group "web" {
    count = 1

    network {
      port "http" {
        to = 8080
      }
    }

    task "linda-nihao" {
      driver = "docker"

      config {
        image = var.image
        ports = ["http"]
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
          "traefik.http.routers.linda-nihao.rule=Host(`linda.com`)",
          "traefik.http.routers.linda-nihao.entrypoints=web",
        ]
      }
    }
  }
}
