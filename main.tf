# main.tf - Ressources EC2 TP03

# Data source : AMI Amazon Linux 2023 la plus recente
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# Key Pair SSH
resource "aws_key_pair" "formation" {
  key_name   = "${local.name_prefix}-key"
  public_key = file(pathexpand(var.public_key_path))

  tags = {
    Name     = "${local.name_prefix}-key"
    Etudiant = "etudiant06"
  }
}

# Attendre que les tags de la clé se propagent dans AWS
# (Workaround pour la politique IAM du formateur qui verifie le tag au moment du RunInstances)
resource "time_sleep" "wait_for_keypair_tags" {
  create_duration = "5s"
  depends_on      = [aws_key_pair.formation]
}

# Security Group : web instances
resource "aws_security_group" "web" {
  name        = "${local.name_prefix}-web-sg"
  description = "Allow SSH/HTTP from bastion SG only"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${local.name_prefix}-web-sg"
  }
}

# Ingress rule : SSH depuis SG bastion uniquement
resource "aws_vpc_security_group_ingress_rule" "web_ssh" {
  security_group_id            = aws_security_group.web.id
  description                  = "SSH depuis le bastion"
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.bastion.id
}

# Ingress rule : HTTP depuis SG bastion uniquement
resource "aws_vpc_security_group_ingress_rule" "web_http" {
  security_group_id            = aws_security_group.web.id
  description                  = "HTTP depuis le bastion"
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.bastion.id
}

# Egress rule : tout sortant (pour yum install nginx)
resource "aws_vpc_security_group_egress_rule" "web_all" {
  security_group_id = aws_security_group.web.id
  description       = "Egress all (yum/nginx updates)"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# EC2 Bastion (public subnet, AZ 1)
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public[var.azs[0]].id
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  key_name                    = aws_key_pair.formation.key_name
  associate_public_ip_address = true

  tags = {
    Name     = "bastion_isaie_dns"
    Role     = "bastion"
    Etudiant = "etudiant06"
  }

  depends_on = [time_sleep.wait_for_keypair_tags]
}

# Elastic IP pour le bastion (IP statique)
resource "aws_eip" "bastion" {
  instance = aws_instance.bastion.id
  domain   = "vpc"

  tags = {
    Name = "eip_bastion_isaie_dns"
  }

  depends_on = [aws_internet_gateway.main]
}

# EC2 Web instances (prives, 1 par AZ via for_each)
resource "aws_instance" "web" {
  for_each = local.web_subnets

  ami                         = data.aws_ami.al2023.id
  instance_type               = var.instance_type
  subnet_id                   = each.value
  vpc_security_group_ids      = [aws_security_group.web.id]
  key_name                    = aws_key_pair.formation.key_name
  user_data                   = templatefile("${path.module}/templates/nginx.sh.tftpl", { az = each.key })
  user_data_replace_on_change = true

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name     = "web_isaie_dns_${each.key}"
    Role     = "web"
    AZ       = each.key
    Etudiant = "etudiant06"
  }

  depends_on = [time_sleep.wait_for_keypair_tags]
}
