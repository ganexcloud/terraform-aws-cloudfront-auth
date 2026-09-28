provider "aws" {
  region = "us-east-1"
}

module "cloudfront_auth_example_github" {
  source              = "../../"
  name                = "example-github"
  auth_vendor         = "github"
  github_organization = "org1"
  client_id           = "example-client-id"
  client_secret       = "example-client-secret"
  redirect_uri        = "https://example.invalid/_callback"
  cloudfront_aliases  = ["example.invalid"]
  acm_certificate_arn = "arn:aws:acm:us-east-1:000000000000:certificate/00000000-0000-0000-0000-000000000000"
}
