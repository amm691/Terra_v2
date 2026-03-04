# --- GKE Cluster Configuration ---
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

# --- GKE Node Pool Configuration ---
resource "google_container_node_pool" "nodes" {
  name       = "primary-pool"
  cluster    = google_container_cluster.gke.name
  location   = var.region
  node_count = 2

  node_config {
    machine_type = "e2-medium"
    disk_size_gb = 40
    disk_type    = "pd-standard"

    # Using your specific project's default compute service account
    service_account = "648980925301-compute@developer.gserviceaccount.com"

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    shielded_instance_config {
      enable_secure_boot = true
    }
  }
}

# --- Artifact Registry (The Missing Link) ---
resource "google_artifact_registry_repository" "devops_repo" {
  location      = var.region
  repository_id = "devops"
  description   = "Docker repository for microservices"
  format        = "DOCKER"
}

# --- IAM Permissions ---
# This allows the GKE nodes to pull images from the Artifact Registry
resource "google_project_iam_member" "gke_artifact_reader" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:648980925301-compute@developer.gserviceaccount.com"
}
