variable "location" {
  type    = string
  default = "UK South"
}

variable "admin_password" {
  type      = string
  sensitive = true
}