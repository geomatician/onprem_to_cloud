resource "aws_iam_role" "redshift" {
  name = "redshift-s3-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "redshift.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "s3_access" {
  role = aws_iam_role.redshift.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = ["s3:*"]
      Effect = "Allow"
      Resource = "*"
    }]
  })
}

output "redshift_role_arn" {
  value = aws_iam_role.redshift.arn
}