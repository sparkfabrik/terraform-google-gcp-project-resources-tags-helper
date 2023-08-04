locals {
  tags_to_discover = {
    "dev-team" : [
      "viewer",
      "editor",
      "admin"
    ],
    "external-team" : [
      "viewer",
      "editor",
      "admin"
    ]
  }

  buckets_to_tag = [
    {
      bucket_name = "my-website"
    },
    {
      bucket_name = "my-website-stage"
    },
    {
      bucket_name = "external-website"
      # Here we override the global tags.
      tags        = [
        "dev-team/editor", "external-team/editor"
      ]
    },
  ]
}

# ------------------------------
module "project_resources_tags" {
  source                = "../."
  default_location      = "europe-west1"
  project_id            = "my-project-id"
  tags_to_be_discovered = local.tags_to_discover
  buckets_to_be_tagged  = local.buckets_to_tag
  global_tags           = [
    "dev-team/editor", "external-team/viewer"
  ]
}
