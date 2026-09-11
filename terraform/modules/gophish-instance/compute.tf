resource "aws_instance" "gophish" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_size
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.gophish.id]
  iam_instance_profile   = aws_iam_instance_profile.this.name
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
  root_block_device {
    encrypted   = true
    volume_size = 16
    tags        = local.tags
  }
  user_data = templatefile("${path.module}/user_data.sh.tftpl", {
    region        = data.aws_region.current.name
    client_name   = var.client_name
    gophish_image = var.gophish_image
  })
  user_data_replace_on_change = true
  tags                        = merge(local.tags, { Name = "${var.client_name}-gophish" })
}
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}
resource "aws_eip" "gophish" {
  domain   = "vpc"
  instance = aws_instance.gophish.id
  tags     = local.tags
}
