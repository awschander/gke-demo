output "artifact_registry_url" {
  description = "Docker image base URL"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/demo-app/demo-app"
}

output "gke_cluster_name" {
  description = "GKE cluster name"
  value       = google_container_cluster.primary.name
}

output "gke_get_credentials_cmd" {
  description = "Command to configure kubectl"
  value       = "gcloud container clusters get-credentials ${var.cluster_name} --region ${var.region} --project ${var.project_id}"
}