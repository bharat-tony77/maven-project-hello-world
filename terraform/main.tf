provider "aws" {
    region = ap-south-1
  
}

resource "aws_security_group" "project-iac-sg" {
  name = tomcat-sg
  vpc_id = vpc-ce8cb2a7

  // To Allow SSH Transport
  ingress {
    from_port = 8080
    protocol = "tcp"
    to_port = 8080
    cidr_blocks = ["0.0.0.0/0"]
  }

  // To Allow Port 80 Transport
  ingress {
    from_port = 80
    protocol = ""
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
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


resource "aws_instance" "tomcat-server" {
  ami = ami-0749d3be2b2eb3873
  instance_type = t2.micro
  subnet_id = subnet-e724258e
  associate_public_ip_address = lookup(var.awsprops, "publicip")
  key_name = mykey


  vpc_security_group_ids = [
    sg-0e3eaf8b123437980
  ]
  root_block_device {
    delete_on_termination = true
    iops = 150
    volume_size = 10
    volume_type = "gp2"
  }
  tags = {
    Name ="tomcat-server"
    Environment = "DEV"
    Managed = "IAC"
  }

}
