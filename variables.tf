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

variable "credentials" {
  description = "My Credentials"
  default     = "./keys/semar-gcp.json"
}

variable "project_id" {
  description = "Project"
  default     = "semar-de-project1"
}

variable "region" {
  description = "Region"
  default     = "asia-southeast2"
}

variable "zone" {
  description = "Zone"
  default     = "asia-southeast2-c"
}

variable "location" {
  description = "Project Location"
  default     = "asia-southeast2"
}

