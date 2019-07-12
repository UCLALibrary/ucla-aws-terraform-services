resource "aws_security_group" "allow_web" {
  name          = "${var.app_name}-allow_web"
  description   = "All public facing traffic to 80/443"
  vpc_id        = "${var.vpc_main_id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "alb_access" {
  name          = "{var.app_name}-alb-access"
  description   = "Allow HTTP/HTTPS traffic to load balancers"
  vpc_id        = "${var.vpc_main_id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
  
resource "aws_lb" "alb" {
  name               = "${var.app_name}-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = "${var.vpc_subnet_ids}"
  security_groups    = ["${aws_security_group.alb_access.id}"]
}
