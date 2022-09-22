<!-- BEGIN_TF_DOCS -->

## Introduction

This module will build a website that is protected by an [OpenId](https://openid.net/what-is-openid/)-compatible authentication provider.  It will provision a private S3 bucket, [Cloudfront](https://aws.amazon.com/cloudfront/), and deploy a customized Lambda function using [Lambda@Edge](https://aws.amazon.com/lambda/edge/).

Currently support [Google Apps (G Suite)](https://developers.google.com/identity/protocols/OpenIDConnect), [Microsoft Azure AD](https://docs.microsoft.com/en-us/azure/active-directory/develop/active-directory-protocols-oauth-code), [GitHub](https://developer.github.com/apps/building-oauth-apps/authorization-options-for-oauth-apps/), [OKTA](https://www.okta.com/), [Auth0](https://auth0.com/), [Centrify](https://centrify.com).

## Based on

#### [Widen](https://github.com/Widen/cloudfront-auth/)
This project uses the nodejs code for the Lambda function. Their repository includes a `build.js` script that interactively prompts for configuration items (client\_id, client\_secret, etc.) and builds the lambda zip file.

#### [terraform-cloudfront-auth](https://github.com/scalefactory/terraform-cloudfront-auth)
We use too the existant terraform module as a base.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.63 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.63 |
| <a name="provider_null"></a> [null](#provider\_null) | ~> 3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudfront_distribution.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_origin_access_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_identity) | resource |
| [aws_cloudfront_response_headers_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_response_headers_policy) | resource |
| [aws_iam_policy.lambda_log_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.lambda_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.lambda_log_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_route53_record.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_notification.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification) | resource |
| [aws_s3_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [null_resource.build_lambda](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.copy_lambda_artifact](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.lambda_clean_files](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_iam_policy_document.lambda_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.lambda_log_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_route53_zone.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [null_data_source.lambda_artifact_sync](https://registry.terraform.io/providers/hashicorp/null/latest/docs/data-sources/data_source) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acl"></a> [acl](#input\_acl) | (Optional) ACL | `string` | `"private"` | no |
| <a name="input_acm_certificate_arn"></a> [acm\_certificate\_arn](#input\_acm\_certificate\_arn) | (Optional) ARN of Certificate | `string` | `""` | no |
| <a name="input_auth_vendor"></a> [auth\_vendor](#input\_auth\_vendor) | (Required) The vendor to use for authorization (google, microsoft, github, okta, auth0, centrify) | `string` | n/a | yes |
| <a name="input_authz"></a> [authz](#input\_authz) | (Optional) The authorization method (google, microsoft only). Mirosoft: (1) Azure AD Login (default)<br>   (2) JSON Username Lookup<br><br> Google: (1) Hosted Domain - verify email's domain matches that of the given hosted domain<br>   (2) HTTP Email Lookup - verify email exists in JSON array located at given HTTP endpoint<br>   (3) Google Groups Lookup - verify email exists in one of given Google Groups | `string` | `"1"` | no |
| <a name="input_block_public_acls"></a> [block\_public\_acls](#input\_block\_public\_acls) | (Optional) Whether Amazon S3 should block public ACLs for this bucket. | `bool` | `true` | no |
| <a name="input_block_public_policy"></a> [block\_public\_policy](#input\_block\_public\_policy) | (Optional) Whether Amazon S3 should block public bucket policies for this bucket. | `bool` | `true` | no |
| <a name="input_client_id"></a> [client\_id](#input\_client\_id) | (Required) The authorization client id | `string` | n/a | yes |
| <a name="input_client_secret"></a> [client\_secret](#input\_client\_secret) | (Required) The authorization client secret | `string` | n/a | yes |
| <a name="input_cloudfront_aliases"></a> [cloudfront\_aliases](#input\_cloudfront\_aliases) | (Optional) List of cloudfront\_aliases | `list(string)` | <pre>[<br>  ""<br>]</pre> | no |
| <a name="input_cloudfront_allowed_methods"></a> [cloudfront\_allowed\_methods](#input\_cloudfront\_allowed\_methods) | (Optional) List of allowed methods (e.g. GET, PUT, POST, DELETE, HEAD) for AWS CloudFront | `list(string)` | <pre>[<br>  "GET",<br>  "HEAD"<br>]</pre> | no |
| <a name="input_cloudfront_cached_methods"></a> [cloudfront\_cached\_methods](#input\_cloudfront\_cached\_methods) | (Optional) List of cached methods (e.g. GET, PUT, POST, DELETE, HEAD) | `list(string)` | <pre>[<br>  "GET",<br>  "HEAD"<br>]</pre> | no |
| <a name="input_cloudfront_comment"></a> [cloudfront\_comment](#input\_cloudfront\_comment) | (Optional) Cloudfront comments | `string` | `""` | no |
| <a name="input_cloudfront_compress"></a> [cloudfront\_compress](#input\_cloudfront\_compress) | (Optional) Compress content for web requests that include Accept-Encoding: gzip in the request header | `bool` | `false` | no |
| <a name="input_cloudfront_custom_error_response"></a> [cloudfront\_custom\_error\_response](#input\_cloudfront\_custom\_error\_response) | (Optional) List of one or more custom error response element maps | <pre>list(object({<br>    error_caching_min_ttl = number<br>    error_code            = number<br>    response_code         = number<br>    response_page_path    = string<br>  }))</pre> | `[]` | no |
| <a name="input_cloudfront_custom_origins"></a> [cloudfront\_custom\_origins](#input\_cloudfront\_custom\_origins) | (Optional) One or more custom origins for this distribution (multiples allowed). See documentation for configuration options description https://www.terraform.io/docs/providers/aws/r/cloudfront_distribution.html#origin-arguments | `any` | `[]` | no |
| <a name="input_cloudfront_default_ttl"></a> [cloudfront\_default\_ttl](#input\_cloudfront\_default\_ttl) | (Optional) Default amount of time (in seconds) that an object is in a CloudFront cache | `number` | `86400` | no |
| <a name="input_cloudfront_forward_cookies"></a> [cloudfront\_forward\_cookies](#input\_cloudfront\_forward\_cookies) | (Optional) Specifies whether you want CloudFront to forward all or no cookies to the origin. Can be 'all' or 'none' | `string` | `"none"` | no |
| <a name="input_cloudfront_forward_header_values"></a> [cloudfront\_forward\_header\_values](#input\_cloudfront\_forward\_header\_values) | (Optional) A list of whitelisted header values to forward to the origin | `list(string)` | `[]` | no |
| <a name="input_cloudfront_forward_query_string"></a> [cloudfront\_forward\_query\_string](#input\_cloudfront\_forward\_query\_string) | (Optional) Forward query strings to the origin that is associated with this cache behavior | `bool` | `false` | no |
| <a name="input_cloudfront_index_document"></a> [cloudfront\_index\_document](#input\_cloudfront\_index\_document) | (Optional) Amazon S3 returns this index document when requests are made to the root domain or any of the subfolders | `string` | `"index.html"` | no |
| <a name="input_cloudfront_max_ttl"></a> [cloudfront\_max\_ttl](#input\_cloudfront\_max\_ttl) | (Optional) Maximum amount of time (in seconds) that an object is in a CloudFront cache | `number` | `31536000` | no |
| <a name="input_cloudfront_min_ttl"></a> [cloudfront\_min\_ttl](#input\_cloudfront\_min\_ttl) | (Optional) Minimum amount of time that you want objects to stay in CloudFront caches | `number` | `0` | no |
| <a name="input_cloudfront_minimum_protocol_version"></a> [cloudfront\_minimum\_protocol\_version](#input\_cloudfront\_minimum\_protocol\_version) | (Optional) Cloudfront TLS minimum protocol version | `string` | `"TLSv1.2_2021"` | no |
| <a name="input_cloudfront_ordered_cache_behavior"></a> [cloudfront\_ordered\_cache\_behavior](#input\_cloudfront\_ordered\_cache\_behavior) | (Optional) - An ordered list of cache behaviors resource for this distribution. List from top to bottom in order of precedence. The topmost cache behavior will have precedence 0. | `any` | `[]` | no |
| <a name="input_cloudfront_origin_group"></a> [cloudfront\_origin\_group](#input\_cloudfront\_origin\_group) | (Optional) One or more origin\_group for this distribution (multiples allowed). | `any` | `{}` | no |
| <a name="input_cloudfront_price_class"></a> [cloudfront\_price\_class](#input\_cloudfront\_price\_class) | (Optional) Price class for this distribution: `PriceClass_All`, `PriceClass_200`, `PriceClass_100` | `string` | `"PriceClass_All"` | no |
| <a name="input_cloudfront_response_headers_policy"></a> [cloudfront\_response\_headers\_policy](#input\_cloudfront\_response\_headers\_policy) | (Optional) Provides a CloudFront response headers policy resource. A response headers policy contains information about a set of HTTP response headers and their values. After you create a response headers policy, you can use its ID to attach it to one or more cache behaviors in a CloudFront distribution. When it’s attached to a cache behavior, CloudFront adds the headers in the policy to every response that it sends for requests that match the cache behavior. | `any` | `{}` | no |
| <a name="input_cloudfront_response_headers_policy_id"></a> [cloudfront\_response\_headers\_policy\_id](#input\_cloudfront\_response\_headers\_policy\_id) | (Optional) The identifier for a response headers policy. If response\_headers\_policy is true the name of policy is used. | `string` | `null` | no |
| <a name="input_cloudfront_trusted_signers"></a> [cloudfront\_trusted\_signers](#input\_cloudfront\_trusted\_signers) | (Optional) The AWS accounts, if any, that you want to allow to create signed URLs for private content. 'self' is acceptable. | `list(string)` | `[]` | no |
| <a name="input_cloudfront_viewer_protocol_policy"></a> [cloudfront\_viewer\_protocol\_policy](#input\_cloudfront\_viewer\_protocol\_policy) | (Optional) allow-all, redirect-to-https | `string` | `"redirect-to-https"` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | (Optional) Delete all objects in bucket on destroy | `bool` | `false` | no |
| <a name="input_github_organization"></a> [github\_organization](#input\_github\_organization) | (Optional) The GitHub organization. Required for GitHub auth vendor only | `string` | `null` | no |
| <a name="input_hd"></a> [hd](#input\_hd) | (Optional) The hosted domain (google only) | `string` | `null` | no |
| <a name="input_ignore_public_acls"></a> [ignore\_public\_acls](#input\_ignore\_public\_acls) | (Optional) Whether Amazon S3 should ignore public ACLs for this bucket. | `bool` | `true` | no |
| <a name="input_lambda_notifications"></a> [lambda\_notifications](#input\_lambda\_notifications) | (Optional) Map of S3 bucket notifications to Lambda function | `any` | `{}` | no |
| <a name="input_lifecycle_rule"></a> [lifecycle\_rule](#input\_lifecycle\_rule) | (Optional) List of maps containing configuration of object lifecycle management. | `any` | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | (Required) Name of resources | `string` | n/a | yes |
| <a name="input_policy"></a> [policy](#input\_policy) | (Optional) A valid bucket policy JSON document | `string` | `""` | no |
| <a name="input_redirect_uri"></a> [redirect\_uri](#input\_redirect\_uri) | (Required) The redirect uri | `string` | n/a | yes |
| <a name="input_replication_configuration"></a> [replication\_configuration](#input\_replication\_configuration) | (Optional) Map containing cross-region bucket replication configuration. | `any` | `{}` | no |
| <a name="input_restrict_public_buckets"></a> [restrict\_public\_buckets](#input\_restrict\_public\_buckets) | (Optional) Whether Amazon S3 should restrict public bucket policies for this bucket. | `bool` | `true` | no |
| <a name="input_route53_enabled"></a> [route53\_enabled](#input\_route53\_enabled) | (Optional) Set to false to prevent the module from creating any resources | `bool` | `false` | no |
| <a name="input_route53_evaluate_target_health"></a> [route53\_evaluate\_target\_health](#input\_route53\_evaluate\_target\_health) | (Optional) Set to true if you want Route 53 to determine whether to respond to DNS queries | `bool` | `"false"` | no |
| <a name="input_route53_parent_zone_id"></a> [route53\_parent\_zone\_id](#input\_route53\_parent\_zone\_id) | (Optional) ID of the hosted zone to contain this record  (or specify `parent_zone_name`) | `string` | `""` | no |
| <a name="input_route53_parent_zone_name"></a> [route53\_parent\_zone\_name](#input\_route53\_parent\_zone\_name) | (Optional) Name of the hosted zone to contain this record (or specify `parent_zone_id`) | `string` | `""` | no |
| <a name="input_s3_cors_rule"></a> [s3\_cors\_rule](#input\_s3\_cors\_rule) | (Optional) List of maps containing rules for Cross-Origin Resource Sharing. | `any` | `[]` | no |
| <a name="input_session_duration"></a> [session\_duration](#input\_session\_duration) | (Optional) Session duration in hours | `number` | `1` | no |
| <a name="input_sns_notifications"></a> [sns\_notifications](#input\_sns\_notifications) | (Optional) Map of S3 bucket notifications to SNS topic | `any` | `{}` | no |
| <a name="input_sqs_notifications"></a> [sqs\_notifications](#input\_sqs\_notifications) | (Optional) Map of S3 bucket notifications to SQS queue | `any` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Additional Tags | `map(string)` | `{}` | no |
| <a name="input_versioning"></a> [versioning](#input\_versioning) | (Optional) Map containing versioning configuration. | `map(string)` | `{}` | no |
| <a name="input_website"></a> [website](#input\_website) | (Optional) Map containing static web-site hosting or redirect configuration. | `map(string)` | <pre>{<br>  "error_document": "index.html",<br>  "index_document": "index.html"<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_arn"></a> [bucket\_arn](#output\_bucket\_arn) | The ARN of the S3 Bucket project. |
| <a name="output_bucket_domain_name"></a> [bucket\_domain\_name](#output\_bucket\_domain\_name) | S3 Bucket Domain Name |
| <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name) | S3 Bucket Name |
| <a name="output_cloudfront_arn"></a> [cloudfront\_arn](#output\_cloudfront\_arn) | The ARN (Amazon Resource Name) for the distribution. |
| <a name="output_cloudfront_id"></a> [cloudfront\_id](#output\_cloudfront\_id) | The identifier for the cloudfront distribution |
<!-- END_TF_DOCS -->