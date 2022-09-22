/**
  *
  * ## Introduction
  *
  * This module will build a website that is protected by an [OpenId](https://openid.net/what-is-openid/)-compatible authentication provider.  It will provision a private S3 bucket, [Cloudfront](https://aws.amazon.com/cloudfront/), and deploy a customized Lambda function using [Lambda@Edge](https://aws.amazon.com/lambda/edge/).
  *
  * Currently support [Google Apps (G Suite)](https://developers.google.com/identity/protocols/OpenIDConnect), [Microsoft Azure AD](https://docs.microsoft.com/en-us/azure/active-directory/develop/active-directory-protocols-oauth-code), [GitHub](https://developer.github.com/apps/building-oauth-apps/authorization-options-for-oauth-apps/), [OKTA](https://www.okta.com/), [Auth0](https://auth0.com/), [Centrify](https://centrify.com).
  *
  * ## Based on
  *
  * ### [Widen](https://github.com/Widen/cloudfront-auth/)
  * This project uses the nodejs code for the Lambda function. Their repository includes a `build.js` script that interactively prompts for configuration items (client_id, client_secret, etc.) and builds the lambda zip file.
  *
  * ### [terraform-cloudfront-auth](https://github.com/scalefactory/terraform-cloudfront-auth)
  * We use too the existante terraform module as a base.
  */

