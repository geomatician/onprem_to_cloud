resource "aws_security_group" "redshift_sg" {
  name   = "redshift-sg-${var.environment}"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 5439
    to_port     = 5439
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "redshift_from_vpc_cidr" {
  type        = "ingress"
  description = "Allow VPC-wide access to Redshift (optional)"
  from_port   = 5439
  to_port     = 5439
  protocol    = "tcp"

  security_group_id = aws_security_group.redshift_sg.id
  cidr_blocks       = [var.vpc_cidr]
}