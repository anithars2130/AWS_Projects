# ==============================
# Variables
# ==============================
variable "web_ami" {
  description = "AMI ID for web servers"
  type        = string
}

variable "web_instance_type" {
  description = "Instance type for web servers"
  default     = "t3.micro"
}

variable "key_name" {
  description = "Key pair name for EC2 instances"
  type        = string
}

variable "db_username" {
  description = "RDS master username"
  type        = string
}

variable "db_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
}