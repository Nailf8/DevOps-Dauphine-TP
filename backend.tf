terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.10"
    }
  }

  backend "gcs" {
    bucket = "nail-bucket"
  }

  required_version = ">= 1.0"
}


provider "google" {
    project = "devops-tp4"
}