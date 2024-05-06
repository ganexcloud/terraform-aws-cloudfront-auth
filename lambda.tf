resource "null_resource" "build_lambda" {
  triggers = {
    vendor                  = var.auth_vendor
    cloudfront_distribution = var.name
    client_id               = var.client_id
    client_secret           = var.client_secret
    redirect_uri            = var.redirect_uri
    hd                      = var.hd
    session_duration        = var.session_duration
    authz                   = var.authz
    github_organization     = try(var.github_organization, "")
  }

  provisioner "local-exec" {
    command = <<EOF
    rm -rf terraform-aws-cloudfront-auth && rm -rf build
    git clone --branch master https://github.com/ganexcloud/terraform-aws-cloudfront-auth.git terraform-aws-cloudfront-auth
    mv terraform-aws-cloudfront-auth/function build
    mkdir build/distributions
    cd build/ && npm i minimist && npm install && cd build && npm install
EOF
  }

  provisioner "local-exec" {
    command = local.build_lambda_command
  }
}

resource "null_resource" "copy_lambda_artifact" {
  triggers = {
    build_resource = null_resource.build_lambda.id
  }

  provisioner "local-exec" {
    command = <<EOF
    mkdir -p lambda-functions
    cp build/distributions/${var.name}/${var.name}.zip lambda-functions/terraform-aws-cloudfront-auth.zip
EOF
  }
}

data "null_data_source" "lambda_artifact_sync" {
  inputs = {
    file    = "lambda-functions/terraform-aws-cloudfront-auth.zip"
    trigger = null_resource.copy_lambda_artifact.id
  }
}

#data "local_file" "build_js" {
#  filename = "${path.module}/build.js"
#}

data "aws_iam_policy_document" "lambda_log_access" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:*:*:*",
    ]

    effect = "Allow"
  }
}

resource "null_resource" "lambda_clean_files" {
  triggers = {
    build_resource = null_resource.copy_lambda_artifact.id
  }

  provisioner "local-exec" {
    command = "rm -rf terraform-aws-cloudfront-auth && rm -rf build"
  }

  depends_on = [aws_lambda_function.this]
}

resource "aws_lambda_function" "this" {
  description      = "Managed by Terraform"
  runtime          = "nodejs18.x"
  role             = aws_iam_role.lambda_role.arn
  filename         = "lambda-functions/terraform-aws-cloudfront-auth.zip"
  function_name    = "${var.name}-auth"
  handler          = "index.handler"
  publish          = true
  timeout          = 5
  source_code_hash = filebase64sha256(data.null_data_source.lambda_artifact_sync.outputs["file"])
  tags             = var.tags
  depends_on       = [null_resource.copy_lambda_artifact]
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"
      identifiers = [
        "edgelambda.amazonaws.com",
        "lambda.amazonaws.com",
      ]
    }

    effect = "Allow"
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "${var.name}-cloudfront-auth-lambda_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_log_access" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_log_access.arn
}

resource "aws_iam_policy" "lambda_log_access" {
  name   = "${var.name}-cloudfront-auth"
  policy = data.aws_iam_policy_document.lambda_log_access.json
  tags   = var.tags
}
