variable "auth_vendor" {
  type        = string
  description = "(Required) The vendor to use for authorization (google, microsoft, github, okta, auth0, centrify)"
}

variable "client_id" {
  type        = string
  description = "(Required) The authorization client id"
}

variable "client_secret" {
  type        = string
  description = "(Required) The authorization client secret"
}

variable "redirect_uri" {
  type        = string
  description = "(Required) The redirect uri "
}

variable "hd" {
  type        = string
  description = "(Optional) The hosted domain (google only)"
  default     = null
}

variable "session_duration" {
  type        = number
  default     = 1
  description = "(Optional) Session duration in hours"
}

variable "authz" {
  type        = string
  default     = "1"
  description = "(Optional) The authorization method (google, microsoft only). Mirosoft: (1) Azure AD Login (default)\n   (2) JSON Username Lookup\n\n Google: (1) Hosted Domain - verify email's domain matches that of the given hosted domain\n   (2) HTTP Email Lookup - verify email exists in JSON array located at given HTTP endpoint\n   (3) Google Groups Lookup - verify email exists in one of given Google Groups"
}

variable "github_organization" {
  type        = string
  default     = null
  description = "(Optional) The GitHub organization. Required for GitHub auth vendor only"
}

variable "name" {
  description = "(Required) Name of resources"
  type        = string
}

variable "force_destroy" {
  description = "(Optional) Delete all objects in bucket on destroy"
  type        = bool
  default     = false
}

variable "versioning" {
  description = "(Optional) Map containing versioning configuration."
  type        = map(string)
  default     = {}
}

variable "website" {
  description = "(Optional) Map containing static web-site hosting or redirect configuration."
  type        = map(string)
  default = {
    index_document = "index.html"
    error_document = "index.html"
  }
}

variable "lifecycle_rule" {
  description = "(Optional) List of maps containing configuration of object lifecycle management."
  type        = any
  default     = []
}

variable "policy" {
  type        = string
  description = "(Optional) A valid bucket policy JSON document"
  default     = ""
}

variable "replication_configuration" {
  description = "(Optional) Map containing cross-region bucket replication configuration."
  type        = any
  default     = {}
}

variable "tags" {
  description = "(Optional) Additional Tags"
  type        = map(string)
  default     = {}
}

variable "acl" {
  description = "(Optional) ACL"
  type        = string
  default     = "private"
}

variable "block_public_acls" {
  description = "(Optional) Whether Amazon S3 should block public ACLs for this bucket."
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "(Optional) Whether Amazon S3 should block public bucket policies for this bucket."
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  description = "(Optional) Whether Amazon S3 should ignore public ACLs for this bucket."
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = "(Optional) Whether Amazon S3 should restrict public bucket policies for this bucket."
  type        = bool
  default     = true
}

variable "cloudfront_aliases" {
  description = "(Optional) List of cloudfront_aliases"
  type        = list(string)
  default     = [""]
}

variable "cloudfront_comment" {
  description = "(Optional) Cloudfront comments"
  type        = string
  default     = ""
}

variable "cloudfront_price_class" {
  description = "(Optional) Price class for this distribution: `PriceClass_All`, `PriceClass_200`, `PriceClass_100`"
  type        = string
  default     = "PriceClass_All"
}

variable "cloudfront_minimum_protocol_version" {
  type        = string
  description = "(Optional) Cloudfront TLS minimum protocol version"
  default     = "TLSv1.2_2021"
}

variable "cloudfront_default_ttl" {
  type        = number
  default     = 86400
  description = "(Optional) Default amount of time (in seconds) that an object is in a CloudFront cache"
}

variable "cloudfront_min_ttl" {
  type        = number
  default     = 0
  description = "(Optional) Minimum amount of time that you want objects to stay in CloudFront caches"
}

variable "cloudfront_max_ttl" {
  type        = number
  default     = 31536000
  description = "(Optional) Maximum amount of time (in seconds) that an object is in a CloudFront cache"
}

variable "cloudfront_response_headers_policy_id" {
  description = "(Optional) The identifier for a response headers policy. If response_headers_policy is true the name of policy is used."
  type        = string
  default     = null
}

