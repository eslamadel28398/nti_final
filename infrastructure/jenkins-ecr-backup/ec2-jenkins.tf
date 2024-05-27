# Configure the AWS Provider
provider "aws" {
  region = var.region # Change to your desired region
}

# Create VPC
resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true

  tags = {
    Name = "main-vpc"
  }
}
# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

# Create Public Subnet
resource "aws_subnet" "pub_sub1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.sub1_cidr
  availability_zone       = var.az1 # Change to your desired AZ
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet1"

  }
}

# Connect Public Subnet to Internet Gateway
resource "aws_route_table" "rt_public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = var.rt_cidr
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "rt_association1" {
  subnet_id      = aws_subnet.pub_sub1.id
  route_table_id = aws_route_table.rt_public.id
}

# create jenkins sg
resource "aws_security_group" "jenkins-sg" {
  name        = "jenkins-sg"
  description = "SSH Access"
  vpc_id = aws_vpc.main.id 
  
  ingress {
    description      = "SHH access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.rt_cidr]
    }

    ingress {
    description      = "Jenkins port"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = [var.rt_cidr]
    }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [var.rt_cidr]
  }

  tags = {
    Name = "ssh-prot"

  }
}

# Key Pair
resource "aws_key_pair" "my_key_pair" {
  key_name   = "my_key_pair"
  public_key = var.public_key # Replace with your public key
}



# Public Instance1
resource "aws_instance" "jenkins_master1" {
  ami           = var.ami # Change to your desired AMI
  instance_type = "t3.medium"
  root_block_device {
    volume_size = 100
  }
  subnet_id     = aws_subnet.pub_sub1.id
  vpc_security_group_ids = [aws_security_group.jenkins-sg.id]
  key_name      = aws_key_pair.my_key_pair.key_name


  tags = {
    Name = "jenkins_master1"
  }
}

# backup of jenkins instance 



resource "aws_backup_vault" "jenkins_backup_vault" {
  name        = "jenkins-backup-vault"
#   kms_key_arn = "arn:aws:kms:your-region:your-account-id:key/your-key-id"  # Optional, for encryption
}

resource "aws_backup_plan" "jenkins_backup_plan" {
  name = "jenkins-daily-backup-plan"

  rule {
    rule_name         = "daily-backup-rule"
    target_vault_name = aws_backup_vault.jenkins_backup_vault.name
    schedule          = "cron(0 0 * * ? *)"  # Daily at midnight UTC

    lifecycle {
      delete_after = 30  # Retain backups for 30 days
    }

    recovery_point_tags = {
      "CreatedBy" = "Terraform"
    }
  }
}

resource "aws_iam_role" "backup_role" {
  name = "aws_backup_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "backup.amazonaws.com"
        },
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "backup_role_policy_attachment" {
  role       = aws_iam_role.backup_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_backup_selection" "jenkins_backup_selection" {
  name          = "jenkins-backup-selection"
  iam_role_arn  = aws_iam_role.backup_role.arn
  plan_id = aws_backup_plan.jenkins_backup_plan.id

  resources = [
    aws_instance.jenkins_master1.arn
      ]
}


resource "aws_ecr_repository" "ECR1" {
  name                 = "nti-frontend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "ECR2" {
  name                 = "nti-backend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}