resource "null_resource" "copy_source" {
  provisioner "local-exec" {
    command = <<EOF
if [ ! -d "build" ]; then
  if [ ! -L "build" ]; then
    #curl -L https://github.com/Widen/cloudfront-auth/archive/master.zip --output cloudfront-auth-master.zip
    #unzip -q cloudfront-auth-master.zip -d build/
    git clone --branch v1 https://github.com/ganexcloud/terraform-aws-cloudfront-auth.git build
    mkdir build/distributions
    cp ${data.local_file.build-js.filename} build/build/build.js
    cd build/ && npm i minimist && npm install && cd build && npm install
  fi
fi
EOF
  }
}

resource "null_resource" "build_lambda" {
  depends_on = [null_resource.copy_source]
  triggers = {
    vendor                  = var.auth_vendor
    cloudfront_distribution = var.cloudfront_distribution_name
    client_id               = var.client_id
    client_secret           = var.client_secret
    redirect_uri            = var.redirect_uri
    hd                      = var.hd
    session_duration        = var.session_duration
    authz                   = var.authz
    github_organization     = try(var.github_organization, "")
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
    command = "cp build/cloudfront-auth-master/distributions/${var.cloudfront_distribution_name}/${var.cloudfront_distribution_name}.zip lambda.zip"
  }
}

data "null_data_source" "lambda_artifact_sync" {
  inputs = {
    file    = "lambda.zip"
    trigger = null_resource.copy_lambda_artifact.id
  }
}

data "local_file" "build-js" {
  filename = "${path.module}/build.js"
}

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

resource "aws_lambda_function" "this" {
  provider         = aws.us-east-1
  description      = "Managed by Terraform"
  runtime          = "nodejs12.x"
  role             = aws_iam_role.lambda_role.arn
  filename         = "lambda.zip"
  function_name    = var.name
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
  name               = "lambda_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_log_access" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_log_access.arn
}

resource "aws_iam_policy" "lambda_log_access" {
  name   = "cloudfront_auth_lambda_log_access"
  policy = data.aws_iam_policy_document.lambda_log_access.json
}
