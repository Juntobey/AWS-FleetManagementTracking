variable "db_username" {
  description = "Database master username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "fleet_management"
}

variable "active_target_group" {
  description = "Which target group is active (blue or green)"
  type        = string
  default     = "blue"
}
