resource "aws_codedeploy_app" "Codedeploy-App" {
  compute_platform = "Server"
  name             = "IB07441-Spring-Boot-CodeDeploy-Project"
}

resource "aws_iam_role" "IB07441_DeployTrustRole" {
  name = "IB07441_DeployTrustRole"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
            {
              "Sid" : "",
              "Effect" : "Allow",
              "Principal" : {
                "Service": [
                    "codedeploy.amazonaws.com"
                ]
              },
              "Action" : "sts:AssumeRole"
            }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "role_policy_attach_codedeploy" {
  role       = aws_iam_role.IB07441_DeployTrustRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

resource "aws_codedeploy_deployment_group" "Codedeploy-DeploymentGroup" {
  app_name              = aws_codedeploy_app.Codedeploy-App.name
  deployment_group_name = "IB07441-Codedeploy-DeploymentGroup"
  service_role_arn      = aws_iam_role.IB07441_DeployTrustRole.arn
  deployment_config_name = "CodeDeployDefault.OneAtATime"

  #load_balancer_info {
  #  elb_info {
  #    name = aws_elb.ELB.name
  #  }
  #}

  #ec2_tag_filter {
  #    key   = "Name"
  #    type  = "KEY_AND_VALUE"
  #    value = "user19-DevWebApp01"
  #}

  #autoscaling_groups = [aws_autoscaling_group.AutoscalingGroup.name]
}