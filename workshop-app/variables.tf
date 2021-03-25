// ??? whole file
variable "instance_type" {
  description = "instance type for workshop-app instances"
  default     = "t2.micro"
}

variable "ami" {
  description = "ami id for workshop-app instances"
  default     = "ami-08962a4068733a2b6"
}

variable "role" {
  default = "workshop-app-wrapper"
}

variable "cluster_name" {
  default = "workshop-terraform"
}

variable "workshop-app_cluster_size_min" {
  default     = 2
  description = "Minimum of running instances"

}

variable "workshop-app_cluster_size_max" {
  default     = 5
  description = "Maximum of running instances"

}

variable "additional_sgs" {
  default = ""
}

variable "terraform_bucket" {
  default     = "danishemeshterraform"
  description = <<EOS
S3 bucket with the remote state of the site module.
The site module is a required dependency of this module
EOS

}

variable "site_module_state_path" {
  default     = "workshop-site-state/terraform.tfstate"
  description = <<EOS
S3 path to the remote state of the site module.
The site module is a required dependency of this module
EOS

}

variable "workshop-app" {
}
