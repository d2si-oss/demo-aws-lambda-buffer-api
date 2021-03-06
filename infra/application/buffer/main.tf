provider "aws" {
  allowed_account_ids = ["${var.allowed_account_id}"]
  region              = "${var.region}"
}

# Modules
module "vars" {
  source = "../../../modules/format_variables"

  env         = "${var.environment}"
  application = "${var.application}"
  component   = "${var.component}"
}

module "api" {
  source      = "../../../modules/api_gateway"
  name        = "${module.vars.fully_qualified_name}"
  description = "${var.api_description}"
}

# Roles and Policy
resource "aws_iam_role" "iam_for_lambda" {
  name = "${module.vars.fully_qualified_name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "logconf" {
  name = "${module.vars.fully_qualified_name}-logconf"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
              "logs:CreateLogGroup",
              "logs:CreateLogStream",
              "logs:PutLogEvents"
            ],
            "Resource": [
              "*"
            ]
        }
    ]
}
POLICY
}

resource "aws_iam_policy_attachment" "logconf_to_api" {
  name       = "${module.vars.fully_qualified_name}-logconf"
  roles      = ["${aws_iam_role.iam_for_lambda.name}"]
  policy_arn = "${aws_iam_policy.logconf.arn}"
}

/*
* Uncomment this code if you want to destribute your lambda function
* without the apex binary
*/

/*
data "archive_file" "buffer" {
  type        = "zip"
  source_dir  = "../../../../code/buffer/functions/proxy"
  output_path = "../../../build/buffer-proxy.zip"
}
resource "aws_lambda_function" "proxy" {
  filename         = "${data.archive_file.buffer.output_path}"
  function_name    = "${module.vars.fully_qualified_name}-proxy"
  role             = "${aws_iam_role.iam_for_lambda.arn}"
  handler          = "entrypoint.proxy_handler"
  runtime          = "python2.7"
  memory_size      = 256
  timeout          = 10
  source_code_hash = "${data.archive_file.buffer.output_base64sha256}"
}
*/

module "proxy" {
  source             = "../../../modules/api_integration_lambda"
  rest_api_id        = "${module.api.id}"
  parent_id          = "${module.api.root_resource_id}"
  region             = "${var.region}"
  allowed_account_id = "${var.allowed_account_id}"
  function_name      = "${module.vars.fully_qualified_name}-proxy"
  resource_part      = "{proxy+}"
  method             = "ANY"
  api_key_required   = "false"
}

# Deployment
resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = "${module.api.id}"
  stage_name  = "${var.environment}"

  variables = {
    "LBD_ENV" = "${var.environment}"
  }
}

# Resources Dynamo
resource "aws_dynamodb_table" "buffer" {
  name           = "${module.vars.fully_qualified_name}-proxy"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "cache_key"

  attribute {
    name = "cache_key"
    type = "S"
  }
}

resource "aws_iam_policy" "dynamo" {
  name = "${module.vars.fully_qualified_name}-dynamo"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "lambda:InvokeFunction"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:*"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_iam_policy_attachment" "dynamo_to_api" {
  name       = "${module.vars.fully_qualified_name}-dynamo"
  roles      = ["${aws_iam_role.iam_for_lambda.name}"]
  policy_arn = "${aws_iam_policy.dynamo.arn}"
}
