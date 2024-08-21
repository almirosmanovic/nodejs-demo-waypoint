project = "node-test"

app "node-test" {
  labels = {
    "service" = "node-test"
  }

  build {
    use "kaniko" {
      image = "node-test" # The name of the image to be built.
      tag = "latest" # Tag for the Docker image.
      context = "." # Build context
      dockerfile = "Dockerfile"

      registry {
        use "aws_ecr" {
          region = "eu-central-1" # AWS region where your ECR is located
          repository = "waypoint-dp/node-test"
        }
      }

      platform {
        executor = "fargate"
        profile  = "vicoland-non-prod" # Fargate profile name
        labels = {
          "use-vicoland-non-prod" = "true" # Label to ensure Fargate is used
        }
        memory   = "2GB"
        cpu      = "1vCPU"
      }
    }
  }

  deploy {
    use "kubernetes" {
      context_name = "vicoland-non-prod"  # Kubernetes context name
      namespace    = "default"

      service {
        type = "ClusterIP"
        port = 3000
      }

      ingress {
        host = "nodejs-demo.vicoland.io"  # Your specified domain
        class = "traefik-nlb"  # Updated ingress class
        annotations = {
          "kubernetes.io/ingress.class" = "traefik-nlb"
          "traefik.ingress.kubernetes.io/router.entrypoints" = "web"
          "traefik.ingress.kubernetes.io/router.priority" = "10"
        }
      }
    }
  }

  release {
    use "kubernetes" {}
  }
}
