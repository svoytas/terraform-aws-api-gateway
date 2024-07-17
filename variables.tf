variable "api_name" {
  description = "Name of the API"
  type        = string
}

variable "stage_name" {
  description = "Name of the Stage"
  type        = string
}

variable "open_api_file" {
  description = "OpenAPI file for this version"
  type        = string
}

variable "open_api_file_variables" {
  description = "OpenAPI file variables for this version"
  type        = map(string)
}


variable "function_names" {
  type        = list(string)
  description = "List of all function names that the API GW will invoke"
}
