terraform {

    backend "s3" {
        bucket = "statefiles-bucket"
        key = "my-terraform-project"
        dynamodb_table = "statefiles-lock-table"

    }





  required_providers {

    aws = {
    source="hashicorp/aws"

    }

  }
}


provider aws {}



module "aws-vpc" {
    source = "./module/vpc-module"
   
}


module "alb" {
    source = "./module/elb-module"

    public_subnets = module.aws-vpc.public_subnets
    vpc-id = module.aws-vpc.vpc_id
    private_subnets = module.aws-vpc.private_subnets
   
    
}

module "role" {
    source = "./module/ec2-role-module"
}

module "launch_temp" {
    source = "./module/launch-module"

    depends_on = [ module.aws-vpc.private_subnets ]

    
    vpc-id = module.aws-vpc.vpc_id
    

    private_subnets =module.aws-vpc.private_subnets
    lb-arn = module.alb.alb_arn
    profile = module.role.instance_profile
    tg_arn = module.alb.tg_arn
    lb-sg= module.alb.lb-sg
    
}


module "route_53" {
  source = "./module/route53-module"

  lb_name =module.alb.alb_name
  hosted_zone =module.alb.alb_hosted_zone
  dns_name =module.alb.dns_name
}