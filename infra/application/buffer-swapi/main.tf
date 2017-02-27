provider "aws" {
  allowed_account_ids = ["${var.allowed_account_id}"]
  region              = "${var.region}"
}

# Modules
module "vars" {
  source = "../../modules/format_variables"

  env         = "${var.environment}"
  application = "${var.application}"
  component   = "${var.component}"
}

module "api" {
  source      = "../../modules/api_gateway"
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
