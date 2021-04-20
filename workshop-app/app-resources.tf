data "terraform_remote_state" "site" {
  backend = "s3"
  config = {
    bucket = var.terraform_bucket
    key    = var.site_module_state_path
    region = "us-east-2"
  }
}

resource "aws_launch_configuration" "workshop-app_lc" {
  user_data = file("${path.module}/templates/user_data.cloudinit")
  lifecycle {
    create_before_destroy = true
  }
  security_groups   = [aws_security_group.workshop-app.id]
  name              = "${var.cluster_name}_lc"
  enable_monitoring = false
  image_id          = var.ami
  instance_type     = var.instance_type
  key_name          = data.terraform_remote_state.site.outputs.admin_key_name

}

resource "aws_autoscaling_group" "workshop-app_asg" {
  name                 = "${var.cluster_name}_asg"
  launch_configuration = aws_launch_configuration.workshop-app_lc.name
  max_size             = var.workshop-app_cluster_size_max
  min_size             = var.workshop-app_cluster_size_min
  desired_capacity     = var.workshop-app_cluster_size_min
  vpc_zone_identifier  = data.terraform_remote_state.site.outputs.public_subnets
  load_balancers       = [aws_elb.workshop-app.name]

  tag {
    key                 = "Name"
    value               = var.cluster_name
    propagate_at_launch = true
  }

  tag {
    key                 = "Team"
    value               = "Workshop"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "workshop-app_lb" {
  name        = "${var.cluster_name}-lb"
  description = "${var.cluster_name}-lb"
  vpc_id      = data.terraform_remote_state.site.outputs.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "workshop-app_client" {

  lifecycle {
    create_before_destroy = true
  }

  name        = "${var.cluster_name}_client"
  description = "sg for ${var.cluster_name} app clients"
  vpc_id      = data.terraform_remote_state.site.outputs.vpc_id

}



resource "aws_security_group" "workshop-app" {
  lifecycle {
    create_before_destroy = true
  }

  name        = "${var.cluster_name}_workshop_app"
  description = "sg for ${var.cluster_name} workshop app"
  vpc_id      = data.terraform_remote_state.site.outputs.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.workshop-app_client.id]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


}

resource "aws_elb" "workshop-app" {
  name            = "${var.cluster_name}-lb"
  subnets         = data.terraform_remote_state.site.outputs.public_subnets
  security_groups = [aws_security_group.workshop-app_lb.id,aws_security_group.workshop-app_client.id]


  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 2
    target              = "HTTP:80/index.html"
    interval            = 10
  }



}
