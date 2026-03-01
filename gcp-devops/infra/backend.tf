#backend.........
terraform {
    backend "gcs" {
        bucket = "terraform-state-prod_v1"
        credentials = "creds/sa.json"
        prefix = "gke/infra"
    }   
}


