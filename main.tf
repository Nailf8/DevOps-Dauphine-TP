resource "google_project_service" "ressource_manager" {
    service = "cloudresourcemanager.googleapis.com"
}

resource "google_project_service" "ressource_usage" {
    service = "serviceusage.googleapis.com"
    depends_on = [ google_project_service.ressource_manager ]
}

resource "google_project_service" "artifact" {
    service = "artifactregistry.googleapis.com"
    depends_on = [ google_project_service.ressource_manager ]
}


resource "google_project_service" "sqladmin" {
    service = "sqladmin.googleapis.com"
}

resource "google_project_service" "cloudbuild" {
    service = "cloudbuild.googleapis.com"
}

resource "google_artifact_registry_repository" "my-repo" {
  location      = "us-central1"
  repository_id = "website-tools"
  description   = "Exemple de repo Docker"
  format        = "DOCKER"

  depends_on = [ google_project_service.artifact ]
}

resource "google_sql_database" "database" {
  name     = "wordpress"
  instance = "main-instance"
}

resource "google_sql_user" "wordpress" {
   name     = "wordpress"
   instance = "main-instance"
   password = "ilovedevops"
}


resource "google_cloud_run_service" "default" {
name     = "serveur-wordpress"
location = "us-central1"

template {
   spec {
      containers {
      image = "us-central1-docker.pkg.dev/devops-tp4/website-tools/wordpress@sha256:4b78f62ba07fb7f22e7f43bef16db9a1b30e2fa9b2b837f8b638fed64a8ec640"
      }
   }

   metadata {
      annotations = {
      "autoscaling.knative.dev/maxScale"      = "1000"
      "run.googleapis.com/cloudsql-instances" = "devops-tp4:us-central1:main-instance"
      "run.googleapis.com/client-name"        = "terraform"
      }
   }
}

traffic {
   percent         = 100
   latest_revision = true
}
}

data "google_iam_policy" "noauth" {
   binding {
      role = "roles/run.invoker"
      members = [
         "allUsers",
      ]
   }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
   location    = google_cloud_run_service.default.location
   project     = google_cloud_run_service.default.project
   service     = google_cloud_run_service.default.name

   policy_data = data.google_iam_policy.noauth.policy_data
}