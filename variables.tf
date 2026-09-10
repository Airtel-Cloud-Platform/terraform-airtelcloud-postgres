#########################################
# Identity
#########################################

variable "cluster_name" {
  description = "Display name of the PostgreSQL cluster. Forces a new resource."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.cluster_name))
    error_message = "cluster_name must contain only lowercase letters, digits, and hyphens."
  }
}

variable "description" {
  description = "Cluster description. Forces a new resource."
  type        = string
  default     = "Managed by Terraform"
}

variable "postgres_version" {
  description = "PostgreSQL major version (for example 17 or 18). Forces a new resource."
  type        = string

  validation {
    condition     = length(trim(var.postgres_version, " ")) > 0
    error_message = "postgres_version cannot be empty."
  }
}

#########################################
# Database credentials
#########################################

variable "database_name" {
  description = "Name of the initial database. Forces a new resource."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z][A-Za-z0-9_]*$", var.database_name))
    error_message = "database_name must start with a letter and contain only letters, digits, and underscore."
  }
}

variable "postgres_username" {
  description = "Admin username for the cluster. Forces a new resource."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z][A-Za-z0-9_]*$", var.postgres_username))
    error_message = "postgres_username must start with a letter and contain only letters, digits, and underscore."
  }
}

variable "password" {
  description = "Admin password. Stored in Terraform state; the API does not return it. Forces a new resource."
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.password) >= 8 && length(var.password) <= 128
    error_message = "password must be between 8 and 128 characters."
  }

  validation {
    condition     = !strcontains(var.password, "@") && !strcontains(var.password, "_")
    error_message = "password cannot contain '@' or '_'."
  }

  validation {
    condition = (
      can(regex("[A-Z]", var.password)) &&
      can(regex("[a-z]", var.password)) &&
      can(regex("[0-9]", var.password)) &&
      can(regex("[^A-Za-z0-9]", var.password))
    )
    error_message = "password must contain uppercase, lowercase, digit, and special characters."
  }
}

variable "is_superuser" {
  description = "Whether the admin user is a superuser. Defaults to false. Forces a new resource."
  type        = bool
  default     = false
}

#########################################
# Sizing and placement
#########################################

variable "compute_size" {
  description = "Flavor name from the postgres flavors catalog (for example db.postgres.uhper.ccs.xlarge). Forces a new resource."
  type        = string

  validation {
    condition     = length(trim(var.compute_size, " ")) > 0
    error_message = "compute_size cannot be empty."
  }
}

variable "storage_size" {
  description = "Data volume size in GB. Must be at least 200. Forces a new resource."
  type        = number

  validation {
    condition     = var.storage_size >= 200
    error_message = "storage_size must be at least 200 GB."
  }
}

variable "storage_type" {
  description = "Storage class label from the volume-types catalog. Defaults to High Performance. Forces a new resource."
  type        = string
  default     = "High Performance"
}

variable "availability_zone" {
  description = "Availability zone code (for example S1). Forces a new resource."
  type        = string

  validation {
    condition     = length(trim(var.availability_zone, " ")) > 0
    error_message = "availability_zone cannot be empty."
  }
}

variable "network_type" {
  description = "Network type for the cluster. Defaults to private. Forces a new resource."
  type        = string
  default     = "private"
}

#########################################
# High availability
#########################################

variable "high_availability" {
  description = "When true, creates primary-standby topology. Defaults to false. Forces a new resource."
  type        = bool
  default     = false
}

variable "num_replicas" {
  description = "Standby replica count. Required and must be between 1 and 10 when high_availability is true. Defaults to 0. Forces a new resource."
  type        = number
  default     = 0

  validation {
    condition     = var.num_replicas >= 0 && var.num_replicas <= 10
    error_message = "num_replicas must be between 0 and 10."
  }

  validation {
    condition     = !var.high_availability || (var.num_replicas >= 1 && var.num_replicas <= 10)
    error_message = "num_replicas is required when high_availability is true and must be between 1 and 10."
  }
}

#########################################
# Optional extras
#########################################

variable "pg_extensions" {
  description = "PostgreSQL extensions to enable (for example pgvector). Forces a new resource."
  type        = list(string)
  default     = null
}

variable "labels" {
  description = "Labels to assign to the cluster. Forces a new resource."
  type        = list(string)
  default     = null
}

variable "security_group" {
  description = "Allowed client CIDRs. Forces a new resource."

  type = object({
    allowed_ips = list(string)
  })

  validation {
    condition     = length(var.security_group.allowed_ips) > 0
    error_message = "security_group.allowed_ips must contain at least one CIDR."
  }

  validation {
    condition = alltrue([
      for ip in var.security_group.allowed_ips : length(trim(ip, " ")) > 0
    ])
    error_message = "security_group.allowed_ips cannot contain empty values."
  }
}

variable "backup" {
  description = "Backup configuration. Forces a new resource. Set to null to omit."

  type = object({
    enabled           = optional(bool, false)
    protection_plan   = optional(string)
    compression_level = optional(number, 6)
    retention         = optional(number, 15)
    schedule_time     = optional(string)
    schedule_day      = optional(string)
  })

  default = null

  validation {
    condition = (
      var.backup == null ||
      !try(var.backup.enabled, false) ||
      (
        try(var.backup.schedule_time, null) != null &&
        try(var.backup.schedule_day, null) != null
      )
    )
    error_message = "schedule_time and schedule_day are required when backup.enabled is true."
  }

  validation {
    condition = (
      var.backup == null ||
      try(var.backup.schedule_time, null) == null ||
      can(regex("^([01]\\d|2[0-3]):([0-5]\\d)$", var.backup.schedule_time))
    )
    error_message = "backup.schedule_time must be in HH:MM format."
  }

  validation {
    condition = (
      var.backup == null ||
      try(var.backup.schedule_day, null) == null ||
      contains(
        ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"],
        var.backup.schedule_day
      )
    )
    error_message = "backup.schedule_day must be Monday through Sunday."
  }
}

variable "timeouts" {
  description = "Create and delete timeouts for the PostgreSQL cluster."

  type = object({
    create = optional(string)
    delete = optional(string)
  })

  default = null
}
