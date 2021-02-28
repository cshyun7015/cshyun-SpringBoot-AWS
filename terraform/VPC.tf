resource "aws_vpc" "VPC" {
  cidr_block  = "9.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "IB07441-VPC-09-SpringBootVPC"
  }
}

resource "aws_default_route_table" "DefaultRouteTable" {
  default_route_table_id = aws_vpc.VPC.default_route_table_id

  tags = {
    Name = "IB07441-DefaultRouteTable"
  }
}

data "aws_availability_zones" "available" {
}

resource "aws_subnet" "publicSubnet01" {
  vpc_id = aws_vpc.VPC.id
  cidr_block = "9.0.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "IB07441-publicSubnet01"
  }
}

resource "aws_internet_gateway" "InternetGateway" {
  vpc_id = aws_vpc.VPC.id
  tags = {
    Name = "IB07441-InternetGateway"
  }
}

resource "aws_route" "PublicRoute" {
  route_table_id = aws_vpc.VPC.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.InternetGateway.id
}

resource "aws_route_table_association" "publicSubnet01_association" {
  subnet_id = aws_subnet.publicSubnet01.id
  route_table_id = aws_vpc.VPC.main_route_table_id
}

resource "aws_default_network_acl" "DefaultNetworkAcl" {
  default_network_acl_id = aws_vpc.VPC.default_network_acl_id

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "IB07441-DefaultNetworkAcl"
  }
}

resource "aws_network_acl" "PublicNetworkAcl" {
  vpc_id = aws_vpc.VPC.id
  subnet_ids = [
    aws_subnet.publicSubnet01.id
  ]

  tags = {
    Name = "IB07441-PublicNetworkAcl"
  }
}

resource "aws_network_acl_rule" "PublicIngressEphemeral" {
  network_acl_id = aws_network_acl.PublicNetworkAcl.id
  rule_number = 140
  rule_action = "allow"
  egress = false
  protocol = "-1"
  cidr_block = "0.0.0.0/0"
  from_port = 0
  to_port = 65535
}

resource "aws_network_acl_rule" "PublicEgressEphemeral" {
  network_acl_id = aws_network_acl.PublicNetworkAcl.id
  rule_number = 140
  rule_action = "allow"
  egress = true
  protocol = "-1"
  cidr_block = "0.0.0.0/0"
  from_port = 0
  to_port = 65535
}

resource "aws_default_security_group" "DefaultSecurityGroup" {
  vpc_id = aws_vpc.VPC.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "IB07441-DefaultSecurityGroup"
  }
}

resource "aws_security_group" "SecurityGroup" {
  name = "IB07441-SecurityGroup"
  description = "Security group for IB07441 instance"
  vpc_id = aws_vpc.VPC.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 123
    to_port = 123
    protocol = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 9418
    to_port = 9418
    protocol = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "IB07441-SecurityGroup"
  }
}

resource "aws_key_pair" "EC2_sshkey_pub" {
  key_name   = "IB07441_sshkey"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCqLao0WnxsUcJAq5KgUY5sxjsigNQtia+0DIJ05E9Ad1uKgYCtdGlyrSRI/4lgW9sqbIKruz4e8WgnhqxgVMOTro5Z6c0GbRUlS6cS2QLpTQGAyRBZWBY76QbhI6T1rk7L3KHLnknfIU+gUkDDA31dMb3xaf9mjHVDzgMNY/cDZjirNx7D9bnhW1BnMhQ9Y4E3x+pdVO1YrMnm4v/68KkWjIiCdQOtOGg+uijllCtBFL2DGByhIB/xhhVhHFvLP8BwWzg0ftbA2PaUopopXZhHoWA39bFiGwt44nIIFCk/gSMEAyRq3mxPwAMTY2RQSAx/IPjU6o1xkmZ6ao8jC5Vr 07441@SKCC20N01233"
}

variable default_keypair_name {
  default = "IB07441_sshkey"
}

resource "aws_iam_role" "WebAppRole" {
  name = "IB07441_WebAppRole"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
            {
              "Sid": "",
              "Effect": "Allow",
              "Principal": {
                "Service": "ec2.amazonaws.com"
              },
              "Action": "sts:AssumeRole"
            }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "role_policy_attach_AWSCodeDeployReadOnlyAccess" {
  role       = aws_iam_role.WebAppRole.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployReadOnlyAccess"
}
resource "aws_iam_role_policy_attachment" "role_policy_attach_AmazonEC2ReadOnlyAccess" {
  role       = aws_iam_role.WebAppRole.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}


resource "aws_iam_policy" "WebAppRolePolicies" {
  name        = "IB07441_WebAppRolePolicies"
  path        = "/"
  description = "IB07441_WebAppRolePolicies"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
            {
              "Effect": "Allow",
              "Action": [
                "autoscaling:Describe*",
                "autoscaling:EnterStandby",
                "autoscaling:ExitStandby",
                "autoscaling:UpdateAutoScalingGroup"
              ],
              "Resource" : "*"
            },
            {
              "Effect": "Allow",
              "Action": [
                "ec2:DescribeInstances",
                "ec2:DescribeInstanceStatus"
              ],
              "Resource": "*"
            },
            {
              "Effect": "Allow",
              "Action": [
                "s3:Get*",
                "s3:List*"
              ],
              "Resource": [
                "arn:aws:s3:::fs07441-cicd-workshop",
                "arn:aws:s3:::fs07441-cicd-workshop/*",
                "arn:aws:s3:::FS07441-CodePipeline*"
              ]
            }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "IB07441_role_policy_attach_WebApp" {
  role       = aws_iam_role.WebAppRole.name
  policy_arn = aws_iam_policy.WebAppRolePolicies.arn
}

resource "aws_iam_instance_profile" "InstanceProfile" {
  name = "IB07441_InstanceProfile"
  role = aws_iam_role.WebAppRole.name
}

resource "aws_instance" "SpringBoot_EC2_01" {
  ami = "ami-9bec36f5" #ap-northeast-2
  availability_zone = aws_subnet.publicSubnet01.availability_zone
  instance_type = "t2.nano"
  iam_instance_profile = aws_iam_instance_profile.InstanceProfile.id
  key_name = var.default_keypair_name
  vpc_security_group_ids = [
    aws_default_security_group.DefaultSecurityGroup.id,
    aws_security_group.SecurityGroup.id
  ]
  subnet_id = aws_subnet.publicSubnet01.id
  associate_public_ip_address = true

  user_data = <<-EOF
#!/bin/bash
yum upgrade
yum install -y aws-cli
yum install -y git
yum -y install codedeploy-agent.noarch.rpm
service codedeploy-agent start
yum remove -y java-1.7.0-openjdk
yum install -y java-1.8.0-openjdk-devel.x86_64
rm /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Seoul /etc/localtime
yum install -y mysql
EOF

  tags = {
    Name = "IB07441-EC2-SpringBoot"
  }
}