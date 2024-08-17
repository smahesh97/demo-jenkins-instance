resource "aws_instance" "web" {
  ami                    = var.ami      
  instance_type          = var.instance_type
  key_name               = var.key_name
  iam_instance_profile   = var.iam_role              
  vpc_security_group_ids = [aws_security_group.Jenkins-VM-SG1.id]
  user_data              = templatefile("./installer.sh", {})

  tags = {
    Name = "Jenkins-SonarQube"
  }

  root_block_device {
    volume_size = 40
  }
}
resource "aws_ecr_repository" "int-demo" {
  name                 = "int-demo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_security_group" "Jenkins-VM-SG1" {
  name        = "Jenkins-VM-SG1"
  description = "Allow TLS inbound traffic"

  ingress = [
    for port in [22, 80, 443, 8080, 9000, 3000] : {
      description      = "inbound rules"
      from_port        = port
      to_port          = port
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Jenkins-VM-SG1"
  }
}

