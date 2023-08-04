output "tag_keys" {
  value = module.project_resources_tags.discovered_tag_keys
}

output "tag_values" {
  value = module.project_resources_tags.discovered_tag_values
}
