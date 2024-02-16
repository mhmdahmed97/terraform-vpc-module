resource "aws_flow_log" "flow_log" {
  iam_role_arn    = aws_iam_role.iam_role.arn
  log_destination = aws_cloudwatch_log_group.flowlog_cw.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main.id
  depends_on = [ aws_vpc.main ]
}

resource "aws_cloudwatch_log_group" "flowlog_cw" {
  name = "vpc-flow-logs"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_role" {
  name               = "vpc-flow-logs-iam-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "iam_policy" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "iam_role_policy" {
  name   = "vpc-flow-logs-policy"
  role   = aws_iam_role.iam_role.id
  policy = data.aws_iam_policy_document.iam_policy.json
}