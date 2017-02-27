output "id" {
  value = "${aws_api_gateway_resource.main.id}"
}

output "resource_full_path" {
  value = "${aws_api_gateway_resource.main.path}"
}
