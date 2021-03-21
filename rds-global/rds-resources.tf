data "terraform_remote_state" "site" {
  backend = "s3"
  config = {
    bucket = var.terraform_bucket
    key = var.site_module_state_path
    region = "us-east-1"
  }
}

resource "aws_security_group" "rds-mysql-db" {

  name = "workshop_rds"
  description = "sg for workshop rds"
  vpc_id = data.terraform_remote_state.site.outputs.vpc_id


  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "rds-db-default-group" {
  name        = "default-subnet-group"
  description = "Terraform example RDS subnet group"
  subnet_ids  = element(data.terraform_remote_state.site.outputs.private_subnets, 0)
}

resource "aws_db_instance" "rds-db" {
  multi_az = var.multi_az
  apply_immediately = var.apply_immediately
  identifier = var.identifier
  publicly_accessible  = var.publicly_accessible
  engine = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class
  name = var.name
  username = "admin"
  password = "AA123456" //use tfvars file or a datasource
  db_subnet_group_name = aws_db_subnet_group.rds-db-default-group.id
  storage_type = var.storage_type
  allocated_storage = var.allocated_storage
  availability_zone = var.availability_zone
  vpc_security_group_ids = [ aws_security_group.rds-mysql-db.id ]
  skip_final_snapshot = var.skip_final_snapshot
}