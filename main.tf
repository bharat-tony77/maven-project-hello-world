provider "aws" {
    region = "ap-south-1"
  
}

resource "aws_instance" "tomcat-server" {
  ami = "ami-076754bea03bde973"
  instance_type = "t2.micro"
  subnet_id = "subnet-e724258e"
  key_name = "mykey"
  iam_instance_profile = "role-for-ec2-ssm"

  vpc_security_group_ids = [
    "sg-0e3eaf8b123437980"
  ]

  user_data = <<EOF
#!/bin/bash
yum remove java* -y
sudo yum install java-1.8.0-openjdk.x86_64 -y
cd /opt
wget https://archive.apache.org/dist/tomcat/tomcat-8/v8.5.35/bin/apache-tomcat-8.5.35.tar.gz
tar -xvzf /opt/apache-tomcat-8.5.35.tar.gz
sudo chmod +x /opt/apache-tomcat-8.5.35/bin/*.sh
sudo sh -x /opt/apache-tomcat-8.5.35/bin/startup.sh
EOF


  root_block_device {
    delete_on_termination = true
    volume_size = 10
    volume_type = "gp2"
  }
  tags = {
    Name ="tomcat-server"
    Environment = "DEV"
    Managed = "terraform"
  }
  provisioner "remote-exec" {
    inline = [
      "touch hello.txt",
      "echo helloworld remote provisioner >> hello.txt",
    ]
  }
  connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ec2-user"
      private_key = "${file("/home/ec2-user/mykey.pem")}
      timeout     = "4m"
   }
}
