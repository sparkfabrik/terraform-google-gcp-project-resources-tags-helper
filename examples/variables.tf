variable "project_id" {
  type        = string
  description = "The Google Cloud project ID."
}

variable "default_location" {
  description = "The default location (region) used for the resources to be tagged."
  type        = string
}

variable "global_tags" {
  description = "A list of tags to be applied to all the resources, in the form tag_key_short_name/tag_value_short_name. If a resource specify a list of tags, the global tags will overridden and replaced by those specified in the resource."
  type        = list(string)
  default     = []
}
