variable "project_id" {
  type        = string
  description = "The Google Cloud project ID."
}

variable "default_location" {
  description = "The default location (region) used for the resources to be tagged."
  type        = string
}

variable "tags_to_be_discovered" {
  description = "The map with the tags we want to discover with a full structure key / values, see the README.md for an example. The module will print the tag informations as output."
  type        = map(list(string))
  default     = {}
}

variable "global_tags" {
  description = "A list of tags to be applied to all the resources, in the form tag_key_short_name/tag_value_short_name. If a resource specify a list of tags, the global tags will overridden and replaced by those specified in the resource."
  type        = list(string)
  default     = []
}

variable "buckets_to_be_tagged" {
  description = "A structured list of objects, containing the list of buckets we want to tag and the tag values, in the form `<TAG_KEY_SHORTNAME>/<TAG_VALUE_SHORTNAME>`. If no bucket_location is specified, the value of default_location will be used."
  type = list(object({
    bucket_name     = string
    bucket_location = optional(string, null)
    tags            = optional(list(string), [])
  }))
  default = []
}

variable "cloudsql_instances_to_be_tagged" {
  description = "A structured list of objects, containing the list of cloudSQL instances we want to tag, with instance name, instance location (region) and tag values."
  type = list(object({
    instance_id       = string
    instance_location = optional(string, null)
    tags              = optional(list(string), [])
  }))
  default = []
}

variable "artifact_registry_repositories_to_be_tagged" {
  description = "A structured list of objects, containing the list of repositories we want to tag, with repository id, repository location (region) and tag values."
  type = list(object({
    repository_id       = string
    repository_location = optional(string, null)
    tags                = optional(list(string), [])
  }))
  default = []
}
