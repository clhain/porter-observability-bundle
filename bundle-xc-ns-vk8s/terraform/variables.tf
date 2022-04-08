variable "name" {
  description = "The name of the volterra namespace to create."
  default = ""
}

variable "name_prefix" {
  description = "The prefix of the volterra namespace to create. Appends a random ID to the end."
  default = "default-ns"
}

variable "vsite" {
  description = "The VSITE to deploy the vk8s cluster at"
  default = "ves-io-all-res"
}