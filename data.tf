data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "stcok-market-bucket"
    key    = "env/dev/terraform.tfstate"
    region = "eu-west-2"
  }
}
