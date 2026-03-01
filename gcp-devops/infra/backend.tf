#backend.........
terraform {
    backend "gcs" {
        bucket = "terraform-state-prod_v1"
        prefix = "gke/infra"
    }   
}