variable "cloudfront_response_headers_policy" {
  description = "(Optional) Provides a CloudFront response headers policy resource. A response headers policy contains information about a set of HTTP response headers and their values. After you create a response headers policy, you can use its ID to attach it to one or more cache behaviors in a CloudFront distribution. When it’s attached to a cache behavior, CloudFront adds the headers in the policy to every response that it sends for requests that match the cache behavior."
  type        = any
  default     = {}
}

variable "cloudfront_viewer_protocol_policy" {
  type        = string
  description = "(Optional) allow-all, redirect-to-https"
  default     = "redirect-to-https"
}

variable "cloudfront_forward_cookies" {
  type        = string
  default     = "none"
  description = "(Optional) Specifies whether you want CloudFront to forward all or no cookies to the origin. Can be 'all' or 'none'"
}

variable "cloudfront_forward_header_values" {
  type        = list(string)
  description = "(Optional) A list of whitelisted header values to forward to the origin"
  default     = []
}

variable "cloudfront_forward_query_string" {
  type        = bool
  default     = false
  description = "(Optional) Forward query strings to the origin that is associated with this cache behavior"
}

variable "cloudfront_trusted_signers" {
  type        = list(string)
  default     = []
  description = "(Optional) The AWS accounts, if any, that you want to allow to create signed URLs for private content. 'self' is acceptable."
}

variable "cloudfront_compress" {
  type        = bool
  default     = false
  description = "(Optional) Compress content for web requests that include Accept-Encoding: gzip in the request header"
}

variable "cloudfront_allowed_methods" {
  type        = list(string)
  default     = ["GET", "HEAD"]
  description = "(Optional) List of allowed methods (e.g. GET, PUT, POST, DELETE, HEAD) for AWS CloudFront"
}

variable "cloudfront_cached_methods" {
  type        = list(string)
  default     = ["GET", "HEAD"]
  description = "(Optional) List of cached methods (e.g. GET, PUT, POST, DELETE, HEAD)"
}

variable "cloudfront_index_document" {
  type        = string
  default     = "index.html"
  description = "(Optional) Amazon S3 returns this index document when requests are made to the root domain or any of the subfolders"
}

variable "cloudfront_ordered_cache_behavior" {
  type        = any
  default     = []
  description = "(Optional) - An ordered list of cache behaviors resource for this distribution. List from top to bottom in order of precedence. The topmost cache behavior will have precedence 0."
}

variable "cloudfront_custom_error_response" {
  type = list(object({
    error_caching_min_ttl = number
    error_code            = number
    response_code         = number
    response_page_path    = string
  }))
  description = "(Optional) List of one or more custom error response element maps"
  default     = []
}

variable "cloudfront_custom_origins" {
  type        = any
  default     = []
  description = "(Optional) One or more custom origins for this distribution (multiples allowed). See documentation for configuration options description https://www.terraform.io/docs/providers/aws/r/cloudfront_distribution.html#origin-arguments"
}

variable "cloudfront_origin_group" {
  description = "(Optional) One or more origin_group for this distribution (multiples allowed)."
  type        = any
  default     = {}
}

variable "route53_enabled" {
  description = "(Optional) Set to false to prevent the module from creating any resources"
  type        = bool
  default     = false
}

variable "route53_parent_zone_id" {
  description = "(Optional) ID of the hosted zone to contain this record  (or specify `parent_zone_name`)"
  type        = string
  default     = ""
}

variable "route53_parent_zone_name" {
  description = "(Optional) Name of the hosted zone to contain this record (or specify `parent_zone_id`)"
  type        = string
  default     = ""
}

variable "route53_evaluate_target_health" {
  description = "(Optional) Set to true if you want Route 53 to determine whether to respond to DNS queries"
  type        = bool
  default     = "false"
}

variable "acm_certificate_arn" {
  description = "(Optional) ARN of Certificate"
  type        = string
  default     = ""
}

variable "lambda_notifications" {
  description = "(Optional) Map of S3 bucket notifications to Lambda function"
  type        = any
  default     = {}
}

variable "sqs_notifications" {
  description = "(Optional) Map of S3 bucket notifications to SQS queue"
  type        = any
  default     = {}
}

variable "sns_notifications" {
  description = "(Optional) Map of S3 bucket notifications to SNS topic"
  type        = any
  default     = {}
}

variable "s3_cors_rule" {
  description = "(Optional) List of maps containing rules for Cross-Origin Resource Sharing."
  type        = any
  default     = []
}
