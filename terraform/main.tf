data "aws_region" "current" {}

data "aws_iam_policy_document" "lambda" {
  statement {
    sid = "AllowESFullAccess"

    actions = [
      "es:*",
    ]

    resources = [
      "*",
    ]
  }
}

module "lambda" {
  source        = "github.com/harmy/terraform-aws-lambda"
  function_name = "lambda-curator-${var.stage}-${data.aws_region.current.name}"
  description   = "a lambda function deletes old AWS ElasticSearch indices using curator"
  handler       = "main.lambda_handler"
  runtime       = "python3.6"
  timeout       = "${var.timeout}"
  source_path   = "${path.module}/../lambda"

  attach_policy = true
  policy        = "${data.aws_iam_policy_document.lambda.json}"

  log_retention_days  = 7
  schedule_expression = "${var.schedule_expression}"
  enabled             = "${var.enabled}"

  environment {
    variables {
      REGIONS = "${var.regions}"
      VPC_ID  = "${var.vpc_id}"
    }
  }

  attach_vpc_config = "${var.vpc_id != ""}"

  vpc_config = "${var.vpc_config}"
}
