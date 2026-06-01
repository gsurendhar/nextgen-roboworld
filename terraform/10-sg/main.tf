#  creating SG for bastion host to connection from laptops
module "bastion" {
  # source          = "../../terraform-aws-security-group-module"
  source         = "git::https://github.com/gsurendhar/terraform-aws-security-group-module.git?ref=master"
  project        = var.project
  environment    = var.environment
  sg_name        = "bastion"
  sg_description = "created sg for bastion instances"
  # vpc_id          = data.aws_ssm_parameter.vpc_id.value
  vpc_id         = local.vpc_id
}

#  creating SG for VPN to connection from laptop
module "vpn" {
  source         = "git::https://github.com/gsurendhar/terraform-aws-security-group-module.git?ref=master"
  project        = var.project
  environment    = var.environment
  sg_name        = "vpn"
  sg_description = "created sg for vpn"
  vpc_id         = local.vpc_id
}

#  creating SG for ingress-alb to connection from bastion and vpn
module "ingress_alb" {
  source         = "git::https://github.com/gsurendhar/terraform-aws-security-group-module.git?ref=master"
  project        = var.project
  environment    = var.environment
  sg_name        = "ingress_alb"
  sg_description = "created sg for ingress load balancer"
  vpc_id         = local.vpc_id
}

#  creating SG for eks_control_plane to connection from bastion and vpn
module "eks_control_plane" {
  source         = "git::https://github.com/gsurendhar/terraform-aws-security-group-module.git?ref=master"
  project        = var.project
  environment    = var.environment
  sg_name        = "eks_control_plane"
  sg_description = "created sg for eks_control_plane"
  vpc_id         = local.vpc_id
}

#  creating SG for eks_node to connection from bastion and vpn
module "eks_node" {
  source         = "git::https://github.com/gsurendhar/terraform-aws-security-group-module.git?ref=master"
  project        = var.project
  environment    = var.environment
  sg_name        = "eks_node"
  sg_description = "created sg for eks_node"
  vpc_id         = local.vpc_id
}



# BASTION accepting connections from my laptop
resource "aws_security_group_rule" "bastion_laptop" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.bastion.sg_id
}

# VPN connection to open 22,443,943,1194 ports 
resource "aws_security_group_rule" "vpn_ports" {
  count             = length(var.vpn_ports)
  type              = "ingress"
  from_port         = var.vpn_ports[count.index]
  to_port           = var.vpn_ports[count.index]
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.vpn.sg_id
}

#  ingress_alb accepting connections from internet 443 port 
resource "aws_security_group_rule" "ingress_alb_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.ingress_alb.sg_id

}
#  eks_node accepting connections from eks_control_plane 
resource "aws_security_group_rule" "eks_node_to_eks_control_plane" {
  type      = "ingress"
  from_port = 0
  to_port   = 0
  protocol  = "-1"
  source_security_group_id = module.eks_control_plane.sg_id
  security_group_id = module.eks_node.sg_id
}

#  eks_control_plane accepting connections from eks_node 
resource "aws_security_group_rule" "eks_control_plane_to_eks_node" {
  type      = "ingress"
  from_port = 0
  to_port   = 0
  protocol  = "-1"
  source_security_group_id = module.eks_node.sg_id
  security_group_id = module.eks_control_plane.sg_id
}

#  eks_node accepting connections from bastion
resource "aws_security_group_rule" "eks_node_to_bastion" {
  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id = module.eks_node.sg_id
}

#  eks_control_plane accepting connections from bastion 
resource "aws_security_group_rule" "eks_control_plane_to_bastion" {
  type      = "ingress"
  from_port = 443
  to_port   = 443
  protocol  = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id = module.eks_control_plane.sg_id
}

#  eks_node accepting connections vpc nodes
resource "aws_security_group_rule" "eks_node_to_vpc" {
  type      = "ingress"
  from_port = 0
  to_port   = 0
  protocol  = "-1"
  cidr_blocks       = ["10.0.0.0/16"]
  security_group_id = module.eks_node.sg_id
}
