resource "aws_security_group" "allow_web" {
  name          = "allow_web"
  description   = "All public facing traffic to 80/443"
  vpc_id        = "${aws_vpc.main.id}"
  depends_on    = ["aws_vpc.main"]

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

resource "aws_security_group" "allow_restricted_ssh" {
  name          = "allow_restricted_ssh"
  description   = "Allow restricted subnets to SSH into systems"
  vpc_id        = "${aws_vpc.main.id}"
  depends_on    = ["aws_vpc.main"]

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["164.67.152.0/24", "164.67.40.0/24", "165.227.26.38/32"]
  }
}

resource "aws_security_group" "cantaloupe_alb_ecs" {
  name = "cantaloupe-alb-ecs"
  description = "Allow HTTP/HTTPS traffic to load balancers"
  vpc_id        = "${aws_vpc.main.id}"
  depends_on    = ["aws_vpc.main"]

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
  
resource "aws_security_group" "cantaloupe_container" {
  name = "cantaloupe-container"
  description = "Whitelist Cantaloupe ALB SG to access application port on container"
  vpc_id        = "${aws_vpc.main.id}"
  depends_on    = ["aws_security_group.cantaloupe_alb_ecs", "aws_vpc.main"]

  ingress {
    from_port   = "${var.cantaloupe_app_port}"
    to_port     = "${var.cantaloupe_app_port}"
    protocol    = "tcp"
    security_groups = ["${aws_security_group.cantaloupe_alb_ecs.id}"]
  }
}