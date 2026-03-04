# main
resource "google_container_cluster" "gke" {
  name     = "prod-gke"
  location = var.region

  remove_default_node_pool = true
  initial_node_count       = 1

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  deletion_protection = false
}
# node pool
resource "google_container_node_pool" "nodes" {
  name       = "primary-pool"
  cluster    = google_container_cluster.gke.name
  location   = var.region
  node_count = 2

  node_config {
    machine_type = "e2-medium"
    disk_size_gb    = 40      # Add this line
    disk_type       = "pd-standard"   # Use standard disks instead of SSD to save SSD quota

    # FIXED: Using your specific project's default compute service account
    service_account = "648980925301-compute@developer.gserviceaccount.com"

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    shielded_instance_config {
      enable_secure_boot = true
    }
  }
}
