# Airtel Cloud PostgreSQL Terraform Module

Terraform module for provisioning an Airtel Cloud PostgreSQL cluster using `airtelcloud_postgres`.

v1 supports create, read, import, and delete. Changing configuration forces a new cluster. The API does not return the admin password; Terraform stores the configured value in state.

## Features

* Creates an Airtel Cloud PostgreSQL cluster
* Supports PostgreSQL major versions
* Configurable compute flavor and storage size
* Supports standalone and high-availability primary-standby topology
* Configurable standby replica count
* Configurable availability zone
* Optional PostgreSQL extensions
* Optional labels
* Optional backup configuration
* Provider-compatible VPC/subnet and custom CIDR network access
* Configurable network and storage types
* Create and delete timeouts
* Supports importing existing PostgreSQL clusters

## Requirements

| Name        | Version  |
| ----------- | -------- |
| Terraform   | >= 1.5   |
| airtelcloud | = 2.0.0  |

## Usage

### Basic Example

```hcl
variable "postgres_password" {
  type      = string
  sensitive = true
}

module "postgres" {
  source = "Airtel-Cloud-Platform/postgres/airtelcloud"

  cluster_name      = "example-postgres"
  postgres_version  = "17"
  database_name     = "exampledb"
  postgres_username = "dbadmin"
  password          = var.postgres_password
  compute_size      = "db.postgres.uhper.ccs.xlarge"
  storage_size      = 200
  availability_zone = "S1"

  custom_cidr = ["192.168.1.0/24"]
}
```

### Complete Example

```hcl
variable "postgres_password" {
  type      = string
  sensitive = true
}

module "postgres" {
  source = "Airtel-Cloud-Platform/postgres/airtelcloud"

  cluster_name      = "example-postgres"
  description       = "Example PostgreSQL cluster"
  postgres_version  = "17"
  database_name     = "exampledb"
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

  is_superuser = false
  network_type = "private"
  storage_type = "High Performance"

  pg_extensions = ["pgvector"]
  labels        = ["terraform"]

  backup = {
    enabled          = true
    protection_plan  = "weekly-full-daily-incr"
    compression_level = 6
    retention         = 15
    schedule_time    = "02:00"
    schedule_day     = "Monday"
  }

  timeouts = {
    create = "30m"
    delete = "30m"
  }
}
```

## Inputs

| Name                | Description                                                                                  | Type           | Required |
| ------------------- | -------------------------------------------------------------------------------------------- | -------------- | -------- |
| `cluster_name`      | Display name of the PostgreSQL cluster. Configuration changes force a new cluster.           | `string`       | Yes      |
| `postgres_version`  | PostgreSQL major version, for example `17` or `18`.                                          | `string`       | Yes      |
| `database_name`     | Name of the initial database.                                                                | `string`       | Yes      |
| `postgres_username` | PostgreSQL admin username.                                                                   | `string`       | Yes      |
| `password`          | PostgreSQL admin password. The API does not return this value.                               | `string`       | Yes      |
| `compute_size`      | PostgreSQL compute flavor name.                                                              | `string`       | Yes      |
| `storage_size`      | Data volume size in GB. Minimum 200 GB.                                                      | `number`       | Yes      |
| `availability_zone` | Availability zone code, for example `S1`.                                                    | `string`       | Yes      |
| `vpc`               | VPC name used to resolve the subnet.                                                          | `string`       | No*      |
| `subnet`            | Subnet name within the VPC.                                                                   | `string`       | No*      |
| `custom_cidr`       | Custom CIDRs allowed to connect.                                                              | `list(string)` | No*      |
| `description`       | Cluster description.                                                                         | `string`       | No       |
| `high_availability` | Enables primary-standby high availability. Defaults to `false`.                              | `bool`         | No       |
| `num_replicas`      | Number of standby replicas. Defaults to `0`. Must be 1–10 when high availability is enabled. | `number`       | No       |
| `is_superuser`      | Whether the PostgreSQL admin user is a superuser. Defaults to `false`.                       | `bool`         | No       |
| `network_type`      | Network type. Defaults to `private`.                                                         | `string`       | No       |
| `storage_type`      | Storage class. Defaults to `High Performance`.                                               | `string`       | No       |
| `pg_extensions`     | PostgreSQL extensions to enable, for example `pgvector`.                                     | `list(string)` | No       |
| `labels`            | Labels to assign to the cluster.                                                             | `list(string)` | No       |
| `backup`            | Backup configuration.                                                                        | `object`       | No       |
| `timeouts`          | Create and delete operation timeouts. Defaults to 30 minutes.                                | `object`       | No       |

