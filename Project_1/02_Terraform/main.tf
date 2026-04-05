# ==============================
# Provider
# ==============================
provider "aws" {
  region = "us-east-1"
}

# ==============================
# VPC
# ==============================
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "ANI-HA-VPC"
  }
}

# ==============================
# Public Subnets
# ==============================
resource "aws_subnet" "public_1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = { Name = "ANI-Public-Subnet-1" }
}

resource "aws_subnet" "public_2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = { Name = "ANI-Public-Subnet-2" }
}

# ==============================
# Private Subnets
# ==============================
resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "us-east-1a"

  tags = { Name = "ANI-Private-Subnet-1" }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = "us-east-1b"

  tags = { Name = "ANI-Private-Subnet-2" }
}

# ==============================
# Security Groups
# ==============================
resource "aws_security_group" "web_sg" {
  name        = "ANI-Web-SG"
  description = "Allow HTTP/HTTPS inbound"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "ANI-Web-SG" }
}

resource "aws_security_group" "alb_sg" {
  name        = "ANI-ALB-SG"
  description = "Allow inbound from internet to ALB"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "ANI-ALB-SG" }
}

resource "aws_security_group" "rds_sg" {
  name        = "ANI-RDS-SG"
  description = "Allow MySQL access from Web servers"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port                = 3306
    to_port                  = 3306
    protocol                 = "tcp"
    security_groups          = [aws_security_group.web_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "ANI-RDS-SG" }
}

# ==============================
# Internet Gateway & Route Table
# ==============================
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = { Name = "ANI-IGW" }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "ANI-Public-RT" }
}

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public_rt.id
}

# ==============================
# Web EC2 Instances (for import/testing)
# ==============================
resource "aws_instance" "web1" {
  ami                    = var.web_ami
  instance_type          = var.web_instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.public_1.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = { Name = "ANI-EC2-Web-1" }
}

resource "aws_instance" "web2" {
  ami                    = var.web_ami
  instance_type          = var.web_instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.public_2.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = { Name = "ANI-EC2-Web-2" }
}

# ==============================
# Launch Template
# ==============================
resource "aws_launch_template" "web_lt" {
  name                  = "ani-webserver-lt"
  image_id              = var.web_ami
  instance_type         = var.web_instance_type
  key_name              = var.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]
}

# ==============================
# Auto Scaling Group
# ==============================
resource "aws_autoscaling_group" "web_asg" {
  name                      = "ani-asg"
  launch_template {
    id      = aws_launch_template.web_lt.id
    version = "$Latest"
  }
  min_size                  = 1
  max_size                  = 2
  desired_capacity          = 2
  vpc_zone_identifier       = [aws_subnet.public_1.id, aws_subnet.public_2.id]
  health_check_type         = "EC2"
  wait_for_capacity_timeout = "10m"
}

# ==============================
# ALB, Target Group, Listener
# ==============================
resource "aws_lb" "web_alb" {
  name               = "ani-ha-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_1.id, aws_subnet.public_2.id]
}

resource "aws_lb_target_group" "tg" {
  name     = "ani-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

# ==============================
# RDS
# ==============================
resource "aws_db_subnet_group" "rds_subnet" {
  name        = "ani-rds-subnet-group"
  description = "Managed by Terraform"
  subnet_ids  = [aws_subnet.private_1.id, aws_subnet.private_2.id]

  tags = { Name = "ani-rds-subnet-group" }
}

resource "aws_db_instance" "my_rds" {
  identifier             = "ani-db"
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  username               = var.db_username
  password               = var.db_password
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet.name
}

# ==============================
# Outputs
# ==============================
output "web1_public_ip" {
  value = aws_instance.web1.public_ip
}

output "web2_public_ip" {
  value = aws_instance.web2.public_ip
}

output "alb_dns" {
  value = aws_lb.web_alb.dns_name
}

output "rds_endpoint" {
  value = aws_db_instance.my_rds.endpoint
}