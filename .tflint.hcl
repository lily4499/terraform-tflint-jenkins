plugin "aws" {
  enabled = true
  version = "0.19.0" # Replace with the correct version if necessary
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

rule "aws_instance_invalid_type" {
  enabled = true
}


