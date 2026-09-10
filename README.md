# Airtel Cloud PostgreSQL Terraform Module

Terraform module for provisioning an Airtel Cloud PostgreSQL cluster using `airtelcloud_postgres`.

v1 supports create, read, import, and delete. Changing configuration forces a new cluster. The API does not return the admin password; Terraform stores the configured value in state.

## Features

- Creates a PostgreSQL cluster
- Optional high availability (primary-standby) with replica count
- Optional backup schedule and protection plan
- Security group CIDR allow list
- Optional extensions and labels
- Create and delete timeouts

## Requirements

| Name | Version |
|------|---------|
| Terraform | >= 1.5 |
| airtelcloud | >= 1.2.6 |

## Usage

### Basic Example

```hcl
module "postgres" {
  source = "Airtel-Cloud-Platform/postgres/airtelcloud"

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
```

### Complete Example

```hcl
module "postgres" {
  source = "Airtel-Cloud-Platform/postgres/airtelcloud"

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
  pg_extensions     = ["pgvector"]
  labels            = ["terraform"]

  backup = {
    enabled         = true
    protection_plan = "weekly-full-daily-incr"
    schedule_time   = "02:00"
    schedule_day    = "Monday"
  }

  security_group = {
    allowed_ips = ["192.168.1.0/24"]
  }

  timeouts = {
    create = "30m"
    delete = "30m"
  }
}
```

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| cluster_name | Display name of the cluster | string | Yes |
| postgres_version | PostgreSQL major version | string | Yes |
| database_name | Initial database name | string | Yes |
| postgres_username | Admin username | string | Yes |
| password | Admin password | string | Yes |
| compute_size | Flavor name | string | Yes |
| storage_size | Data volume size in GB (min 200) | number | Yes |
| availability_zone | Availability zone code | string | Yes |
| security_group | Allowed client CIDRs (`allowed_ips`) | object | Yes |
| description | Cluster description | string | No |
| high_availability | Primary-standby topology | bool | No |
| num_replicas | Standby replica count | number | No |
| is_superuser | Admin superuser flag | bool | No |
| network_type | Network type (default `private`) | string | No |
| storage_type | Storage class (default `High Performance`) | string | No |
| pg_extensions | Extensions to enable | list(string) | No |
| labels | Labels to assign | list(string) | No |
| backup | Backup configuration | object | No |
| timeouts | Create and delete timeouts | object | No |

## Outputs

| Name | Description |
|------|-------------|
| id | Cluster UUID |
| cluster_name | Configured cluster name |
| version | PostgreSQL major version |
| database_name | Initial database name |
| postgres_username | Admin username |
| status | Current cluster status |
| topology | Resolved topology |
| num_replicas | Standby replica count |
| availability_zone | Availability zone |
| created_at | Creation timestamp |
| connection_string | Connection string (password masked by the API) |
| postgres | Selected cluster attributes |

## Notes

- Configuration changes force a new cluster.
- When `high_availability` is true, `num_replicas` must be between 1 and 10.
- When `backup.enabled` is true, `schedule_time` (`HH:MM`) and `schedule_day` are required.
- Import cannot populate `password` because the API does not return it.
