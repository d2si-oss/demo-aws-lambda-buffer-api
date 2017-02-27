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
