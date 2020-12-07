

# Necessary permissions for ec2 instance to read other instances
resource "aws_iam_role" "iam_for_ec2" {
  name               = "iam_for_ec2"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  tags               = var.tags
}


resource "aws_iam_policy" "iperf_ec2_policy" {
  name        = "iperf-ec2-access"
  path        = "/"
  description = "permissions to read ec2 and create tags"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:CreateTags",
        "ec2:Describe*",
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

# attach policies
resource "aws_iam_role_policy_attachment" "policy_attachment" {
  role       = aws_iam_role.iam_for_ec2.name
  policy_arn = aws_iam_policy.iperf_ec2_policy.arn
}

# creating ec2 instance profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_access"
  role = aws_iam_role.iam_for_ec2.name
}