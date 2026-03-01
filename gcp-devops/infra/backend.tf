#backend.........
terraform {
    backend "gcs" {
        bucket = "terraform-state-prod_v1"
        credentials = "./creds/serviceaccount.json"
        prefix = "gke/infra"
    }   
}


