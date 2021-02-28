resource "aws_iam_role" "IB07441_BuildTrustRole" {
  name = "IB07441_BuildTrustRole"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "1",
      "Effect": "Allow",
      "Principal": {
        "Service": ["codebuild.amazonaws.com"]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = {
    tag-key = "IB07441_BuildTrustRole"
  }
}

resource "aws_iam_policy" "IB07441_CodeBuildRolePolicy" {
  name        = "IB07441_CodeBuildRolePolicy"
  path        = "/"
  description = "IB07441_CodeBuildRolePolicy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
            {
              "Sid": "CloudWatchLogsPolicy",
              "Effect": "Allow",
              "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
              ],
              "Resource": [
                "*"
              ]
            },
            {
              "Sid": "CodeCommitPolicy",
              "Effect": "Allow",
              "Action": [
                "codecommit:GitPull"
              ],
              "Resource": [
                "*"
              ]
            },
            {
              "Sid": "S3GetObjectPolicy",
              "Effect": "Allow",
              "Action": [
                "s3:GetObject",
                "s3:GetObjectVersion"
              ],
              "Resource": [
                "*"
              ]
            },
            {
              "Sid": "S3PutObjectPolicy",
              "Effect": "Allow",
              "Action": [
                "s3:PutObject"
              ],
              "Resource": [
                "*"
              ]
            },
            {
              "Sid": "OtherPolicies",
              "Effect": "Allow",
              "Action": [
                "ssm:GetParameters",
                "ecr:*"
              ],
              "Resource": [
                "*"
              ]
            }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "IB07441_role_policy_attach_codebuild" {
  role       = aws_iam_role.IB07441_BuildTrustRole.name
  policy_arn = aws_iam_policy.IB07441_CodeBuildRolePolicy.arn
}

resource "aws_s3_bucket" "S3_Bucket" {
  bucket = "ib07441-spring-boot-zip"
  force_destroy = true
  acl    = "private"

  versioning {
    enabled = true
  }

  tags = {
    Name        = "IB07441_S3_Bucket"
    Environment = "Dev"
  }
}

resource "aws_codebuild_project" "codebuild-project" {
  name          = "FS07441-Spring-Boot-codebuild-project"
  description   = "test_codebuild_project"
  build_timeout = "5"
  service_role  = aws_iam_role.IB07441_BuildTrustRole.arn

  artifacts {
    type = "S3"
    location = "ib07441-spring-boot-zip"
    packaging = "ZIP"
    name = "SpringBootArtifact.zip"
  }

  environment {
    type  = "LINUX_CONTAINER"
    image = "aws/codebuild/java:openjdk-8"
    compute_type = "BUILD_GENERAL1_SMALL"
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/cshyun7015/cshyun-SpringBoot-AWS.git"
    git_clone_depth = 1
    git_submodules_config {
      fetch_submodules = true
    }
  }
  source_version = "master"

  tags = {
    Name        = "IB07441_Spring-Boot-codebuild-project"
    Environment = "Test"
  }
}