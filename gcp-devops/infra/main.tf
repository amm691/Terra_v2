#main.................
resource "google_container_cluster" "gke" {
    name = "prod-gke"
    location = var.region

    remove_default_node_pool = true
    initial_node_count = 1

    workload_identity_config {
        workload_pool = "${var.project_id}.svc.id.goog"
    }
    deletion_protection = false
}

#resource....................
resource "google_container_node_pool" "nodes" {
    name = "primary-pool" 
    cluster = google_container_cluster.gke.name
    location = var.region 

    node_config {
        machine_type = "e2-standard-4"
        oauth_scopes = ["https://www.googleapi.com/auth/cloud-platform"]
        shielded_instance_config {
            enable_secure_boot = true
        }
    }
    initial_node_count = 3
}