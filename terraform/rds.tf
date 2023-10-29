
resource "random_string" "suffix" {
  length  = 16
  special = false
}

resource "aws_secretsmanager_secret_version" "sversion" {
  secret_id = aws_secretsmanager_secret.secretmasterDB.id
  secret_string = <<EOF
   {
    "username": "adminaccount",
    "password": "${random_password.password.result}",
    "endpoint": "${aws_db_instance.default.endpoint.address}"
   }
EOF
}

resource "aws_secretsmanager_secret" "secretmasterDB" {
   name = "${var.cluster_name}-secret"
}

data "aws_secretsmanager_secret_version" "creds" {
    secret_id = aws_secretsmanager_secret.secretmasterDB.arn
}

resource "aws_db_instance" "default" {
  allocated_storage    = 10
  db_name              = "mydb"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  username             = jsondecode(data.aws_secretsmanager_secret_version.creds.secret_string)["username"]
  password = jsondecode(data.aws_secretsmanager_secret_version.creds.secret_string)["password"]
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.default.name
}

resource "aws_db_subnet_group" "default" {
  name       = "subnet-group"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name = "${var.cluster_name}-subnet-group"
  }
}

# Sercurity group

resource "aws_security_group" "rdssg" {
    name = "rdssg"
    vpc_id =  module.vpc.vpc_id

    ingress {
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        security_groups = module.eks.node_security_group_id

    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]

    }
}