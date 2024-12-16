# Discover tags from the project from the list we provide as module input.
# ------------------------------------------------------------------------
locals {
  # The following variable is used to flatten the tags map, so don't edit it directly.
  tag_values_to_be_discovered = {
    for item in flatten([
      for tag_key, tag_values in var.tags_to_be_discovered : [
        for tag_value in tag_values : {
          tag_key_shortname   = tag_key
          tag_value_shortname = tag_value
        }
      ]
    ]) : "${item.tag_key_shortname}--${item.tag_value_shortname}" => item
  }
}

data "google_tags_tag_key" "project_tag_keys_to_discover" {
  for_each = toset([
    for tag_key, tag_values in var.tags_to_be_discovered : tag_key
  ])
  parent     = "projects/${var.project_id}"
  short_name = each.value
}

data "google_tags_tag_value" "project_tag_values_to_be_discovered" {
  for_each   = local.tag_values_to_be_discovered
  parent     = data.google_tags_tag_key.project_tag_keys_to_discover[each.value.tag_key_shortname].id
  short_name = each.value.tag_value_shortname
}

data "google_project" "project" {
  project_id = var.project_id
}

# ---------------------------------
# Binding Google Tags to resources
# ---------------------------------
locals {
  unique_tags_in_buckets = distinct(flatten([
    for bucket in var.buckets_to_be_tagged : bucket.tags
  ]))
  unique_tags_in_cloudsql_instances = distinct(flatten([
    for cloudsql in var.cloudsql_instances_to_be_tagged : cloudsql.tags
  ]))
  unique_tags_in_artifact_registry_repositories = distinct(flatten([
    for repository in var.artifact_registry_repositories_to_be_tagged : repository.tags
  ]))
  all_used_unique_tags = distinct(concat(local.unique_tags_in_buckets, local.unique_tags_in_cloudsql_instances, local.unique_tags_in_artifact_registry_repositories, var.global_tags))

  # Add the global tags to the buckets we want to tag and populate bucket location.
  buckets_to_be_tagged = [
    for bucket in var.buckets_to_be_tagged : {
      bucket_name     = bucket.bucket_name
      bucket_location = bucket.bucket_location != null ? bucket.bucket_location : var.default_location
      # If the bucket has no tags, we add the global tags, otherwise we use the bucket tags.
      tags = length(bucket.tags) > 0 ? bucket.tags : var.global_tags
    }
  ]

  # The map structure is something like:
  # {
  #   "bucket_name--tag_friendly_name" = {
  #     bucket_name       = "bucket_name"
  #     bucket_location   = "bucket_location"
  #     tag_friendly_name = "tag_friendly_name"
  #   },
  #   "bucket_name--tag2_friendly_name" = {
  # ...
  # }
  map_of_buckets_to_be_tagged = {
    for obj in flatten([
      for item in local.buckets_to_be_tagged : [
        for tag in item.tags : {
          bucket_name       = item.bucket_name
          bucket_location   = item.bucket_location
          tag_friendly_name = tag
        }
      ]
    ]) : "${obj.bucket_name}--${obj.tag_friendly_name}" => obj
  }

  # Add the global tags to the CloudSQL instances we want to tag.
  cloudsql_instances_to_be_tagged = [
    for cloussql_instance in var.cloudsql_instances_to_be_tagged : {
      instance_id       = cloussql_instance.instance_id
      instance_location = cloussql_instance.instance_location != null ? cloussql_instance.instance_location : var.default_location
      tags              = length(cloussql_instance.tags) > 0 ? cloussql_instance.tags : var.global_tags
    }
  ]

  map_of_cloudsql_instances_to_be_tagged = {
    for obj in flatten([
      for item in local.cloudsql_instances_to_be_tagged : [
        for tag in item.tags : {
          instance_id       = item.instance_id
          instance_location = item.instance_location
          tag_friendly_name = tag
        }
      ]
    ]) : "${obj.instance_id}--${obj.tag_friendly_name}" => obj
  }

  # Add the global tags to the Artifact Registry repository we want to tag.
  artifact_registry_repositories_to_be_tagged = [
    for repository in var.artifact_registry_repositories_to_be_tagged : {
      repository_id       = repository.repository_id
      repository_location = repository.repository_location != null ? repository.repository_location : var.default_location
      tags                = length(repository.tags) > 0 ? repository.tags : var.global_tags
    }
  ]

  map_of_artifact_registry_repositories_to_be_tagged = {
    for obj in flatten([
      for item in local.artifact_registry_repositories_to_be_tagged : [
        for tag in item.tags : {
          repository_id       = item.repository_id
          repository_location = item.repository_location
          tag_friendly_name   = tag
        }
      ]
    ]) : "${obj.repository_id}--${obj.tag_friendly_name}" => obj
  }
}

# Retrieve the tag keys for the tags that we are passing to the resources.
# We split the friendly name we are passing to the module, to get the tag key shortname
# as the index 0, and the tag value shortname as the index 1.
# The friendly name is in the form <TAG_KEY_SHORTNAME>/<TAG_VALUE_SHORTNAME>
data "google_tags_tag_key" "tag_keys" {
  for_each   = toset(local.all_used_unique_tags)
  parent     = "projects/${var.project_id}"
  short_name = split("/", each.value)[0]
}

# To bind a tag to a resource, we need to know the tag value ID (something as
# "tagValues/281483307043046"), that we can retrieve from this data source.
data "google_tags_tag_value" "tag_values" {
  for_each   = toset(local.all_used_unique_tags)
  parent     = data.google_tags_tag_key.tag_keys[each.value].id
  short_name = split("/", each.value)[1]
}

# Buckets need a location tag binding.
resource "google_tags_location_tag_binding" "buckets" {
  for_each = local.map_of_buckets_to_be_tagged
  # Parent full resource name reference: https://cloud.google.com/iam/docs/full-resource-names
  parent    = "//storage.googleapis.com/projects/_/buckets/${each.value.bucket_name}"
  location  = each.value.bucket_location
  tag_value = data.google_tags_tag_value.tag_values[each.value.tag_friendly_name].id
}

# For a CloudSQL instance, even if regional, we can use a normal tag binding,
# without the need to specify location.
resource "google_tags_location_tag_binding" "cloudsql" {
  for_each = local.map_of_cloudsql_instances_to_be_tagged
  # Parent full resource name reference: https://cloud.google.com/iam/docs/full-resource-names
  parent    = "//sqladmin.googleapis.com/projects/${var.project_id}/instances/${each.value.instance_id}"
  location  = each.value.instance_location
  tag_value = data.google_tags_tag_value.tag_values[each.value.tag_friendly_name].id
}

# Tag bindings for Artifact Registry repositories.
resource "google_tags_location_tag_binding" "artifact_registry" {
  for_each = local.map_of_artifact_registry_repositories_to_be_tagged
  # Parent full resource name reference: https://cloud.google.com/artifact-registry/docs/repositories/tag-repos#attach
  # For the Artifact Registry, the parent needs to be in the form:
  # //artifactregistry.googleapis.com/projects/PROJECT_NUMBER/locations/LOCATION/repositories/REPOSITORY_ID
  parent    = "//artifactregistry.googleapis.com/projects/${data.google_project.project.number}/locations/${each.value.repository_location}/repositories/${each.value.repository_id}"
  location  = each.value.repository_location
  tag_value = data.google_tags_tag_value.tag_values[each.value.tag_friendly_name].id
}
