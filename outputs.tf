output "id" {
  description = "UUID of the PostgreSQL cluster."
  value       = airtelcloud_postgres.this.id
}

output "cluster_name" {
  description = "Configured cluster name."
  value       = airtelcloud_postgres.this.cluster_name
}

output "version" {
  description = "PostgreSQL major version."
  value       = airtelcloud_postgres.this.version
}

output "database_name" {
  description = "Initial database name."
  value       = airtelcloud_postgres.this.database_name
}

output "postgres_username" {
  description = "Admin username for the PostgreSQL cluster."
  value       = airtelcloud_postgres.this.postgres_username
}

output "status" {
  description = "Current cluster status."
  value       = airtelcloud_postgres.this.status
}

output "topology" {
  description = "Resolved topology (standalone or primary-standby)."
  value       = airtelcloud_postgres.this.topology
}

output "num_replicas" {
  description = "Number of standby replicas."
  value       = airtelcloud_postgres.this.num_replicas
}

output "availability_zone" {
  description = "Availability zone of the cluster."
  value       = airtelcloud_postgres.this.availability_zone
}

output "created_at" {
  description = "Creation timestamp of the cluster."
  value       = airtelcloud_postgres.this.created_at
}

output "connection_string" {
  description = "PostgreSQL connection string. Empty until the cluster is Active. The API masks the password."
  value       = airtelcloud_postgres.this.connection_string
}

output "postgres" {
  description = "Selected cluster attributes for downstream modules."

  value = {
    id                = airtelcloud_postgres.this.id
    cluster_name      = airtelcloud_postgres.this.cluster_name
    version           = airtelcloud_postgres.this.version
    database_name     = airtelcloud_postgres.this.database_name
    postgres_username = airtelcloud_postgres.this.postgres_username
    status            = airtelcloud_postgres.this.status
    topology          = airtelcloud_postgres.this.topology
    num_replicas      = airtelcloud_postgres.this.num_replicas
    availability_zone = airtelcloud_postgres.this.availability_zone
    created_at        = airtelcloud_postgres.this.created_at
    connection_string = airtelcloud_postgres.this.connection_string
  }
}
