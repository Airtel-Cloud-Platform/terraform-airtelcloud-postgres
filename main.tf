resource "airtelcloud_postgres" "this" {
  cluster_name      = var.cluster_name
  description       = var.description
  version           = var.postgres_version
  database_name     = var.database_name
  postgres_username = var.postgres_username
  password          = var.password
  compute_size      = var.compute_size
  storage_size      = var.storage_size
  availability_zone = var.availability_zone
  high_availability = var.high_availability
  num_replicas      = var.num_replicas
  is_superuser      = var.is_superuser
  network_type      = var.network_type
  storage_type      = var.storage_type
  vpc               = var.vpc
  subnet            = var.subnet
  custom_cidr       = var.custom_cidr
  pg_extensions     = var.pg_extensions
  labels            = var.labels
  backup            = var.backup

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = try(timeouts.value.create, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}
