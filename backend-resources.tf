# resource "aws_s3_bucket" "terraform_state" {
#   bucket = "terraform-state-example-4532423423423"

#   lifecycle {
#     prevent_destroy = true
#   }

#   tags = {
#     Name = "Terraform State Bucket"
#   }
# }

# resource "aws_dynamodb_table" "terraform_locks" {
#   name         = "terraform-example-locks"
#   billing_mode = "PAY_PER_REQUEST"
#   hash_key     = "LockID"

#   attribute {
#     name = "LockID"
#     type = "S"
#   }

#   lifecycle {
#     prevent_destroy = true
#   }

#   tags = {
#     Name = "Terraform DynamoDB Table"
#   }
# }
