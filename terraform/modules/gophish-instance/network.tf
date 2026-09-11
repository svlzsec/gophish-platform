resource "aws_vpc" "this" {
  cidr_block           = "10.42.0.0/16"
  enable_dns_hostnames = true
  tags                 = merge(local.tags, { Name = "${var.client_name}-gophish" })
}
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = local.tags
}
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.42.1.0/24"
  map_public_ip_on_launch = true
  tags                    = local.tags
}
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags   = local.tags
}
resource "aws_route" "internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
resource "aws_security_group" "gophish" {
  name_prefix = "${var.client_name}-gophish-"
  vpc_id      = aws_vpc.this.id
  ingress {
    description = "Public campaign HTTPS listener"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # The administrative API contains sensitive campaign data and is never public.
  ingress {
    description = "Gophish administration from approved networks only"
    from_port   = 3333
    to_port     = 3333
    protocol    = "tcp"
    cidr_blocks = var.admin_allowlist_cidrs
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = local.tags
}
