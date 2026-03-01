#provider...............
provider "google" {
    credentials = "creds/sa.json"
    project = var.project_id
    region = var.region
}
