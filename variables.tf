
variable "auth_vendor" {
  type        = string
  description = "The vendor to use for authorisation (google, microsoft, github, okta, auth0, centrify)"
}

#variable "cloudfront_distribution" {
#  type        = string
#  description = "The cloudfront distribtion"
#}

variable "client_id" {
  type        = string
  description = "The authorisation client id"
}

variable "client_secret" {
  type        = string
  description = "The authorisation client secret"
  #sensitive   = true
}

variable "redirect_uri" {
  type        = string
  description = "The redirect uri "
}

variable "hd" {
  type        = string
  description = "The hosted domain (google only)"
  default     = null
}

variable "session_duration" {
  type        = number
  default     = 1
  description = "Session duration in hours"
}

variable "authz" {
  type        = string
  default     = "1"
  description = "The authorisation method (google, microsoft only). Mirosoft: (1) Azure AD Login (default)\n   (2) JSON Username Lookup\n\n Google: (1) Hosted Domain - verify email's domain matches that of the given hosted domain\n   (2) HTTP Email Lookup - verify email exists in JSON array located at given HTTP endpoint\n   (3) Google Groups Lookup - verify email exists in one of given Google Groups"
}

variable "github_organization" {
  type        = string
  default     = null
  description = "The GitHub organization. Required for GitHub auth vendor only"
}

#variable "bucket_name" {
#  type        = string
#  description = "The name of your s3 bucket"
#}
#
#variable "region" {
#  type        = string
#  description = "The region to deploy the S3 bucket into"
#}
#

################### NOVO
variable "name" {
  description = "Name of resources"
  type        = string
}

variable "force_destroy" {
  description = "Delete all objects in bucket on destroy"
  type        = bool
  default     = false
}

variable "versioning" {
  description = "Map containing versioning configuration."
  type        = map(string)
  default     = {}
}

variable "website" {
  description = "Map containing static web-site hosting or redirect configuration."
  type        = map(string)
  default = {
    index_document = "index.html"
    error_document = "index.html"
  }
}

variable "lifecycle_rule" {
  description = "List of maps containing configuration of object lifecycle management."
  type        = any
  default     = []
}

variable "policy" {
  type        = string
  description = "A valid bucket policy JSON document"
  default     = ""
}

variable "replication_configuration" {
  description = "Map containing cross-region bucket replication configuration."
  type        = any
  default     = {}
}

variable "tags" {
  description = "Additional Tags"
  type        = map(string)
  default     = {}
}

variable "acl" {
  description = "ACL"
  type        = string
  default     = "private"
}

variable "block_public_acls" {
  description = "Whether Amazon S3 should block public ACLs for this bucket."
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "Whether Amazon S3 should block public bucket policies for this bucket."
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  description = "Whether Amazon S3 should ignore public ACLs for this bucket."
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = "Whether Amazon S3 should restrict public bucket policies for this bucket."
  type        = bool
  default     = true
}

variable "origin_path" {
  type        = string
  description = "An optional element that causes CloudFront to request your content from a directory in your Amazon S3 bucket or your custom origin. It must begin with a /. Do not add a / at the end of the path."
  default     = "/"
}

variable "cloudfront_distribution_name" {
  description = "The name of the distribution."
  type        = string
}

variable "cloudfront_aliases" {
  description = "List of cloudfront_aliases"
  type        = list(string)
  default     = [""]
}

variable "cloudfront_comment" {
  description = "Cloudfront comments"
  type        = string
  default     = ""
}

variable "cloudfront_price_class" {
  description = "Price class for this distribution: `PriceClass_All`, `PriceClass_200`, `PriceClass_100`"
  type        = string
  default     = "PriceClass_All"
}

variable "cloudfront_minimum_protocol_version" {
  type        = string
  description = "Cloudfront TLS minimum protocol version"
  default     = "TLSv1.1_2016"
}

variable "cloudfront_default_ttl" {
  type        = number
  default     = 86400
  description = "Default amount of time (in seconds) that an object is in a CloudFront cache"
}

