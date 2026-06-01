module "vpc" {
    source                  = "git::https://github.com/gsurendhar/terraform-aws-vpc-module.git?ref=master"
    # source                  = "../../terraform-aws-vpc-module"
    project                 = var.project
    environment             = var.environment
    public_subnet_cidrs     = var.public_subnet_cidrs
    private_subnet_cidrs    = var.private_subnet_cidrs
    database_subnet_cidrs   = var.database_subnet_cidrs
    is_peering_required     = var.is_peering_required
    is_NAT_required         = var.is_NAT_required

}
