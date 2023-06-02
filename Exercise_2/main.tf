terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
 access_key = "ASIAVJF2IRYM4QHVO3JJ"
 secret_key = "iaKRoM0xMFXPD7iaEXuOFensEJGFt6db+8pbEQ7I"
 token  = "FwoGZXIvYXdzELD//////////wEaDCv0JvEfIyK2HVMgJSLVAfVK9ijiUK78JBqYkawsGxwriPDA4mhbpGtt3/k1APE3NG6k/BEh2K1fqwzNw9THIfJ+k2XeUsY74FzEzxkcLElW1IkQCHQv1sIK27PklPvD359tSOUOCF1tQul984A0F1zBa6obyqFi8lrDxHwrZpkrhUH0WXVn9u7a7mRySdPZhNKzHK9nCqEoXm/UtoRvoHQDeNv1woHGFMfNGNA9LRXAo1gBowkja00F+BKNj8Pqfpe/VLyeNFe4k1JlN7eRyNOcUN9CMmFhNfLM4XreEkDVqbda2yj4heijBjItEovh7tA3reTG1h5iJn/UDw3s4o4p9zUFURkHwq2CPYqbRsBFawOOuynZRRSM"
 region = var.region
}


# See also the following AWS managed policy: AWSLambdaBasicExecutionRole
data "aws_iam_policy_document" "lambda_role_policy"{
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_role_udacity" {  
  name = "lambda-Role"  
  assume_role_policy = data.aws_iam_policy_document.lambda_role_policy.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]
}

data "archive_file" "lambda_udacity" {
  type        = "zip"
  source_file = "greet_lambda.py"
  output_path = "lambda_python.zip"
}

resource "aws_lambda_function" "test_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "lambda_python.zip"
  function_name = "lambda_udacity_python_part2"
  role          = aws_iam_role.lambda_role_udacity.arn
  handler       = "greet_lambda.lambda_handler"
  timeout       = 30
  memory_size   = 128
  source_code_hash = data.archive_file.lambda_udacity.output_base64sha256

  runtime = "python3.8"

  environment {
    variables = {
      Project = "Udacity"
    }
  }
}

resource "aws_iam_role_policy_attachment" "function_logging_policy" {
  role = aws_iam_role.lambda_role_udacity.id
  policy_arn = aws_iam_policy.function_logging_policy.arn
}


resource "aws_iam_policy" "function_logging_policy" {
  name   = "function-logging-policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Action : [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect : "Allow",
        Resource : "arn:aws:logs:*:*:*"
      }
    ]
  })
}
resource "aws_cloudwatch_log_group" "uda_lambda" {
  name = "/aws/lambda/${aws_lambda_function.test_lambda.function_name}"
  retention_in_days = 3
  lifecycle {
    prevent_destroy = false
  }
}