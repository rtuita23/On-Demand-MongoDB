# Create an EC2 instance
# Install docker engine
# Download MongoDB docker image
# Run MongoDB container

provider "aws" {
    version = "~> 1.5"

    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    #region     = "us-east-1"
    region      = "${var.aws_region}"
}

resource "aws_security_group" "instance" {
  name        = "mongodb"
  description = "Allow all inbound traffic"

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "docker-mongodb" {
  ami                    = "ami-3dec9947"
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]
  key_name               = "my_dbaas_key"
  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = "${file("my_dbaas_key.pem")}"
  }
  provisioner "remote-exec" {
    inline = [
      "curl -fsSL get.docker.com -o get-docker.sh",
      "sudo sh get-docker.sh",
      "sudo docker pull mongo",
      "sudo docker container run --name mongo_dbaas -d mongo"
    ]
  }

  tags {
    Name = "MongoDB Server"
  }
}

output "public_ip" {
  value = "${aws_instance.docker-mongodb.public_ip}"
}