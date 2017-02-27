resource "aws_api_gateway_resource" "main" {
  rest_api_id = "${var.rest_api_id}"
  parent_id   = "${var.parent_id}"
  path_part   = "${var.resource_part}"
}

resource "aws_api_gateway_method" "main" {
  rest_api_id      = "${var.rest_api_id}"
  resource_id      = "${aws_api_gateway_resource.main.id}"
  http_method      = "${var.method}"
  authorization    = "NONE"
  api_key_required = "${var.api_key_required}"
}

resource "aws_api_gateway_integration" "main" {
  depends_on              = ["aws_api_gateway_method.main"]
  rest_api_id             = "${var.rest_api_id}"
  type                    = "AWS"
  resource_id             = "${aws_api_gateway_resource.main.id}"
  http_method             = "${aws_api_gateway_method.main.http_method}"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.region}:${var.allowed_account_id}:function:${var.function_name}/invocations"
  integration_http_method = "POST"

  request_templates = {
    "application/json" = "${file("${path.module}/mappings.js")}"
  }
}

resource "aws_api_gateway_integration_response" "200" {
  depends_on  = ["aws_api_gateway_integration.main"]
  rest_api_id = "${var.rest_api_id}"
  resource_id = "${aws_api_gateway_resource.main.id}"
  http_method = "${aws_api_gateway_method.main.http_method}"
  status_code = "200"
}

resource "aws_api_gateway_method_response" "200" {
  rest_api_id = "${var.rest_api_id}"
  resource_id = "${aws_api_gateway_resource.main.id}"
  http_method = "${aws_api_gateway_method.main.http_method}"
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "500" {
  depends_on  = ["aws_api_gateway_integration.main"]
  rest_api_id = "${var.rest_api_id}"
  resource_id = "${aws_api_gateway_resource.main.id}"
  http_method = "${aws_api_gateway_method.main.http_method}"
  status_code = "500"
  selection_pattern = ".*Error:5\\d{2}.*"
  response_templates = {
    "application/json" = <<EOS
    {
      "message": $input.json('$.errorMessage')
    }
EOS
  }
}

resource "aws_api_gateway_method_response" "500" {
  rest_api_id = "${var.rest_api_id}"
  resource_id = "${aws_api_gateway_resource.main.id}"
  http_method = "${aws_api_gateway_method.main.http_method}"
  status_code = "500"
  depends_on = ["aws_api_gateway_method_response.200"]
}

resource "aws_api_gateway_integration_response" "400" {
  depends_on  = ["aws_api_gateway_integration.main"]
  rest_api_id = "${var.rest_api_id}"
  resource_id = "${aws_api_gateway_resource.main.id}"
  http_method = "${aws_api_gateway_method.main.http_method}"
  status_code = "400"
  selection_pattern = ".*Error:4\\d{2}.*"
  response_templates = {
    "application/json" = <<EOS
    {
      "message": $input.json('$.errorMessage')
    }
EOS
  }
}

resource "aws_api_gateway_method_response" "400" {
  rest_api_id = "${var.rest_api_id}"
  resource_id = "${aws_api_gateway_resource.main.id}"
  http_method = "${aws_api_gateway_method.main.http_method}"
  status_code = "400"
  depends_on = ["aws_api_gateway_method_response.500"]
}

resource "aws_api_gateway_integration_response" "429" {
  depends_on  = ["aws_api_gateway_integration.main"]
  rest_api_id = "${var.rest_api_id}"
  resource_id = "${aws_api_gateway_resource.main.id}"
  http_method = "${aws_api_gateway_method.main.http_method}"
  status_code = "429"
  selection_pattern = ".*Error:429.*"
  response_templates = {
    "application/json" = <<EOS
    {
      "message": $input.json('$.errorMessage')
    }
EOS
  }
}

resource "aws_api_gateway_method_response" "429" {
  rest_api_id = "${var.rest_api_id}"
  resource_id = "${aws_api_gateway_resource.main.id}"
  http_method = "${aws_api_gateway_method.main.http_method}"
  status_code = "429"
  depends_on = ["aws_api_gateway_method_response.400"]
}

resource "aws_lambda_permission" "allow" {
  function_name = "${var.function_name}"
  statement_id  = "${sha256("${var.function_name}")}"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region}:${var.allowed_account_id}:${var.rest_api_id}/*/${aws_api_gateway_integration.main.http_method}${aws_api_gateway_resource.main.path}"
}
