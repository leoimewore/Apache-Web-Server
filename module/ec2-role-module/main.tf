
resource "aws_iam_policy" "ec2_policy1" {
  name = "ec2_policy"
  

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:Get*",
                "s3:List*",
                "s3:Describe*",
                "s3-object-lambda:Get*",
                "s3-object-lambda:List*"
            ],
            "Resource": "arn:aws:s3:::project-s3check/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssm:DescribeAssociation",
                "ssm:GetDeployablePatchSnapshotForInstance",
                "ssm:GetDocument",
                "ssm:DescribeDocument",
                "ssm:GetManifest",
                "ssm:GetParameter",
                "ssm:GetParameters",
                "ssm:ListAssociations",
                "ssm:ListInstanceAssociations",
                "ssm:PutInventory",
                "ssm:PutComplianceItems",
                "ssm:PutConfigurePackageResult",
                "ssm:UpdateAssociationStatus",
                "ssm:UpdateInstanceAssociationStatus",
                "ssm:UpdateInstanceInformation"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssmmessages:CreateControlChannel",
                "ssmmessages:CreateDataChannel",
                "ssmmessages:OpenControlChannel",
                "ssmmessages:OpenDataChannel"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2messages:AcknowledgeMessage",
                "ec2messages:DeleteMessage",
                "ec2messages:FailMessage",
                "ec2messages:GetEndpoint",
                "ec2messages:GetMessages",
                "ec2messages:SendReply"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "ssm:DescribeEffectivePatchesForPatchBaseline",
            "Resource": "arn:aws:ssm:*:*:patchbaseline/*"
        },
        {
            "Effect": "Allow",
            "Action": "ssm:GetPatchBaseline",
            "Resource": "arn:aws:ssm:*:*:patchbaseline/*"
        },
        {
            "Effect": "Allow",
            "Action": "tag:GetResources",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "ssm:DescribePatchBaselines",
            "Resource": "*"
        }
    ]
  })

  tags = {
    tag-key = "ec2_policy"
  }
}


resource "aws_iam_role" "ssm_ec2_role" {
  name = "ssm_ec2_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "tag-value"
  }
}

resource "aws_iam_policy_attachment" "role_attach" {
    name ="role_attach"
    roles = [aws_iam_role.ssm_ec2_role.name]
    policy_arn = aws_iam_policy.ec2_policy1.arn
  
}
resource "aws_iam_instance_profile" "ssm-ec2-profile" {
    name = "ssm-ec2-profile"
    role = aws_iam_role.ssm_ec2_role.name
  
}