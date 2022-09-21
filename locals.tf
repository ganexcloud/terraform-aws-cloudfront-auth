locals {
  build_lambda_command         = var.github_organization != null ? "${chomp(local.build_lambda_command_plus_hd)} --GITHUB_ORGANIZATION=${format("%q", var.github_organization)}" : local.build_lambda_command_plus_hd
  build_lambda_command_plus_hd = var.auth_vendor == "google" ? "${chomp(local.build_lambda_command_common)} --HD=${format("%q", var.hd)}" : local.build_lambda_command_common
  build_lambda_command_common  = <<-EOT
    cd build/ && node build/build.js --AUTH_VENDOR='${var.auth_vendor}' --CLOUDFRONT_DISTRIBUTION='${var.cloudfront_distribution_name}' --CLIENT_ID='${var.client_id}' --CLIENT_SECRET='${var.client_secret}' --REDIRECT_URI='${var.redirect_uri}' --SESSION_DURATION='${var.session_duration}' --AUTHZ=${format("%q", var.authz)}
    EOT
}
