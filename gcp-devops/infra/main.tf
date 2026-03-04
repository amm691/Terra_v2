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
  name     = "primary-pool"
  cluster  = google_container_cluster.gke.name
  location = var.region

  # CHANGED: Reduced to 2 nodes to fit within CPU quota
  node_count = 2

  node_config {
    # CHANGED: Switched to e2-medium (2 vCPU, 4GB RAM)
    machine_type = "e2-medium"

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    shielded_instance_config {
      enable_secure_boot = true
    }
  }
}
