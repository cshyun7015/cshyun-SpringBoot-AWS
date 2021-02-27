resource "aws_db_parameter_group" "DB_Parameter_Group" {
  name   = "ib07441-db-parameter-group"
  family = "mariadb10.2"
  description = "IB07441 Maria DB for Spring Boot Test"

  parameter {
    name  = "time_zone"
    value = "Asia/Seoul"
  }
  parameter {
    name  = "character_set_client"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_connection"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_filesystem"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_results"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "collation_connection"
    value = "utf8mb4_general_ci"
  }

  parameter {
    name  = "collation_server"
    value = "utf8mb4_general_ci"
  }

  parameter {
    name  = "max_connections"
    value = 150
  }
}

resource "aws_subnet" "privateSubnet01" {
  vpc_id = aws_vpc.VPC.id
  cidr_block = "9.0.11.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "IB07441-privateSubnet01"
  }
}

resource "aws_subnet" "privateSubnet02" {
  vpc_id = aws_vpc.VPC.id
  cidr_block = "9.0.12.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "IB07441-privateSubnet02"
  }
}

resource "aws_subnet" "privateSubnet03" {
  vpc_id = aws_vpc.VPC.id
  cidr_block = "9.0.13.0/24"
  availability_zone = data.aws_availability_zones.available.names[2]
  tags = {
    Name = "IB07441-privateSubnet03"
  }
}

resource "aws_security_group" "SecurityGroup_RDS" {
  name = "IB07441-SecurityGroup-RDS"
  description = "Security group for IB07441 instance"
  vpc_id = aws_vpc.VPC.id

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["218.55.155.51/32"]
  }
  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_groups = [aws_security_group.SecurityGroup.id]
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

resource "aws_db_subnet_group" "DB_Subnet_Group" {
  name       = "ib07441-db-subnet-group"
  subnet_ids = [
    aws_subnet.privateSubnet01.id,
    aws_subnet.privateSubnet02.id,
    aws_subnet.privateSubnet03.id
  ]

  tags = {
    Name = "FS07441-DBSubnetGroup"
  }
}

resource "aws_db_instance" "DB_Instance" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mariadb"
  engine_version       = "10.2.21"
  instance_class       = "db.t2.micro"
  name                 = "IB07441DB"
  username             = "admin"
  password             = "password"
  parameter_group_name = aws_db_parameter_group.DB_Parameter_Group.id
  vpc_security_group_ids = [aws_security_group.SecurityGroup_RDS.id]
  db_subnet_group_name = aws_db_subnet_group.DB_Subnet_Group.id
  publicly_accessible  = true
  port                 = 3306
  identifier = "ib07441-db-identifier"
  final_snapshot_identifier = "id07441-db-snapshot-identifier"
  skip_final_snapshot  = true
}