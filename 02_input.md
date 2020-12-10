## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| admin\_ldap\_groups | Comma separated list of LDAP Groups, a user who is a member on any list will login as an administrator. | `list(string)` | `[]` | no |
| assertion\_cs\_url | The URL at which the SAML assertion should be received. If not provided, defaults to the OmniAuth callback URL | `string` | `""` | no |
| assertion\_logout\_url | n/a | `string` | `""` | no |
| csp\_frame\_ancestors | Sets allowed urls for the Content Security Policy header | `string` | `""` | no |
| fedora\_ssl | Forces the fedora database connection to use ssl. | `bool` | `false` | no |
| idp\_cert\_file | n/a | `string` | `"Path to IDP's cert, cert should be in PEM format."` | no |
| idp\_slo\_target\_url | The URL to which the single logout request and response should be sent. This would be on the identity provider. | `string` | `""` | no |
| idp\_sso\_target\_url | The URL to which the authentication request should be sent. This would be on the identity provider. | `string` | `""` | no |
| issuer | The name of your application. Some identity providers might need this to establish the identity of the service provider requesting the login. Also know as EntityID | `string` | `""` | no |
| lti\_auth\_key | This LTI value is the 'username', it identifies the service to Canvas | `string` | `""` | no |
| lti\_auth\_secret | This LTI value is the 'password' | `string` | `""` | no |
| secret\_key\_base | n/a | `string` | `"a882b3f2f6144681b2fc0eb23fbdc8904c806fae882a3b6ada84ae83a4d967a9200e1ea27ee6c3049b1ca8bae040d844f04457d0f58c125813d3978a36898675"` | no |
| sp\_cert\_file | Path to the service provider's cert, in standard PEM format. | `string` | `""` | no |
| sp\_key\_file | Path to the service provider's private key, in standard PEM format. | `string` | `""` | no |
