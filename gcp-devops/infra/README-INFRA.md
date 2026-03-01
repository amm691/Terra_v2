
5th Commit............

What Happens AFTER PHASE-1 (INFRA CODE READY)

You already have this structure 👇

gcp-devops/
│
├── infra/
│   ├── terraform/
│   │   ├── backend.tf
│   │   ├── provider.tf
│   │   ├── main.tf
│   │   └── variables.tf
│   └── cloudbuild.yaml        # Infra CI/CD (approval based)
│
├── apps/
│   ├── app1/
│   │   ├── Dockerfile
│   │   └── deployment.yaml
│   ├── app2/
│   ├── app3/
│   └── cloudbuild.yaml        # App CI/CD
│
└── README.md

Now let’s connect GitHub → Cloud Build → Terraform.

✅ STEP 1: Push Code to GitHub
1️⃣ Create a GitHub repository

Repo name: gcp-devops

Visibility: private (recommended)

2️⃣ Push your local code
git init
git add .
git commit -m "Initial infra setup with Terraform"
git branch -M main
git remote add origin https://github.com/<org>/gcp-devops.git
git push -u origin main

👉 GitHub is now your single source of truth.

✅ STEP 2: Prepare GCP Project (ONE-TIME)
1️⃣ Enable required APIs
gcloud services enable \
  cloudbuild.googleapis.com \
  container.googleapis.com \
  iam.googleapis.com \
  compute.googleapis.com
2️⃣ Grant permissions to Cloud Build Service Account

Cloud Build uses this SA:

PROJECT_NUMBER@cloudbuild.gserviceaccount.com

Grant minimum required roles:

gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="serviceAccount:PROJECT_NUMBER@cloudbuild.gserviceaccount.com" \
  --role="roles/container.admin"

gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="serviceAccount:PROJECT_NUMBER@cloudbuild.gserviceaccount.com" \
  --role="roles/compute.networkAdmin"

gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="serviceAccount:PROJECT_NUMBER@cloudbuild.gserviceaccount.com" \
  --role="roles/storage.admin"

⚠️ Do NOT give Owner/Editor (important interview point).

✅ STEP 3: Create GCS Bucket for Terraform State
gsutil mb gs://terraform-state-prod
gsutil versioning set on gs://terraform-state-prod

This matches:

bucket  = "terraform-state-prod"
prefix = "gke/infra"
✅ STEP 4: Connect GitHub to Cloud Build
In GCP Console:

Go to Cloud Build → Triggers

Click Connect Repository

Choose GitHub

Authenticate & select repo gcp-devops

Connection type: GitHub App (recommended)

✅ Now GCP can read your repo.

✅ STEP 5: Create CI Trigger (PLAN on PR)
Trigger details:

Name: infra-ci-plan

Event: Pull Request

Branch: ^.*$

Build config: infra/cloudbuild.yaml

Approval: ❌ No (CI only)

What happens:
PR opened → terraform fmt → validate → plan

❌ No apply
✅ Safe review

✅ STEP 6: Create CD Trigger (APPLY with Approval)
Trigger details:

Name: infra-cd-apply

Event: Push to branch

Branch: ^main$

Build config: infra/cloudbuild.yaml

✅ Enable “Require approval before build executes”

What happens:
Merge to main
→ Cloud Build waits for approval
→ terraform apply

🔥 This is production-grade control.

✅ STEP 7: Day-to-Day Workflow (REAL LIFE)
🔁 Infra Change Flow
Feature branch
→ PR created
→ CI trigger runs (plan)
→ Review Terraform plan
→ PR approved
→ Merge to main
→ Manual approval in Cloud Build
→ terraform apply
✅ STEP 8: Verify Cluster Creation

After approval:

gcloud container clusters get-credentials prod-gke \
  --region us-central1 \
  --project PROJECT_ID

kubectl get nodes

✅ Cluster is ready
👉 PHASE-1 DONE

🎤 Interview-Ready Explanation (IMPORTANT)

Infrastructure is managed using Terraform with a GCS backend. GitHub is integrated with Cloud Build using triggers. Pull requests run Terraform plan for review, and merges to the main branch require manual approval before applying changes. This ensures controlled and auditable infrastructure provisioning.