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

resource "aws_security_group" "glue_sg" {
  name        = "glue-sg-${var.environment}"
  description = "Glue security group"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "allow_glue_to_redshift" {
  type      = "ingress"
  from_port = 5439
  to_port   = 5439
  protocol  = "tcp"

  security_group_id        = aws_security_group.redshift_sg.id
  source_security_group_id = aws_security_group.glue_sg.id
}