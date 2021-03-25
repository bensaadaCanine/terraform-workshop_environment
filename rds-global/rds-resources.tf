data "terraform_remote_state" "site" {
  backend = "s3"
  config = {
    bucket = var.terraform_bucket
    key    = var.site_module_state_path
    region = "us-east-2"
  }
}

resource "aws_security_group" "rds-mysql-db" {

  name        = "workshop_rds"
  description = "sg for workshop rds"
  vpc_id      = data.terraform_remote_state.site.outputs.vpc_id


  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "rds-db-default-group" {
  name       = "${var.identifier}_subnets"
  subnet_ids = data.terraform_remote_state.site.outputs.private_subnets
}

resource "aws_db_instance" "rds-db" {
  multi_az            = false
  apply_immediately   = var.apply_immediately
  identifier          = var.identifier
  publicly_accessible = var.publicly_accessible
  engine              = var.engine
  instance_class      = var.instance_class
  name                = var.name
  username            = var.username
  password            = var.password
  storage_type        = var.storage_type
  allocated_storage   = var.allocated_storage
  availability_zone   = var.availability_zone
  skip_final_snapshot = var.skip_final_snapshot
}
