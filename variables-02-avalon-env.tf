variable "admin_ldap_groups" {
  type = list(string)
  default = []
}

variable "assertion_cs_url" {
  default = ""
}

variable "assertion_logout_url" {
  default = ""
}

variable "compose_docker_branch" {
  default = "aws_min"
  description = "Controls which branch of avalon-docker the compose ec2 will download and unzip during setup"
}

variable "fedora_ssl" {
  type = bool
  default = false
  description = "Forces the fedora database connection to use ssl."
}

variable "idp_slo_target_url" {
  default = ""
}

variable "idp_sso_target_url" {
  default = ""
}

variable "issuer" {
  default = ""
}

variable "idp_cert_file" {
  default = ""
}

variable "lti_auth_key" {
  default = ""
}

variable "lti_auth_secret" {
  default = ""
}

variable "secret_key_base" {
  default = "a882b3f2f6144681b2fc0eb23fbdc8904c806fae882a3b6ada84ae83a4d967a9200e1ea27ee6c3049b1ca8bae040d844f04457d0f58c125813d3978a36898675"
}
variable "sp_cert_file" {
  default = ""
}

variable "sp_key_file" {
  default = ""
}