### Network Access

Set `custom_cidr`, or set both `vpc` and `subnet`. Both forms can be used together:

```hcl
vpc         = "copper-vpc1"
subnet      = "temporal-subnet"
custom_cidr = ["192.168.1.0/24"]
```

`vpc` and `subnet` must be set together. The provider resolves the subnet's IPv4 address space and adds it to the allowed IPs.

### Backup

When backup is enabled, `schedule_time` and `schedule_day` are required:

```hcl
backup = {
  enabled           = true
  protection_plan   = "weekly-full-daily-incr"
  compression_level = 6
  retention         = 15
  schedule_time     = "02:00"
  schedule_day      = "Monday"
}
```

* `enabled` - Whether backup is enabled. Defaults to `false`.
* `protection_plan` - Protection plan value.
* `compression_level` - Backup compression level. Defaults to `6`.
* `retention` - Backup retention period in days. Defaults to `15`.
* `schedule_time` - Backup schedule in `HH:MM` format. Required when backup is enabled.
* `schedule_day` - Backup schedule day from `Monday` through `Sunday`. Required when backup is enabled.

### Timeouts

Create and delete timeouts can be configured using:

```hcl
timeouts = {
  create = "30m"
  delete = "30m"
}
```

The default timeout is 30 minutes.

## Outputs

| Name                   | Description                                               |
| ---------------------- | --------------------------------------------------------- |
| `id`                   | PostgreSQL cluster UUID.                                  |
| `cluster_name`         | Configured cluster name.                                  |
| `version`              | PostgreSQL major version.                                 |
| `database_name`        | Initial database name.                                    |
| `postgres_username`    | PostgreSQL admin username.                                |
| `status`               | Current cluster status.                                   |
| `topology`             | Resolved topology: `standalone` or `primary-standby`.     |
| `num_replicas`         | Standby replica count.                                    |
| `availability_zone`    | Availability zone.                                        |
| `created_at`            | Cluster creation timestamp.                               |
| `connection_string`    | PostgreSQL connection string. The API masks the password. |
| `backup_schedule_time` | Configured backup schedule time.                          |
| `backup_schedule_day`  | Configured backup schedule day.                           |
| `postgres`             | Complete/selected PostgreSQL cluster attributes.          |

## High Availability

High availability can be enabled using:

```hcl
high_availability = true
num_replicas      = 1
```

When `high_availability` is enabled:

* `num_replicas` is required.
* `num_replicas` must be between `1` and `10`.
* The resulting topology is `primary-standby`.

For standalone clusters:

```hcl
high_availability = false
num_replicas      = 0
```

## Important Notes

* Changing PostgreSQL cluster configuration forces a new cluster.
* `storage_size` must be at least 200 GB.
* The PostgreSQL password is not returned by the API and is stored by Terraform in state.
* When `high_availability` is enabled, `num_replicas` must be between `1` and `10`.
* When `backup.enabled` is `true`, `schedule_time` and `schedule_day` are required.
* `schedule_time` must use `HH:MM` format.
* `schedule_day` must be one of `Monday` through `Sunday`.
* The `connection_string` is empty until the cluster becomes `Active`.
* The API masks the password in the returned connection string.
* The provider resolves `compute_size`, `storage_type`, and `protection_plan` using the corresponding Airtel Cloud catalogs.

## Import

Existing PostgreSQL clusters can be imported using the cluster UUID:

```shell
terraform import module.postgres.airtelcloud_postgres.this <cluster-uuid>
```

The admin password cannot be populated during import because the API does not return the password. It must be configured separately after importing the resource.

## Provider Resource

This module provisions the Airtel Cloud `airtelcloud_postgres` resource.
