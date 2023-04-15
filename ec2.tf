
resource "aws_instance" "test-instance" {
  ami = lookup(var.awsprops, "ami")
  instance_type = lookup(var.awsprops, "itype")
  subnet_id = aws_subnet.subnet_public.id
  key_name = local_file.tf-key.filename


  vpc_security_group_ids = [
    aws_security_group.leumi_SG.id
  ]
  
  root_block_device {
    delete_on_termination = true
    volume_size = 50
    volume_type = "gp2"
  }
  depends_on = [ aws_security_group.leumi_SG ]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl enable httpd
              systemctl start httpd
              EOF

  tags = {
    Name = "TEST EC2"
  }
}




