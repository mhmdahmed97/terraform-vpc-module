variable "create_vpc" {
  description = "Controls if VPC should be created"
  type        = bool
  default     = true
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  #default     = "10.0.0.0/16"
}

variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Should be true to enable dns support in the VPC"
  type        = bool
  default     = true
}

variable "create_internet_gateway" {
  description = "Controls if Internet gateway should be created"
  type        = bool
  default     = true
}
variable "public_subnet_cidr_blocks" {
  description = "(Optional) List of CIDR blocks for public subnets"
  type        = list(string)
  #default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "availability_zones" {
  type    = list(string)
  #default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "map_public_ip_on_launch" {
  description = "Controls if EC2 instances launched into this subnet should have a public IP addr by default"
  type        = bool
  default     = true
}

variable "public_route_destination" {
  description = "(Optional) Can be provided in case a specific route is needed for internet-bound traffic"
  type        = string
  default     = "0.0.0.0/0"
}

variable "private_route_destination" {
  description = "(Optional) Can be provided in case a specific route is needed"
  type        = string
  #default     = "0.0.0.0/0"
}

variable "private_subnet_cidr_blocks" {
  description = "(Optional) List of CIDR blocks for private subnets"
  type        = list(string)
  #default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "tags" {
  description = "Tags to apply to AWS resources"
  type        = map(string)
}
