provider "aws" {
  region = "us-east-1"  # N.Virginia
}

resource "aws_instance" "Controller" {
  ami           = ""  #Standard AWS Build
  instance_type = "t2.micro"  #Cheap server
  key_name      = ""

  tags          = {
    Name  =  "Terraform test - Controller"
    Shutdown = "24-Aug-2023-10:00:00"
  }
  user_data = file("jmeter_setup_script.sh")

 provisioner "remote-exec" {
    inline = [
      "sudo mkdir /performance_testing",
      "sudo chmod 777 /performance_testing"
    ]
   
    connection {
    type        = "ssh"
    user        = "ec2-user"  # Change to the appropriate user for your AMI
    private_key = file("~/.ssh/id_rsa")  # Update with the path to your SSH private key
    host        = aws_instance.Controller.public_ip
    }
  } 

   provisioner "file" {
        source      = "../jmeter_demo_test/"
        destination = "/performance_testing/"
      
    connection {
    type        = "ssh"
    user        = "ec2-user"  # Change to the appropriate user for your AMI
    private_key = file("~/.ssh/id_rsa")  # Update with the path to your SSH private key
    host        = aws_instance.Controller.public_ip
    }
  } 
}
#################################
#INJECTORS
#################################
resource "aws_instance" "Injectors" {
  ami           = ""  #Standard AWS Build
  instance_type = "t2.micro"  #Cheap server
  key_name      = ""
  count         =  2

  tags          = {
    Name  =  "Terraform test - Injector"
    Shutdown = "24-Aug-2023-10:00:00"
  }
  user_data = file("jmeter_setup_script.sh")

 provisioner "remote-exec" {
    inline = [
      "sudo mkdir /performance_testing",
      "sudo chmod 777 /performance_testing"
    ]
    connection {
    type        = "ssh"
    user        = "ec2-user"  # Change to the appropriate user for your AMI
    private_key = file("~/.ssh/id_rsa")  # Update with the path to your SSH private key
    host        = aws_instance.Controller.public_ip
    }
  } 
 
   provisioner "file" {
        source      = "../jmeter_demo_test/"
        destination = "/performance_testing/"
      
    connection {
    type        = "ssh"
    user        = "ec2-user"  # Change to the appropriate user for your AMI
    private_key = file("~/.ssh/id_rsa")  # Update with the path to your SSH private key
    host        = aws_instance.Controller.public_ip
    }
  } 
}
