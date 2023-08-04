output "discovered_tag_keys" {
  value = data.google_tags_tag_key.project_tag_keys_to_discover
}

output "discovered_tag_keys_ids" {
  value = { for tag_key, tag_values in var.tags_to_be_discovered : tag_key => data.google_tags_tag_key.project_tag_keys_to_discover[tag_key].id }
}

output "discovered_tag_keys_names" {
  value = { for tag_key, tag_values in var.tags_to_be_discovered : tag_key => data.google_tags_tag_key.project_tag_keys_to_discover[tag_key].name }
}

output "discovered_tag_values" {
  value = data.google_tags_tag_value.project_tag_values_to_be_discovered
}

output "discovered_tag_values_ids" {
  value = {
    for item in flatten([
      for tag_key, tag_values in var.tags_to_be_discovered : [
        for tag_value in tag_values : {
          tag_key   = tag_key
          tag_value = tag_value
        }
      ]
    ]) : "${item.tag_key}/${item.tag_value}" => data.google_tags_tag_value.project_tag_values_to_be_discovered["${item.tag_key}--${item.tag_value}"].id
  }
}
