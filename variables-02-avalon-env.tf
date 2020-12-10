variable "admin_ldap_groups" {
  type = list(string)
  default = []
  description = "Comma separated list of LDAP Groups, a user who is a member on any list will login as an administrator."
}

variable "assertion_cs_url" {
  default = ""
  description = "The URL at which the SAML assertion should be received. If not provided, defaults to the OmniAuth callback URL"
}

variable "assertion_logout_url" {
  default = ""
}

variable "csp_frame_ancestors" {
  default = ""
  description = "Sets allowed urls for the Content Security Policy header"
}

variable "fedora_ssl" {
  type = bool
  default = false
  description = "Forces the fedora database connection to use ssl."
}

variable "idp_slo_target_url" {
  default = ""
  description = "The URL to which the single logout request and response should be sent. This would be on the identity provider. "
}

variable "idp_sso_target_url" {
  default = ""
  description = "The URL to which the authentication request should be sent. This would be on the identity provider."
}

variable "issuer" {
  default = ""
  description = "The name of your application. Some identity providers might need this to establish the identity of the service provider requesting the login. Also know as EntityID"
}

variable "idp_cert_file" {
  default = "Path to IDP's cert, cert should be in PEM format."
}

variable "lti_auth_key" {
  default = ""
  description = "This LTI value is the 'username', it identifies the service to Canvas"
}

variable "lti_auth_secret" {
  default = ""
  description = "This LTI value is the 'password'"
}

variable "secret_key_base" {
  default = "a882b3f2f6144681b2fc0eb23fbdc8904c806fae882a3b6ada84ae83a4d967a9200e1ea27ee6c3049b1ca8bae040d844f04457d0f58c125813d3978a36898675"
}
variable "sp_cert_file" {
  default = ""
  description = "Path to the service provider's cert, in standard PEM format."
}

variable "sp_key_file" {
  default = ""
  description = "Path to the service provider's private key, in standard PEM format."
}

