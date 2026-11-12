terraform {
  required_providers {
    airtelcloud = {
      source  = "Airtel-Cloud-Platform/airtelcloud"
      version = "= 2.0.0"
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
  description       = "Application PostgreSQL cluster"
  postgres_version  = "17"
  database_name     = "app"
  postgres_username = "dbadmin"
  password          = var.postgres_password
  compute_size      = "db.postgres.uhper.ccs.xlarge"
  storage_size      = 200
  availability_zone = "S1"
  high_availability = true
  num_replicas      = 1
  vpc               = "copper-vpc1"
  subnet            = "temporal-subnet"
  custom_cidr       = ["192.168.1.0/24"]
  pg_extensions     = ["pgvector"]
  labels            = ["terraform"]

  backup = {
    enabled         = true
    protection_plan = "weekly-full-daily-incr"
    schedule_time   = "02:00"
    schedule_day    = "Monday"
  }

  timeouts = {
    create = "30m"
    delete = "30m"
  }
}
