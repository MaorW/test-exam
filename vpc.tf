/* VPC */
resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_vpc
  enable_dns_support   = true
  enable_dns_hostnames = true


  variable "vpc_id" {}

  data "aws_vpc" "selected" {
    id = var.vpc_id
  }
}

/* Internet Gateway */
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

/* Public Subnet */
resource "aws_subnet" "subnet_public" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.cidr_subnet
}

/* Route Table */
resource "aws_route_table" "rtb_public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "rta_subnet_public" {
  subnet_id      = aws_subnet.subnet_public.id
  route_table_id = aws_route_table.rtb_public.id
}

/* Security Group */
resource "aws_security_group" "leumi_SG" {
  name = lookup(var.awsprops, "secgroupname")
  vpc_id = aws_vpc.vpc.id
  tags = {
    "Name" = "Leumi http access"
  }

  // Allow SSH Transport
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["147.235.220.59/32"]
  }

  // Allow Port 80 for Leumi's IP
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["91.231.246.50/32"]
  }
  
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["147.235.220.59/32"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

/* Elastic IP */
resource "aws_eip" "test-eip" {
  vpc = true

  tags = {
    Name = "Test EC2 eip"
  }
}

/* Network Load Balancer */
resource "aws_lb" "test-nlb" {
  name = "test-spoke-nlb"
  internal = false
  load_balancer_type = "network"
}  

# NLB TEST target group
resource "aws_lb_target_group" "nlb-tg" {
  port = 80
  protocol = "TCP"
  vpc_id = data.aws_vpc.vpc.id

  health_check {
    interval            = 30
    timeout             = 10
    unhealthy_threshold = 2
    protocol            = "TCP"
  }
}

# nlb listener attachment
resource "aws_lb_listener" "nlb_listener" {
  load_balancer_arn = aws_lb.test-nlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb-tg.arn
  }
}

# nlb-target-group-attachment
resource "aws_lb_target_group_attachment" "nlb-tg-attachment" {
  target_group_arn = aws_lb_target_group.nlb-tg.arn
  target_id = aws_eip.test-eip.id
  port = 80
}

/* Key_Pair */
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "tf-key-pair" {
  key_name   = lookup(var.awsprops, "keyname")
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "local_file" "tf-key" {
  content  = tls_private_key.rsa.private_key_pem
  filename = aws_key_pair.tf-key-pair.key_name
}