variable "cloudfront_min_ttl" {
  type        = number
  default     = 0
  description = "Minimum amount of time that you want objects to stay in CloudFront caches"
}

variable "cloudfront_max_ttl" {
  type        = number
  default     = 31536000
  description = "Maximum amount of time (in seconds) that an object is in a CloudFront cache"
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
  description = "allow-all, redirect-to-https"
  default     = "redirect-to-https"
}

variable "cloudfront_forward_cookies" {
  type        = string
  default     = "none"
  description = "Specifies whether you want CloudFront to forward all or no cookies to the origin. Can be 'all' or 'none'"
}

variable "cloudfront_forward_header_values" {
  type        = list(string)
  description = "A list of whitelisted header values to forward to the origin"
  default     = []
}

variable "cloudfront_forward_query_string" {
  type        = bool
  default     = false
  description = "Forward query strings to the origin that is associated with this cache behavior"
}

variable "cloudfront_trusted_signers" {
  type        = list(string)
  default     = []
  description = "The AWS accounts, if any, that you want to allow to create signed URLs for private content. 'self' is acceptable."
}

variable "cloudfront_compress" {
  type        = bool
  default     = false
  description = "Compress content for web requests that include Accept-Encoding: gzip in the request header"
}

variable "cloudfront_allowed_methods" {
  type        = list(string)
  default     = ["GET", "HEAD"]
  description = "List of allowed methods (e.g. GET, PUT, POST, DELETE, HEAD) for AWS CloudFront"
}

variable "cloudfront_cached_methods" {
  type        = list(string)
  default     = ["GET", "HEAD"]
  description = "List of cached methods (e.g. GET, PUT, POST, DELETE, HEAD)"
}

variable "cloudfront_index_document" {
  type        = string
  default     = "index.html"
  description = "Amazon S3 returns this index document when requests are made to the root domain or any of the subfolders"
}

variable "cloudfront_default_target_origin_id" {
  type        = string
  default     = null
  description = "The value of ID for the origin that you want CloudFront to route requests to the default cache behavior"
}

variable cloudfront_ordered_cache_behavior {
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
  description = "List of one or more custom error response element maps"
  default     = []
}

variable "cloudfront_custom_origins" {
  type        = any
  default     = []
  description = "One or more custom origins for this distribution (multiples allowed). See documentation for configuration options description https://www.terraform.io/docs/providers/aws/r/cloudfront_distribution.html#origin-arguments"
}

variable "cloudfront_origin_group" {
  description = "One or more origin_group for this distribution (multiples allowed)."
  type        = any
  default     = {}
}

variable "route53_enabled" {
  description = "Set to false to prevent the module from creating any resources"
  type        = bool
  default     = true
}

variable "route53_parent_zone_id" {
  description = "ID of the hosted zone to contain this record  (or specify `parent_zone_name`)"
  type        = string
  default     = ""
}

variable "route53_parent_zone_name" {
  description = "Name of the hosted zone to contain this record (or specify `parent_zone_id`)"
  type        = string
  default     = ""
}

variable "route53_evaluate_target_health" {
  description = "Set to true if you want Route 53 to determine whether to respond to DNS queries"
  type        = bool
  default     = "false"
}

variable "acm_certificate_arn" {
  description = "ARN of Certificate"
  type        = string
  default     = ""
}

variable "lambda_notifications" {
  description = "Map of S3 bucket notifications to Lambda function"
  type        = any
  default     = {}
}

variable "sqs_notifications" {
  description = "Map of S3 bucket notifications to SQS queue"
  type        = any
  default     = {}
}

variable "sns_notifications" {
  description = "Map of S3 bucket notifications to SNS topic"
  type        = any
  default     = {}
}

variable "s3_cors_rule" {
  description = "(Optional) List of maps containing rules for Cross-Origin Resource Sharing."
  type        = any
  default     = []
}

