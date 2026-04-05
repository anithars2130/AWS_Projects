# 🏗️ Highly Available Web Application on AWS (Manual + Terraform)

---

## 📌 Project Overview

This project demonstrates the design and implementation of a **Highly Available Web Application** on AWS using both:

- **Manual setup**  
- **Terraform (Infrastructure as Code)**  

### 🔧 Key Features

- Multi-AZ deployment with **public and private subnets**  
- **Application Load Balancer (ALB)** for traffic distribution  
- **Auto Scaling Group (ASG)** for high availability  
- **RDS MySQL database** in private subnet  
- Terraform **import and validation** of existing resources  

---

## 🏛️ Architecture Overview

**3-tier design**:

- **Web Layer** → EC2 instances in public subnets behind ALB  
- **Application Layer** → Auto Scaling Group for scalability and fault tolerance  
- **Database Layer** → RDS MySQL in private subnets  

**Benefits**:

- High Availability & Fault Tolerance  
- Secure Network Isolation  

**Diagram**:

![Architecture Diagram](03_Documentation/screenshots/architecture.png) 

---

## 🌐 VPC & Subnet Configuration

**VPC**:

- CIDR: `10.0.0.0/16`  
- Name: **ANI-HA-VPC**  

**Public Subnets**:

| Subnet | CIDR | AZ |
|--------|------|----|
| ANI-Public-Subnet-1 | 10.0.1.0/24 | us-east-1a |
| ANI-Public-Subnet-2 | 10.0.2.0/24 | us-east-1b |

**Private Subnets**:

| Subnet | CIDR | AZ |
|--------|------|----|
| ANI-Private-Subnet-1 | 10.0.101.0/24 | us-east-1a |
| ANI-Private-Subnet-2 | 10.0.102.0/24 | us-east-1b |

**Notes**:

- Public subnets host **web servers** and **ALB**  
- Private subnets host **RDS**  
- Multi-AZ design ensures **high availability**

---

## 🔌 Internet Gateway & Routing

- **Internet Gateway**: ANI-Project1-IGW  
- **Route Table**: ANI-Public-RT  
- Route: `0.0.0.0/0 → IGW`  
- Public subnets associated with this route table; private subnets not associated  

---

## 🔐 Security Groups

### Web SG (ANI-Web-SG)

- SSH (22) → `0.0.0.0/0`  
- HTTP (80) → `0.0.0.0/0`  

### ALB SG (ANI-ALB-SG)

- HTTP (80) → `0.0.0.0/0`  

### RDS SG (ANI-RDS-SG)

- MySQL (3306) → Source: ANI-Web-SG  

**Principle**: Least privilege access; backend access restricted.

---

## 💻 EC2 Instances

| Instance | Subnet | Type | AMI | Security Group |
|----------|--------|------|-----|----------------|
| ANI-EC2-Web-1 | ANI-Public-Subnet-1 | t3.micro | Amazon Linux 2 | ANI-Web-SG |
| ANI-EC2-Web-2 | ANI-Public-Subnet-2 | t3.micro | Amazon Linux 2 | ANI-Web-SG |

- **Purpose**: Hosts web application  
- **Public subnets** allow internet access  
- Integrated with **ALB**  

---

## ⚖️ Application Load Balancer

- **Name**: ANI-HA-ALB  
- **Scheme**: Internet-facing  
- **Listener**: HTTP (80)  
- **Target Group**: ANI-TG → EC2 instances  

**Function**: Distributes traffic across EC2 instances for high availability.

---

## 🔁 Auto Scaling Group

- **Launch Template**: ANI-WebServer-LT (pre-installed Apache)  
- **ASG Name**: ANI-ASG  
- **Subnets**: Public Subnets 1 & 2  
- **Desired Instances**: 2 (min: 1, max: 2)  
- **Instance Maintenance Policy**: Launch before terminating  

**Functionality**: Auto-healing and maintaining desired EC2 count.

---

## 🗄️ RDS Database

