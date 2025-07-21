provider "aws" {
  region  = "ap-southeast-1"
  profile = "default"
}

resource "aws_iam_user" "deploy_user" {
  name = "lambda-deployer"
}

resource "aws_iam_user_policy_attachment" "deploy_policy" {
  user       = aws_iam_user.deploy_user.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_access_key" "deploy_user_key" {
  user = aws_iam_user.deploy_user.name
}

output "access_key_id" {
  value     = aws_iam_access_key.deploy_user_key.id
  sensitive = true
}

output "secret_access_key" {
  value     = aws_iam_access_key.deploy_user_key.secret
  sensitive = true
}
