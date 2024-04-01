variable "credentials" {
  description = "My Credentials"
  default     = "./keys/<your_json_key>"
}

variable "project_id" {
  description = "Project"
  default     = "<your_project_id>"
}

variable "region" {
  description = "Region"
  default     = "<your_region>"
}

variable "zone" {
  description = "Zone"
  default     = "<your_zone>"
}

variable "dataproc_master_machine_type" {
  type        = string
  description = "dataproc master node machine tyoe"
  default     = "n2-standard-2"
}

variable "dataproc_worker_machine_type" {
  type        = string
  description = "dataproc worker nodes machine type"
  default     = "n1-standard-2"
}

variable "dataproc_workers_count" {
  type        = number
  description = "count of worker nodes in cluster"
  default     = 2
}
variable "dataproc_master_bootdisk" {
  type        = number
  description = "primary disk attached to master node, specified in GB"
  default     = 30
}

variable "dataproc_worker_bootdisk" {
  type        = number
  description = "primary disk attached to master node, specified in GB"
  default     = 30
}

variable "worker_local_ssd" {
  type        = number
  description = "primary disk attached to master node, specified in GB"
  default     = 0
}

variable "preemptible_worker" {
  type        = number
  description = "number of preemptible nodes to create"
  default     = 0
}

variable "subnet_name" {
  description = "Network Subnet"
  default     = "myvpcsub"
}

variable "prefix" {
  description = "Prefix Name for Bucket"
  default     = "project1"
}
