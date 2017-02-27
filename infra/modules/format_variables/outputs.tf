output "env" {
  value = "${lower(var.env)}"
}

output "application" {
  value = "${lower(var.application)}"
}

output "component" {
  value = "${lower(var.component)}"
}

output "fully_qualified_name" {
  value = "${lower("${var.env}-${var.application}-${var.component}")}"
}
