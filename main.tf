# Google Provider Versions
terraform {
  required_providers {
    template = {
      source = "hashicorp/template"
      version = "2.2.0"
    }
    google = {
      source = "hashicorp/google"
      version = "5.22.0"
    }
  }
}

provider "template" {
  # Configuration options
}

# Cloud Provider
provider "google" {
  credentials = var.credentials
  project     = var.project_id
  region      = var.region
  zone        = var.zone
}

# Allow SSH from all IPs (insecure, but ok for this tutorial)
resource "google_compute_firewall" "rules" {
  project     = var.project_id
  name        = var.prefix
  network     = "default"
  description = "Creates firewall rule targeting tagged instances"
  
  allow {
    protocol = "icmp"
  }
  
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol  = "tcp"
     ports     = ["80", "8000-9000", "1000-2000", 5432, 6789, 4040, 18081, 18082]
  }
}

resource "google_bigquery_dataset" "default" {
  dataset_id = var.prefix
  location   = var.location
}

resource "google_service_account" "dataproc-svc" {
  project      = var.project_id
  account_id   = "dataproc-svc"
  display_name = "Service Account - dataproc"
}

resource "google_project_iam_member" "svc-access" {
  project = var.project_id
  role    = "roles/dataproc.worker"
  member  = "serviceAccount:${google_service_account.dataproc-svc.email}"
}

resource "google_storage_bucket" "dataproc-bucket" {
  project                     = var.project_id
  name                        = "${var.prefix}-dataproc-config"
  uniform_bucket_level_access = true
  location                    = var.region
  force_destroy = true
  lifecycle {
    prevent_destroy = false
  }
  versioning {
    enabled = true
  }
}

resource "google_storage_bucket_iam_member" "dataproc-member" {
  bucket = google_storage_bucket.dataproc-bucket.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.dataproc-svc.email}"
}

resource "google_dataproc_cluster" "mycluster" {
  name                          = "project1-dataproc"
  region                        = var.region

  cluster_config {
    staging_bucket = google_storage_bucket.dataproc-bucket.name

    master_config {
      num_instances = 1
      machine_type  = var.dataproc_master_machine_type
      disk_config {
        boot_disk_type    = "pd-standard"
        boot_disk_size_gb = var.dataproc_master_bootdisk
      }
    }

    worker_config {    
      num_instances = var.dataproc_workers_count
      machine_type  = var.dataproc_worker_machine_type
      disk_config {
        boot_disk_type    = "pd-standard"
        boot_disk_size_gb = var.dataproc_worker_bootdisk
        # num_local_ssds    = var.worker_local_ssd
      }
    }

    preemptible_worker_config {
      num_instances = var.preemptible_worker
    }

    # Override or set some custom properties
    software_config {
      image_version = "2.2.10-debian12"
      optional_components   = ["DOCKER", "JUPYTER"]
      override_properties = {
        "spark:spark.executor.memory" = "2688m"
        "spark:spark.executor.cores" = "1"
        "spark:spark.logConf" = "true"
        "dataproc:dataproc.allow.zero.workers" = "true"
      } 
    }

    gce_cluster_config {
      zone = "${var.region}-c"
      service_account         = "<your service account>"
      service_account_scopes = ["cloud-platform"]
    }     
  }
}

