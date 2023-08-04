# Helper module to bind tags to Google Cloud Platform resources

A simple module used to retrieve tags data from a GCP project and to assign tags 
(binding) to passed resources. 

Actually the **module supports tagging of storage buckets** and **CloudSQL instances**.

You can pass the tags to the module in a user friendly and easy to read format, 
<TAG_KEY_SHORTNAME>/<TAG_VALUE_SHORTNAME>, so that it will be easy to understand,
for example, you can write tasgs to be applied to resources like:

`dev-team/viewer`
`ops-team/admin`

You can also use the module to retrieve information about some tags, populanting 
the variable `tags_to_be_discovered` with a full tag structure, where the tag key
is the map key, and the tag values are the values of each map key. For example:

```terraform
    tags_to_be_discovered = {
        "dev-team" : [
          "viewer",
          "editor",
          "admin"
        ],
        "ops-team" : [
          "viewer",
          "editor",
          "admin"
        ]
    }
```

In the module output you can retrieve all tags keys and values informations.

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 4.47.0 |
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.47.0 |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_buckets_to_be_tagged"></a> [buckets\_to\_be\_tagged](#input\_buckets\_to\_be\_tagged) | A structured list of objects, containing the list of buckets we want to tag and the tag values, in the form <TAG\_KEY\_SHORTNAME>/<TAG\_VALUE\_SHORTNAME>. If no bucket\_location is specified, the value of default\_location will be used. | <pre>list(object({<br>    bucket_name     = string<br>    tags            = optional(list(string), [])<br>    bucket_location = optional(string, null)<br>  }))</pre> | `[]` | no |
| <a name="input_cloudsql_instances_to_be_tagged"></a> [cloudsql\_instances\_to\_be\_tagged](#input\_cloudsql\_instances\_to\_be\_tagged) | A structured list of objects, containing the list of cloudSQL instances we want to tag, with instance name, and tag values | <pre>list(object({<br>    instance_name = string<br>    tags          = optional(list(string), [])<br>  }))</pre> | `[]` | no |
| <a name="input_default_location"></a> [default\_location](#input\_default\_location) | The default location (region) used for the resources to be tagged. | `string` | n/a | yes |
| <a name="input_global_tags"></a> [global\_tags](#input\_global\_tags) | A list of tags to be applied to all the resources, in the form tag\_key\_short\_name/tag\_value\_short\_name. If a resource specify a list of tags, the global tags will overridden and replaced by those specified in the resource. | `list(string)` | `[]` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The Google Cloud project ID. | `string` | n/a | yes |
| <a name="input_tags_to_be_discovered"></a> [tags\_to\_be\_discovered](#input\_tags\_to\_be\_discovered) | The map with the tags we want to discover with a full structure key / values, for example: { 'tag\_key\_short\_name\_1' = ['tag\_value\_short\_name\_1','tag\_value\_short\_name\_2'], 'tag\_key\_short\_name\_2' = ['tag\_value\_short\_name\_1','tag\_value\_short\_name\_2','tag\_value\_short\_name\_3'] }. The module will print the tag informations as output. | `map(list(string))` | `{}` | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_discovered_tag_keys"></a> [discovered\_tag\_keys](#output\_discovered\_tag\_keys) | n/a |
| <a name="output_discovered_tag_keys_ids"></a> [discovered\_tag\_keys\_ids](#output\_discovered\_tag\_keys\_ids) | n/a |
| <a name="output_discovered_tag_keys_names"></a> [discovered\_tag\_keys\_names](#output\_discovered\_tag\_keys\_names) | n/a |
| <a name="output_discovered_tag_values"></a> [discovered\_tag\_values](#output\_discovered\_tag\_values) | n/a |
| <a name="output_discovered_tag_values_ids"></a> [discovered\_tag\_values\_ids](#output\_discovered\_tag\_values\_ids) | n/a |
## Resources

| Name | Type |
|------|------|
| [google_tags_location_tag_binding.buckets](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/tags_location_tag_binding) | resource |
| [google_tags_tag_binding.cloudsql](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/tags_tag_binding) | resource |
| [google_project.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |
| [google_tags_tag_key.project_tag_keys_to_discover](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/tags_tag_key) | data source |
| [google_tags_tag_key.tag_keys](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/tags_tag_key) | data source |
| [google_tags_tag_value.project_tag_values_to_be_discovered](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/tags_tag_value) | data source |
| [google_tags_tag_value.tag_values](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/tags_tag_value) | data source |
## Modules

No modules.

<!-- END_TF_DOCS -->
