resource "aws_security_group" "my-ec2" {
  name        = "Jenkins-Security Group"
  description = "Open 22,443,80,9000,3000"

  # Define a single ingress rule to allow traffic on all specified ports
  ingress = [
    for port in [22, 80, 443, 9000, 3000] : {
      description      = "TLS from VPC"
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
    Name = "my-ec2"
  }
}

data "aws_ami" "selected" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"] 
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"] 
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.selected.id
  instance_type          = "t2.medium"
  key_name               = "DT_F"
  vpc_security_group_ids = [aws_security_group.my-ec2.id]
  user_data              = templatefile("./script.sh", {})

  tags = {
    Name = "swiggy-base-server"
  }

  root_block_device {
    volume_size = 30
  }
}

