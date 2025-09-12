terraform {
  backend "s3" {
    bucket         = "stcok-market-bucket"
    key            = "env/policy/terraform.tfstate"
    region         = "eu-west-2"   
  }
}