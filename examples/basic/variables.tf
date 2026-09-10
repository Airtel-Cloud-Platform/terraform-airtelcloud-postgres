variable "airtel_api_key" {
  description = "Airtel Cloud API key."
  type        = string
  sensitive   = true
}

variable "airtel_api_secret" {
  description = "Airtel Cloud API secret."
  type        = string
  sensitive   = true
}

variable "organization" {
  description = "Airtel Cloud organization."
  type        = string
}

variable "project_name" {
  description = "Airtel Cloud project name."
  type        = string
}

variable "postgres_password" {
  description = "Admin password for the PostgreSQL cluster."
  type        = string
  sensitive   = true
}
