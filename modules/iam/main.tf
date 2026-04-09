provider "aws" {
  region = "eu-west-2"
}

resource "aws_iam_user" "myUser" {
    name = "Bhaurao"  
}

resource "aws_s3_bucket" "bucket" {
    bucket = "my_s3_bucket"
}

resource "aws_iam_policy" "customePolicy" {
    name = "CustomePolicyName"
    policy = <<EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
            "Action": [
                "s3:ListAllMyBuckets"
            ],
            "Effect": "Allow",
            "Resource": "*"
            },
            {
            "Action": [
                "s3:*"
            ],
            "Effect": "Allow",
            "Resource": "${aws_s3_bucket.bucket.arn}"
            }
        ]
    }
    EOF
}

resource "aws_iam_user_policy_attachment" "attachment" {
  user = aws_iam_user.myUser.name
  policy_arn = aws_iam_policy.customePolicy.arn
}