- **Engine**: MySQL (Free Tier)  
- **Instance Type**: db.t2.micro  
- **Subnets**: Private  
- **Security**: Accessible only from Web SG  
- **Public Access**: Disabled  

---

## ⚙️ Terraform Overview

- **Purpose**: Import manually created resources to manage and validate using Terraform  
- **Key Resources**: VPC, Subnets, IGW, Route Tables, SGs, EC2, ALB, ASG, RDS  
- **Why Import**: Avoids accidental changes while maintaining IAC for tracking and future automation

### Terraform Import Commands (Single Block)

```bash
# VPC
terraform import aws_vpc.my_vpc vpc-08f1d66138f91f57d

# Subnets
terraform import aws_subnet.public_1 subnet-00a49659cbc865308
terraform import aws_subnet.public_2 subnet-0981171c3b671c1ca
terraform import aws_subnet.private_1 subnet-0fc57785caef6cb04
terraform import aws_subnet.private_2 subnet-08691c9b7a92cda08

# Internet Gateway
terraform import aws_internet_gateway.igw igw-0c23330288e89f541

# Route Tables
terraform import aws_route_table.public_rt rtb-02edef0533d87a058
terraform import aws_route_table_association.public1 subnet-00a49659cbc865308/rtb-02edef0533d87a058
terraform import aws_route_table_association.public2 subnet-0981171c3b671c1ca/rtb-02edef0533d87a058

# Security Groups
terraform import aws_security_group.web_sg sg-09323f0dda300dc88
terraform import aws_security_group.alb_sg sg-03dce14031eeb529d
terraform import aws_security_group.rds_sg sg-01e689a49729dfdec

# Launch Template
terraform import aws_launch_template.web_lt lt-0eae95cbc212a86ad

# Auto Scaling Group
terraform import aws_autoscaling_group.web_asg ANI-ASG

# EC2 Instances
terraform import aws_instance.web1 i-048aba6e45a49a4e4
terraform import aws_instance.web2 i-0c10274dde650c4e5

# Application Load Balancer
terraform import aws_lb.web_alb arn:aws:elasticloadbalancing:us-east-1:247842832518:loadbalancer/app/ANI-ALB/93735a8c691e0628
terraform import aws_lb_target_group.tg arn:aws:elasticloadbalancing:us-east-1:247842832518:targetgroup/ANI-TG/413d710d405507b5
terraform import aws_lb_listener.listener arn:aws:elasticloadbalancing:us-east-1:247842832518:listener/app/ANI-ALB/93735a8c691e0628/97ac0b14f428b79b

# RDS
terraform import aws_db_subnet_group.rds_subnet ani-db-subnet-group
terraform import aws_db_instance.my_rds ani-db

📊 Summary Metrics

| Resource        | Count |
| --------------- | ----- |
| EC2 Instances   | 2     |
| RDS             | 1     |
| ALB             | 1     |
| Public Subnets  | 2     |
| Private Subnets | 2     |

## 🖼️ Screenshots & Documentation

### Manual Setup Screenshots
- Screenshots of AWS Console resources (VPC, Subnets, EC2, ALB, RDS, Security Groups, IGW, Route tables) are in:
`01_Manual_Setup/screenshots/`

### Terraform Screenshots
- Screenshots showing Terraform outputs, `terraform plan`, import commands are in:
`03_Documentation/screenshots/`

> These screenshots serve as **proof of manual setup and Terraform validation**.

## 📄 Documentation

Detailed project documentation is available in PDF format:

- [Project 1 Documentation](03_Documentation/Project1_documentation.pdf)


🚀 Project Outcome
Highly available architecture deployed on AWS
Manual setup validated with Terraform
Fault tolerance via ASG and Multi-AZ deployment
Secure backend via private subnets and SGs
Demonstrated Terraform import and drift handling

🌟 Future Improvements
Add HTTPS using ACM
Full Terraform automation (apply + destroy)
CI/CD pipeline integration
CloudWatch monitoring for infrastructure health
