terraform {
  required_providers {
    airtelcloud = {
      source  = "Airtel-Cloud-Platform/airtelcloud"
      version = ">= 1.2.5"
    }
  }
}

provider "airtelcloud" {
  api_endpoint = "https://south.cloud.airtel.in"
  api_key      = var.airtel_api_key
  api_secret   = var.airtel_api_secret
  region       = "south"
  organization = var.organization
  project_name = var.project_name
}

module "postgres" {
  source = "../../"

  cluster_name      = "app-db"
  postgres_version  = "17"
  database_name     = "app"
  postgres_username = "dbadmin"
  password          = var.postgres_password
  compute_size      = "db.postgres.uhper.ccs.xlarge"
  storage_size      = 200
  availability_zone = "S1"

  security_group = {
    allowed_ips = ["192.168.1.0/24"]
  }
}
