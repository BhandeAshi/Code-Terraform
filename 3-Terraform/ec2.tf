output "ec2_instance_private_ip" {
  value = aws_instance.tomcat-instance.private_ip
}


 resource "aws_instance" "tomcat-instance" {
  ami           = "ami-0dab0800aa38826f2" # Specify the AMI ID for your desired operating system
  instance_type = "t2.micro"             # Specify the instance type
  subnet_id     = aws_subnet.subnet2.id   # Specify the subnet ID

  key_name      = "ireland-key"   # If using SSH key pair
  # Other instance configuration options
  vpc_security_group_ids = [aws_security_group.security.id]

  user_data  = <<-EOF
               #!/bin/bash
               yum install java -y
               wget https://dlcdn.apache.org/tomcat/tomcat-8/v8.5.95/bin/apache-tomcat-8.5.95.tar.gz
               tar -xvf apache-tomcat-8.5.95.tar.gz -C /opt
               wget https://s3-us-west-2.amazonaws.com/studentapi-cit/mysql-connector.jar
               cp mysql-connector.jar /opt/apache-tomcat-8.5.95/lib
               wget https://s3-us-west-2.amazonaws.com/studentapi-cit/student.war
               cp student.war /opt/apache-tomcat-8.5.95/webapps
               sed -i '20 i\<Resource name="jdbc/TestDB" auth="Container" type="javax.sql.DataSource" maxTotal="100" maxIdle="30" maxWaitMillis="10000" username="admin" password="test12345" driverClassName="com.mysql.jdbc.Driver" url="jdbc:mysql://database-1.cktv4tcufrmx.eu-west-1.rds.amazonaws.com:3306/studentapp"/>' /opt/apache-tomcat-8.5.95/conf/context.xml
               cd /opt/apache-tomcat-8.5.95/bin
               ./shutdown.sh
               ./startup.sh
               EOF

  tags = {
    Name = "tomcat-instance"
  }
}
 resource "aws_instance" "RDS-instance" {
   ami           = "ami-0dab0800aa38826f2" # Specify the AMI ID for your desired operating system
   instance_type = "t2.micro"             # Specify the instance type
   subnet_id     = aws_subnet.subnet3.id   # Specify the subnet ID
   key_name      = "ireland-key"   # If using SSH key pair
   vpc_security_group_ids = [aws_security_group.security.id]
   user_data = <<-EOF
               #!/bin/bash
               sudo -i
               sudo yum install mariadb105-server -y
               sudo systemctl start mariadb
               sudo systemctl enable mariadb
               # MySQL/MariaDB connection parameters
               DB_USER="admin"
               DB_PASSWORD="test12345"
               DB_NAME="studentapp"
               TABLE_NAME="students"
               mysql -u $DB_USER -h database-1.cktv4tcufrmx.eu-west-1.rds.amazonaws.com -p$DB_PASSWORD <<EOF
               CREATE DATABASE IF NOT EXISTS $DB_NAME;
               USE $DB_NAME;
               CREATE TABLE IF NOT EXISTS $TABLE_NAME (student_id INT NOT NULL AUTO_INCREMENT,student_name VARCHAR(100) NOT NULL,student_addr VARCHAR(100) NOT NULL,student_age VARCHAR(3) NOT NULL,student_qual VARCHAR(20) NOT NULL,student_percent VARCHAR(10) NOT NULL,student_year_passed VARCHAR(10) NOT NULL,PRIMARY KEY (student_id));
               EOF
   tags = {
     Name = "RDS"
   }
 }
