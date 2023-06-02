# TODO: Define the output variable for the lambda function.
output "function_arn" {
  description = "The ARN of the Lambda function"
  value       = join("", aws_lambda_function.test_lambda.*.arn)
}

output "function_name" {
  description = "The name of the Lambda function"
  value       = join("", aws_lambda_function.test_lambda.*.function_name)
}
