project = "node-test"

app "node-test" {
  labels = {
    "service" = "node-test"
  }

  build {
    use "docker" {
      image = "node-test" # Name of the Docker image
      tag = "latest" # Tag for the Docker image

      registry {
        use "aws_ecr" {
          region = "eu-central-1" # AWS region
          repository = "waypoint-dp/node-test" # Repository name in ECR
          aws_account_id = "176791662223" # Your AWS account ID
        }
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

      image = "176791662223.dkr.ecr.eu-central-1.amazonaws.com/waypoint-dp/node-test:latest"

      ingress {
        host = "nodejs-demo.vicoland.io"  # Your specified domain
        class = "traefik-nlb"  # Ingress class for Traefik NLB
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
