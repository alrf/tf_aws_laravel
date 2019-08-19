data "template_file" "env" {
  template = "${file("${path.module}/.env.tpl")}"

  vars = {
    bucket_name            = "${var.bucket_name}"
    aws_access_key         = "${var.aws_access_key}"
    aws_secret_key         = "${var.aws_secret_key}"
    aws_region             = "${var.aws_region}"
    cloudfront_domain_name = "${var.cloudfront_domain_name}"
    db_host                = "${var.db_host}"
    db_name                = "${var.db_name}"
    db_username            = "${var.db_username}"
    db_password            = "${var.db_password}"
  }
}

resource "null_resource" "export_rendered_template" {
  provisioner "local-exec" {
    command = "cat > app/.env <<EOL\n${join(",\n", data.template_file.env.*.rendered)}\nEOL"
  }
}

# resource "null_resource" "docker_build" {
#   provisioner "local-exec" {
#     command = "cat > app/.env <<EOL\n${join(",\n", data.template_file.env.*.rendered)}\nEOL"
#   }


#   depends_on = ["null_resource.export_rendered_template"]
# }

