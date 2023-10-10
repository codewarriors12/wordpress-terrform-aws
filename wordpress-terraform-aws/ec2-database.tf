resource "aws_key_pair" "keypair" {
  public_key = file(var.ssh_key)
}

data "template_file" "phpconfig" {
  template = file("files/conf.wp-config.php")

  vars = {
    db_port = aws_db_instance.mysql.port
    db_host = aws_db_instance.mysql.address
    db_user = var.username
    db_pass = var.password
    db_name = var.dbname
  }
}

resource "aws_db_instance" "mysql" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  identifier             = var.dbname
  db_name                = var.dbname
  username               = var.username
  password               = var.password
  parameter_group_name   = "default.mysql5.7"
  vpc_security_group_ids = [aws_security_group.mysql.id]
  db_subnet_group_name   = aws_db_subnet_group.mysql.name
  skip_final_snapshot    = true
}

resource "aws_instance" "wordpress-ec2" {
  ami           = var.ami_id
  instance_type = var.instance_type

#  depends_on = [
#    aws_db_instance.mysql,
#  ]

  key_name                    = aws_key_pair.keypair.key_name
  vpc_security_group_ids      = [aws_security_group.web.id]
  subnet_id                   = aws_subnet.public1.id
  associate_public_ip_address = true

  user_data = file("files/userdata.sh")

  tags = {
    Name = "wordpress-ec2"
  }

  provisioner "file" {
    source      = "files/userdata.sh"
    destination = "userdata.sh"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      host = self.public_ip
      private_key = file(var.ssh_priv_key)
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x userdata.sh",
      "sudo bash userdata.sh",
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      host = self.public_ip
      private_key = file(var.ssh_priv_key)
    }
  }

  provisioner "file" {
    content     = data.template_file.phpconfig.rendered
    destination = "wp-config.php"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      host = self.public_ip
      private_key = file(var.ssh_priv_key)
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo cp wp-config.php /var/www/html/wp-config.php",
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      host = self.public_ip
      private_key = file(var.ssh_priv_key)
    }
  }

  timeouts {
    create = "20m"
  }
}

data "aws_ami" "wordpress-ec2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["Amazon Linux 2*"]
  }
}
