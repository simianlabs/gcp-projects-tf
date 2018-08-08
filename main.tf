provider "google" {
  region  = "us-central1"
  project = "st2-tf"
}

resource "random_id" "trainee" {
  count       = "${length(var.trainees)}"
  byte_length = "4"
}

resource "google_project" "trainee" {
  count           = "${length(var.trainees)}"
  name            = "trainee-${element(random_id.trainee.*.hex, count.index)}-posam-dsi"
  project_id      = "trainee-${element(random_id.trainee.*.hex, count.index)}-posam-dsi"
  billing_account = "${var.billing_id}"
  org_id          = "${var.org_id}"
}

data "google_iam_policy" "trainee" {
  count = "${length(var.trainees)}"

  binding = {
    role = "roles/owner"

    members = [
      "user:admin@mycompany.io",
    ]
  }

  binding = {
    role = "roles/editor"

    members = [
      "user:${element(var.trainees, count.index)}",
    ]
  }
}

resource "google_project_iam_policy" "trainee" {
  count       = "${length(var.trainees)}"
  project     = "${element(google_project.trainee.*.project_id, count.index)}"
  policy_data = "${element(data.google_iam_policy.trainee.*.policy_data, count.index)}"
}

resource "google_project_services" "trainee" {
  count   = "${length(var.trainees)}"
  project = "${element(google_project.trainee.*.project_id, count.index)}"

  services = [
    "container.googleapis.com",
  ]
}

output "project_id" {
  value = "${google_project.trainee.*.project_id}"
}
