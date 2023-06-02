resource "aws_iam_role" "lambda_role" {
  name               = "automatic_terraform_destroy_lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda_trust_policy.json
}

data "aws_iam_policy_document" "lambda_trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_execution_policy_document" {
  statement {
    sid = "1"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "arn:aws:logs:*:*:*",
    ]
  }

  statement {
    sid = "2"

    actions = [
      "s3:PutObject",
      "s3:GetObject"
    ]

    resources = [
      "arn:aws:s3:::pumpbot-terraform-states/*",
    ]
  }

  statement {
    sid = "3"

    actions = [
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "dynamodb:DeleteItem",
      "dynamodb:Query",
      "dynamodb:UpdateItem"
    ]

    resources = [
      "arn:aws:dynamodb:ap-northeast-1:826620026216:table/terraform-lock",
    ]
  }

  statement {
    sid = "4"

    actions = [
      "sns:*",
      "cloudwatch:*",
      "ec2:*",
      "elasticloadbalancing:*"
    ]

    resources = [
      "*",
    ]
  }

  statement {
    sid = "5"

    actions = [
      "lambda:*"
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "lambda_execution_policy" {
  name   = "automatic_terraform_destroy_lambda_policy"
  policy = data.aws_iam_policy_document.lambda_execution_policy_document.json
}

resource "aws_iam_role_policy_attachment" "lambda_execution_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_execution_policy.arn
}
