
# INSTANCES #
resource "aws_instance" "nginx" {
  count                  = var.instance_count[terraform.workspace]
  ami                    = nonsensitive(data.aws_ssm_parameter.ami.value)
  instance_type          = var.instance_type[terraform.workspace]
  subnet_id              = module.vpc.public_subnets[(count.index % var.vpc_subnet_count[terraform.workspace])]
  vpc_security_group_ids = [aws_security_group.nginx-sg.id]
  iam_instance_profile   = module.web_app_s3.instance_profile.name
  depends_on             = [module.web_app_s3]

  user_data = templatefile("${path.module}/startup_script.tpl", {
    s3_bucket_name = module.web_app_s3.web_bucket.id
  })

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-nginx-${count.index}"
  })

}

## $env:AWS_ACCESS_KEY_ID="AKIA265AAB5F3FJ7ISNC"
## $env:AWS_SECRET_ACCESS_KEY="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"