resource "aws_s3_bucket" "this" {
  bucket        = var.name
  force_destroy = var.force_destroy
  tags          = var.tags
  acl           = var.acl

  dynamic "website" {
    for_each = length(keys(var.website)) == 0 ? [] : [var.website]

    content {
      index_document           = lookup(website.value, "index_document", null)
      error_document           = lookup(website.value, "error_document", null)
      redirect_all_requests_to = lookup(website.value, "redirect_all_requests_to", null)
      routing_rules            = lookup(website.value, "routing_rules", null)
    }
  }

  dynamic "cors_rule" {
    for_each = try(jsondecode(var.s3_cors_rule), var.s3_cors_rule)

    content {
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      allowed_headers = lookup(cors_rule.value, "allowed_headers", null)
      expose_headers  = lookup(cors_rule.value, "expose_headers", null)
      max_age_seconds = lookup(cors_rule.value, "max_age_seconds", null)
    }
  }

  dynamic "versioning" {
    for_each = length(keys(var.versioning)) == 0 ? [] : [var.versioning]

    content {
      enabled    = lookup(versioning.value, "enabled", null)
      mfa_delete = lookup(versioning.value, "mfa_delete", null)
    }
  }

  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_rule

    content {
      id                                     = lookup(lifecycle_rule.value, "id", null)
      prefix                                 = lookup(lifecycle_rule.value, "prefix", null)
      tags                                   = lookup(lifecycle_rule.value, "tags", null)
      abort_incomplete_multipart_upload_days = lookup(lifecycle_rule.value, "abort_incomplete_multipart_upload_days", null)
      enabled                                = lifecycle_rule.value.enabled

      # Max 1 block - expiration
      dynamic "expiration" {
        for_each = length(keys(lookup(lifecycle_rule.value, "expiration", {}))) == 0 ? [] : [lookup(lifecycle_rule.value, "expiration", {})]

        content {
          date                         = lookup(expiration.value, "date", null)
          days                         = lookup(expiration.value, "days", null)
          expired_object_delete_marker = lookup(expiration.value, "expired_object_delete_marker", null)
        }
      }

      # Several blocks - transition
      dynamic "transition" {
        for_each = lookup(lifecycle_rule.value, "transition", [])

        content {
          date          = lookup(transition.value, "date", null)
          days          = lookup(transition.value, "days", null)
          storage_class = transition.value.storage_class
        }
      }

      # Max 1 block - noncurrent_version_expiration
      dynamic "noncurrent_version_expiration" {
        for_each = length(keys(lookup(lifecycle_rule.value, "noncurrent_version_expiration", {}))) == 0 ? [] : [lookup(lifecycle_rule.value, "noncurrent_version_expiration", {})]

        content {
          days = lookup(noncurrent_version_expiration.value, "days", null)
        }
      }

      # Several blocks - noncurrent_version_transition
      dynamic "noncurrent_version_transition" {
        for_each = lookup(lifecycle_rule.value, "noncurrent_version_transition", [])

        content {
          days          = lookup(noncurrent_version_transition.value, "days", null)
          storage_class = noncurrent_version_transition.value.storage_class
        }
      }
    }
  }

  # Max 1 block - replication_configuration
  dynamic "replication_configuration" {
    for_each = length(keys(var.replication_configuration)) == 0 ? [] : [var.replication_configuration]

    content {
      role = replication_configuration.value.role

      dynamic "rules" {
        for_each = replication_configuration.value.rules

        content {
          id       = lookup(rules.value, "id", null)
          priority = lookup(rules.value, "priority", null)
          prefix   = lookup(rules.value, "prefix", null)
          status   = lookup(rules.value, "status", null)

          dynamic "destination" {
            for_each = length(keys(lookup(rules.value, "destination", {}))) == 0 ? [] : [lookup(rules.value, "destination", {})]

            content {
              bucket             = lookup(destination.value, "bucket", null)
              storage_class      = lookup(destination.value, "storage_class", null)
              replica_kms_key_id = lookup(destination.value, "replica_kms_key_id", null)
              account_id         = lookup(destination.value, "account_id", null)

              dynamic "access_control_translation" {
                for_each = length(keys(lookup(destination.value, "access_control_translation", {}))) == 0 ? [] : [lookup(destination.value, "access_control_translation", {})]

                content {
                  owner = access_control_translation.value.owner
                }
              }
            }
          }

          dynamic "source_selection_criteria" {
            for_each = length(keys(lookup(rules.value, "source_selection_criteria", {}))) == 0 ? [] : [lookup(rules.value, "source_selection_criteria", {})]

            content {

              dynamic "sse_kms_encrypted_objects" {
                for_each = length(keys(lookup(source_selection_criteria.value, "sse_kms_encrypted_objects", {}))) == 0 ? [] : [lookup(source_selection_criteria.value, "sse_kms_encrypted_objects", {})]

                content {

                  enabled = sse_kms_encrypted_objects.value.enabled
                }
              }
            }
          }

          dynamic "filter" {
            for_each = length(keys(lookup(rules.value, "filter", {}))) == 0 ? [] : [lookup(rules.value, "filter", {})]

            content {
              prefix = lookup(filter.value, "prefix", null)
              tags   = lookup(filter.value, "tags", null)
            }
          }
        }
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = var.policy == "" ? data.aws_iam_policy_document.s3_bucket_policy.json : var.policy
}

data "aws_iam_policy_document" "s3_bucket_policy" {
  statement {
    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.this.arn}/*",
    ]

    principals {
      type = "AWS"
      identifiers = [
        aws_cloudfront_origin_access_identity.this.iam_arn,
      ]
    }
  }

  statement {
    actions = [
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.this.arn,
    ]

    principals {
      type = "AWS"
      identifiers = [
        aws_cloudfront_origin_access_identity.this.iam_arn,
      ]
    }
  }
}

resource "aws_s3_bucket_notification" "this" {
  count  = length(var.lambda_notifications) > 0 || length(var.sqs_notifications) > 0 || length(var.sns_notifications) > 0 ? 1 : 0
  bucket = var.name

  dynamic "lambda_function" {
    for_each = var.lambda_notifications

    content {
      id                  = lambda_function.key
      lambda_function_arn = lambda_function.value.function_arn
      events              = lambda_function.value.events
      filter_prefix       = lookup(lambda_function.value, "filter_prefix", null)
      filter_suffix       = lookup(lambda_function.value, "filter_suffix", null)
    }
  }

  dynamic "queue" {
    for_each = var.sqs_notifications

    content {
      id            = queue.key
      queue_arn     = queue.value.queue_arn
      events        = queue.value.events
      filter_prefix = lookup(queue.value, "filter_prefix", null)
      filter_suffix = lookup(queue.value, "filter_suffix", null)
    }
  }

  dynamic "topic" {
    for_each = var.sns_notifications

    content {
      id            = topic.key
      topic_arn     = topic.value.topic_arn
      events        = topic.value.events
      filter_prefix = lookup(topic.value, "filter_prefix", null)
      filter_suffix = lookup(topic.value, "filter_suffix", null)
    }
  }
}

resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = var.cloudfront_comment
  default_root_object = var.cloudfront_index_document
  aliases             = var.cloudfront_aliases
  price_class         = var.cloudfront_price_class
  tags                = var.tags

  default_cache_behavior {
    allowed_methods  = var.cloudfront_allowed_methods
    cached_methods   = var.cloudfront_cached_methods
    target_origin_id = "S3-${var.name}"
    compress         = var.cloudfront_compress
    trusted_signers  = var.cloudfront_trusted_signers

    forwarded_values {
      query_string = var.cloudfront_forward_query_string
      headers      = var.cloudfront_forward_header_values

      cookies {
        forward = var.cloudfront_forward_cookies
      }
    }

    response_headers_policy_id = length(var.cloudfront_response_headers_policy) > 0 ? aws_cloudfront_response_headers_policy.this[0].id : var.cloudfront_response_headers_policy_id
    viewer_protocol_policy     = var.cloudfront_viewer_protocol_policy
    default_ttl                = var.cloudfront_default_ttl
    min_ttl                    = var.cloudfront_min_ttl
    max_ttl                    = var.cloudfront_max_ttl

    lambda_function_association {
      event_type = "viewer-request"
      lambda_arn = aws_lambda_function.this.qualified_arn
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.cloudfront_ordered_cache_behavior
    content {
      path_pattern     = ordered_cache_behavior.value.path_pattern
      allowed_methods  = lookup(ordered_cache_behavior.value, "allowed_methods", ["GET", "HEAD"])
      cached_methods   = lookup(ordered_cache_behavior.value, "cached_methods", ["GET", "HEAD"])
      target_origin_id = ordered_cache_behavior.value.target_origin_id

      forwarded_values {
        headers                 = lookup(ordered_cache_behavior.value, "headers", [])
        query_string            = lookup(ordered_cache_behavior.value, "query_string", false)
        query_string_cache_keys = lookup(ordered_cache_behavior.value, "query_string_cache_keys", [])

        cookies {
          forward           = lookup(ordered_cache_behavior.value, "forward", "none")
          whitelisted_names = lookup(ordered_cache_behavior.value, "whitelisted_names", [])
        }
      }

      min_ttl                = lookup(ordered_cache_behavior.value, "min_ttl", 0)
      default_ttl            = lookup(ordered_cache_behavior.value, "default_ttl", 86400)
      max_ttl                = lookup(ordered_cache_behavior.value, "max_ttl", 31536000)
      compress               = lookup(ordered_cache_behavior.value, "compress", true)
      viewer_protocol_policy = lookup(ordered_cache_behavior.value, "viewer_protocol_policy", "redirect-to-https")
      smooth_streaming       = lookup(ordered_cache_behavior.value, "smooth_streaming", false)
      trusted_key_groups     = lookup(ordered_cache_behavior.value, "trusted_key_groups", [])
      trusted_signers        = lookup(ordered_cache_behavior.value, "trusted_signers", [])
    }
  }

  dynamic "custom_error_response" {
    for_each = var.cloudfront_custom_error_response
    content {
      error_caching_min_ttl = lookup(custom_error_response.value, "error_caching_min_ttl", null)
      error_code            = custom_error_response.value.error_code
      response_code         = lookup(custom_error_response.value, "response_code", null)
      response_page_path    = lookup(custom_error_response.value, "response_page_path", null)
    }
  }

  dynamic "origin" {
    for_each = length(var.cloudfront_custom_origins) == 0 ? list(1) : []
    content {
      domain_name = aws_s3_bucket.this.bucket_domain_name
      origin_id   = "S3-${var.name}"
      s3_origin_config {
        origin_access_identity = aws_cloudfront_origin_access_identity.this.cloudfront_access_identity_path
      }
    }
  }

  dynamic "origin" {
    for_each = var.cloudfront_custom_origins
    content {
      domain_name = origin.value.domain_name
      origin_id   = origin.value.origin_id
      origin_path = lookup(origin.value, "origin_path", "")
      dynamic "custom_header" {
        for_each = lookup(origin.value, "custom_headers", [])
        content {
          name  = custom_header.value["name"]
          value = custom_header.value["value"]
        }
      }
      custom_origin_config {
        http_port                = lookup(origin.value, "http_port", 80)
        https_port               = lookup(origin.value, "https_port", 443)
        origin_protocol_policy   = lookup(origin.value, "origin_protocol_policy", "https-only")
        origin_ssl_protocols     = lookup(origin.value, "origin_ssl_protocols", ["TLSv1.2"])
        origin_keepalive_timeout = lookup(origin.value, "origin_keepalive_timeout", 60)
        origin_read_timeout      = lookup(origin.value, "origin_read_timeout", 60)
      }
    }
  }

  dynamic "origin_group" {
    for_each = var.cloudfront_origin_group

    content {
      origin_id = lookup(origin_group.value, "origin_id", origin_group.key)

      failover_criteria {
        status_codes = origin_group.value["failover_status_codes"]
      }

      member {
        origin_id = origin_group.value["primary_member_origin_id"]
      }

      member {
        origin_id = origin_group.value["secondary_member_origin_id"]
      }
    }
  }

  viewer_certificate {
    acm_certificate_arn            = var.acm_certificate_arn
    ssl_support_method             = var.acm_certificate_arn == "" ? "" : "sni-only"
    minimum_protocol_version       = var.cloudfront_minimum_protocol_version
    cloudfront_default_certificate = var.acm_certificate_arn == "" ? true : false
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

data "aws_route53_zone" "default" {
  count   = var.route53_enabled == true ? signum(length(compact(var.cloudfront_aliases))) : 0
  zone_id = var.route53_parent_zone_id
  name    = var.route53_parent_zone_name
}

resource "aws_route53_record" "default" {
  count   = var.route53_enabled == true ? length(compact(var.cloudfront_aliases)) : 0
  zone_id = data.aws_route53_zone.default[0].zone_id
  name    = element(compact(var.cloudfront_aliases), count.index)
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.this.domain_name
    zone_id                = aws_cloudfront_distribution.this.hosted_zone_id
    evaluate_target_health = var.route53_evaluate_target_health
  }
}

resource "aws_cloudfront_response_headers_policy" "this" {
  count = length(var.cloudfront_response_headers_policy) > 0 ? 1 : 0
  name  = var.cloudfront_response_headers_policy.name

  dynamic "cors_config" {
    for_each = length(keys(lookup(var.cloudfront_response_headers_policy, "cors_config", {}))) == 0 ? [] : [lookup(var.cloudfront_response_headers_policy, "cors_config", {})]
    content {
      access_control_allow_credentials = lookup(cors_config.value, "access_control_allow_credentials")
      access_control_allow_headers {
        items = lookup(cors_config.value, "access_control_allow_headers")
      }
      access_control_allow_methods {
        items = lookup(cors_config.value, "access_control_allow_methods")
      }
      access_control_allow_origins {
        items = lookup(cors_config.value, "access_control_allow_origins", null)
      }
      dynamic "access_control_expose_headers" {
        for_each = length(keys(lookup(cors_config.value, "access_control_expose_headers", {}))) == 0 ? [] : [lookup(cors_config.value, "access_control_expose_headers", {})]
        content {
          items = lookup(access_control_expose_headers.value)
        }
      }
      access_control_max_age_sec = lookup(cors_config.value, "access_control_max_age_sec")
      origin_override            = lookup(cors_config.value, "origin_override")
    }
  }

  dynamic "custom_headers_config" {
    for_each = length(lookup(var.cloudfront_response_headers_policy, "custom_headers_config", [])) == 0 ? [] : list(1)
    content {
      dynamic "items" {
        for_each = length(lookup(var.cloudfront_response_headers_policy, "custom_headers_config", [])) == 0 ? [] : lookup(var.cloudfront_response_headers_policy, "custom_headers_config", [])
        content {
          header   = lookup(items.value, "header")
          override = lookup(items.value, "override")
          value    = lookup(items.value, "value")
        }
      }
    }
  }

  dynamic "security_headers_config" {
    for_each = length(keys(lookup(var.cloudfront_response_headers_policy, "security_headers_config", {}))) == 0 ? [] : [lookup(var.cloudfront_response_headers_policy, "security_headers_config", {})]
    content {
      dynamic "content_security_policy" {
        for_each = length(keys(lookup(security_headers_config.value, "content_security_policy", {}))) == 0 ? [] : [lookup(security_headers_config.value, "content_security_policy", {})]
        content {
          content_security_policy = lookup(content_security_policy.value, "content_security_policy")
          override                = lookup(content_security_policy.value, "override")
        }
      }
      dynamic "content_type_options" {
        for_each = length(keys(lookup(security_headers_config.value, "content_type_options", {}))) == 0 ? [] : [lookup(security_headers_config.value, "content_type_options", {})]
        content {
          override = lookup(content_type_options.value, "override")
        }
      }
      dynamic "frame_options" {
        for_each = length(keys(lookup(security_headers_config.value, "frame_options", {}))) == 0 ? [] : [lookup(security_headers_config.value, "frame_options", {})]
        content {
          frame_option = lookup(frame_options.value, "frame_option")
          override     = lookup(frame_options.value, "override")
        }
      }
      dynamic "referrer_policy" {
        for_each = length(keys(lookup(security_headers_config.value, "referrer_policy", {}))) == 0 ? [] : [lookup(security_headers_config.value, "referrer_policy", {})]
        content {
          referrer_policy = lookup(referrer_policy.value, "referrer_policy")
          override        = lookup(referrer_policy.value, "override")
        }
      }
      dynamic "strict_transport_security" {
        for_each = length(keys(lookup(security_headers_config.value, "strict_transport_security", {}))) == 0 ? [] : [lookup(security_headers_config.value, "strict_transport_security", {})]
        content {
          access_control_max_age_sec = lookup(strict_transport_security.value, "access_control_max_age_sec")
          include_subdomains         = lookup(strict_transport_security.value, "include_subdomains", null)
          override                   = lookup(strict_transport_security.value, "override")
          preload                    = lookup(strict_transport_security.value, "preload", null)
        }
      }
      dynamic "xss_protection" {
        for_each = length(keys(lookup(security_headers_config.value, "xss_protection", {}))) == 0 ? [] : [lookup(security_headers_config.value, "xss_protection", {})]
        content {
          mode_block = lookup(xss_protection.value, "mode_block")
          override   = lookup(xss_protection.value, "override")
          protection = lookup(xss_protection.value, "protection")
          report_uri = lookup(xss_protection.value, "report_uri", null)
        }
      }
    }
  }
}

resource "aws_cloudfront_origin_access_identity" "this" {
  comment = var.name
}
