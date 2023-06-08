resource "aws_vpc" "main" {
  cidr_block       = "172.31.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}

resource "aws_network_acl" "main" {
  vpc_id = aws_vpc.main.id

  ingress = [
    {
      from_port       = 22
      to_port         = 22
      protocol        = "tcp"
      rule_no         = 100
      action          = "allow"
      cidr_block      = "${chomp(data.http.myip.body)}/32"
      ipv6_cidr_block = null
      icmp_type       = 0
      icmp_code       = 0
    },
    {
      from_port       = 3128
      to_port         = 3128
      protocol        = "tcp"
      rule_no         = 200
      action          = "allow"
      cidr_block      = "${chomp(data.http.myip.body)}/32"
      ipv6_cidr_block = null
      icmp_type       = 0
      icmp_code       = 0
    }
  ]

  egress = [
    {
      from_port       = 443
      to_port         = 443
      protocol        = "tcp"
      rule_no         = 100
      action          = "allow"
      cidr_block      = "0.0.0.0/0"
      ipv6_cidr_block = null
      icmp_type       = 0
      icmp_code       = 0
    }
  ]

  tags = {
    Name = "main"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

resource "aws_route_table" "public_routes" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public_routes"
  }
}

resource "aws_subnet" "public_zone" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "172.31.0.0/20"
  availability_zone = "${var.region}d"
}

resource "aws_route_table_association" "public_zone_assoc" {
  subnet_id      = aws_subnet.public_zone.id
  route_table_id = aws_route_table.public_routes.id
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

resource "aws_security_group" "lb_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 3128
    to_port     = 3128
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }

  egress {
    from_port   = 3128
    to_port     = 3128
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/20"]
  }
}

resource "aws_security_group" "instance_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 3128
    to_port     = 3128
    protocol    = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
  }

  ingress {
    from_port   = 54321
    to_port     = 54321
    protocol    = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

locals {
  private_ips = formatlist("172.31.1.%s", range(var.n_proxies))
}

resource "aws_instance" "proxies" {
  count           = var.n_proxies
  ami             = var.proxy_ami
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.instance_sg.id]
  tags = {
    "Name"   = "Proxy"
    "Number" = count.index + 1
  }
  private_ip = local.private_ips[count.index]
  subnet_id                   = aws_subnet.public_zone.id
  key_name                    = "pumpbot"
  associate_public_ip_address = true
  root_block_device {
    volume_type = "gp3"
    volume_size = 8
  }
}

data "template_file" "user_data" {
  template = <<DOC
#!/bin/bash

cat > /etc/nginx/modules-available/load_balancer.conf <<EOF
stream {
        upstream backend {
$${servers}
        }

        server {
                listen 3128;
                proxy_pass backend;
        }
}
EOF

sudo ln -s /etc/nginx/modules-available/load_balancer.conf /etc/nginx/modules-enabled/load_balancer.conf

sudo systemctl restart nginx
DOC

  vars = {
    servers      = "${join("", formatlist("\n            server %s:3128;", local.private_ips))}"
  }

  depends_on = [local.private_ips]
}

resource "aws_instance" "load_balancer" {
  ami             = var.lb_ami
  instance_type   = "a1.medium"
  security_groups = [aws_security_group.lb_sg.id]
  tags = {
    "Name"   = "LB"
  }
  subnet_id                   = aws_subnet.public_zone.id
  key_name                    = "pumpbot"
  associate_public_ip_address = true
  root_block_device {
    volume_type = "gp3"
    volume_size = 8
  }
  user_data = "${data.template_file.user_data.rendered}"
}

data "terraform_remote_state" "lambda" {
  backend = "s3"

  config = {
    bucket = "pumpbot-terraform-states"
    key    = "state_lambda"
    region = var.region
  }
}

module "auto_destroy" {
  source = "git::https://github.com/Jonny1987/terraform-auto-destroy.git//auto_destroy"
  lambda_function_name = data.terraform_remote_state.lambda.outputs.lambda_function_name
  lb_id = aws_instance.load_balancer.id
  lb_max_idle_time_minutes = 5
}
