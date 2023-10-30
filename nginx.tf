 resource "aws_instance" "Ngninx-instance" {
   ami           = "ami-0dbc3d7bc646e8516" # Specify the AMI ID for your desired operating system
   instance_type = "t2.micro"             # Specify the instance type
   subnet_id     = aws_subnet.subnet1.id   # Specify the subnet ID
   key_name      = "ireland-key"   # If using SSH key pair
   vpc_security_group_ids = [aws_security_group.security.id]
   user_data = <<-EOF
               #!/bin/bash
               sudo -i
               yum install nginx -y
               systemctl start nginx
               systemctl enable nginx
               sed -i '47 i\location / {proxy_pass http://192.168.20.8:8080/student/;}' /etc/nginx/nginx.conf
               systemctl restart nginx

               EOF
     tags = {
     Name = "Ngninx-instannce"
  }
 }