# terraform-jenkins

Primero se aplica la infraestructura de la VPC con el siguiente comando. Esto debido a la montura del EFS 

terraform apply -target=module.vpc -auto-approve 

Luego se aplica toda la infraestructura completa

terraform apply -auto-approve