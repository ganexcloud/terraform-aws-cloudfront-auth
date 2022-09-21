provider "aws" {
  region = "us-east-1"
}

module "cloudfront_auth_example_github" {
  source              = "../../"
  name                = "example-github"
  auth_vendor         = "github"
  github_organization = "org1"
  client_id           = "8OXStiDETDS0AOtYnZ6U"
  client_secret       = "5bDmlL4Fn9C9qeMiJo6euUqwRq40hS0v5KtxDXKx"
  redirect_uri        = "https://example-github.domain.com/_callback"
  cloudfront_aliases  = ["example-github.domain.com"]
  acm_certificate_arn = "arn:aws:acm:us-east-1:971301968728:certificate/3ijb5y47-8qhm-4d21-26xs-121kg12dpet1"
}
