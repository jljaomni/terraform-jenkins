# Crear NAT Instances en todas las subnets públicas usando for_each
resource "aws_instance" "nat_instance" {
  for_each               = toset(module.vpc.public_subnets) # Recorre todas las subnets públicas
  ami                    = "ami-02c21308fed24a8ab"           # AMI de Amazon Linux 2, puedes ajustar esta AMI según tu región
  instance_type          = "t3.micro"
  subnet_id              = each.value                        # Asigna la subnet pública
  associate_public_ip_address = true
  security_groups        = [aws_security_group.nat_sg.id]

  # Configuración para habilitar el reenvío de IPs
  user_data = <<-EOF
              #!/bin/bash
              sudo sysctl -w net.ipv4.ip_forward=1
              sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
              EOF

  tags = {
    Name = "NAT Instance ${each.key}"
  }
}
