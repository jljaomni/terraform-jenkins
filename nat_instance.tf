/* # Crear NAT Instances en todas las subnets públicas usando for_each
resource "aws_instance" "nat_instance" {
  ami                    = "ami-0cdfb12db83f3c627"           # AMI de Amazon NAT
  instance_type          = "t3.micro"
  subnet_id              = module.vpc.public_subnets[0]                        # Asigna la subnet pública
  associate_public_ip_address = true
  security_groups        = [aws_security_group.nat_instance_sg.id]
  source_dest_check      = false

  tags = {
    Name = "NAT Instance"
  }
}
  */