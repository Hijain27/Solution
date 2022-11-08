terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
}

provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = "ap-south-1"
}

#module
module "networkModule" {
  source             = "../modules/networking"
  ProjectName        = "HimanshuJain"
  aws_key_name       = "test"
  public_subnets = ["10.0.2.0/24", "10.0.3.0/24","10.0.8.0/24"]
  private_subnets = ["10.0.4.0/24", "10.0.5.0/24","10.0.9.0/24"]
  db_private_subnets = ["10.0.6.0/24","10.0.7.0/24","10.1.8.0/24"]
}

module "ApplicationServer" {
  source = "../modules/application"
  app_sg = module.networkModule.app_sg
  instance_type = "t2.micro"
  key_name = "test"
  private_subnets = module.networkModule.public_subnets
  tags = null

}

module "DBServer" {
  source = "../modules/database"
  db_sg = module.networkModule.db_sg
  instance_type = "t2.micro"
  key_name = "test"
  db_private_subnets = module.networkModule.private_subnets_db
  tags = null
}

module "webServer" {
  source = "../modules/web"
  instance_type  = "t2.micro"
  key_name       = "test"
  public_subnets = module.networkModule.public_subnets
  web_sg         = module.networkModule.web_sg
  tags = null
}
