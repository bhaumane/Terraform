terraform {
  backend "s3" {
    bucket = "my-terraform-start-bucket"
    key = "global/s3/terraform.tfstate"
    region = "us-west-2"
    use_lockfile = true
    
  }
}