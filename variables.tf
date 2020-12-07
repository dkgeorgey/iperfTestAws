variable "name" {
  description = "Name to be used on all resources as prefix"
  type        = string
  default     = "iperf"
}

variable "instance_count" {
  description = "Name to be used on all resources as prefix"
  type        = number
  default     = 2
}

variable "ami" {
  description = "ID of AMI to use for the instance"
  type        = string
  default     = "ami-07fbdcfe29326c4fb"
}

variable "instance_type" {
  description = "The type of instance to start"
  type        = list(string)
  default     = ["t3.micro", "t3.xlarge"]
}

variable "key_name" {
  description = "The key name to use for the instance"
  type        = string
}

variable "associate_public_ip_address" {
  description = "If true, the EC2 instance will have associated public IP address"
  type        = bool
  default     = false
}

variable "user_data_base64" {
  description = "This will pass in the scripts used to customise the instance on startup"
  type        = string
  default     = ""
}


variable "num_suffix_format" {
  description = "Numerical suffix format used as the volume and EC2 instance name suffix"
  type        = string
  default     = "-%d"
}

variable "tags" {
  type        = map(string)
  description = "These tags will be appended to all resources created by terraform"
  default = {
    "project"                  = "iperf-test"
    "instance_class"           = "spot"
    "provisioner"              = "terraform"
  }
}