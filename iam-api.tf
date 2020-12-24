data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

# lambda role
data "aws_iam_policy_document" "get_assume" {
  statement {
    effect  = "Allow"
    principals {
      type = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "get" {
  statement {
    effect = "Allow"
    resources = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]
    actions = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:DeleteLogGroup", "logs:DeleteLogStream", "logs:DeleteMetricFilter", "logs:DescribeLogGroups", "logs:DescribeLogStreams", "logs:DescribeMetricFilters", "logs:GetLogEvents", "logs:GetLogGroupFields", "logs:GetLogRecord", "logs:GetQueryResults", "logs:PutLogEvents", "logs:PutMetricFilter"]
  }
}

resource "aws_iam_role" "iam_role_for_lambda" {
  name = "aws_sandbox_lambda-invoke-role"
  assume_role_policy = data.aws_iam_policy_document.get_assume.json
}

resource "aws_iam_role_policy" "get" {
  role = aws_iam_role.iam_role_for_lambda.name
  policy = data.aws_iam_policy_document.get.json
}
