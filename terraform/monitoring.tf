# ─── Cloud Monitoring ────────────────────────────────────────────────────────

# Notification channel (email)
resource "google_monitoring_notification_channel" "email" {
  display_name = "Demo App Alerts"
  type         = "email"

  labels = {
    email_address = var.alert_email
  }
}

# Uptime check — polls the app's /health endpoint every minute
resource "google_monitoring_uptime_check_config" "app_health" {
  display_name = "demo-app-health"
  timeout      = "10s"
  period       = "60s"

  http_check {
    path         = "/health"
    port         = 80
    use_ssl      = false
    validate_ssl = false
  }

  monitored_resource {
    type = "uptime_url"
    labels = {
      project_id = "kubernetes-gke-practice-488210"
      # TODO: Replace with your LoadBalancer IP after first deploy
      host = "placeholder.example.com"
    }
  }
}

# Alert policy — fires if uptime check fails
resource "google_monitoring_alert_policy" "uptime_failure" {
  display_name = "Demo App Down"
  combiner     = "OR"

  conditions {
    display_name = "Uptime check failed"

    condition_threshold {
      filter          = "metric.type=\"monitoring.googleapis.com/uptime_check/check_passed\" resource.type=\"uptime_url\""
      comparison      = "COMPARISON_LT"
      threshold_value = 1
      duration        = "120s"

      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_FRACTION_TRUE"
        # Fixed: removed cross_series_reducer — not compatible with DOUBLE metric type
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.email.name]

  alert_strategy {
    auto_close = "1800s"
  }
}

# Alert: High pod restart rate
resource "google_monitoring_alert_policy" "pod_restarts" {
  display_name = "Demo App — High Restart Rate"
  combiner     = "OR"

  conditions {
    display_name = "Pod restart count > 5 in 10 min"

    condition_threshold {
      filter          = "metric.type=\"kubernetes.io/container/restart_count\" resource.type=\"k8s_container\" resource.label.cluster_name=\"${var.cluster_name}\""
      comparison      = "COMPARISON_GT"
      threshold_value = 5
      duration        = "600s"

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.email.name]
}