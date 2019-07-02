resource "aws_lambda_function" "example" {
  function_name = "ServerlessExample"
  s3_bucket     = "proteccion-web-profilling"
  s3_key        = "lambda-expl/lambda.zip"
  handler       = "main.handler"
  runtime       = "nodejs8.10"
  role          = "arn:aws:iam::061027341133:role/lambda-example-apex_lambda_function" //"${aws_iam_role.lambda_exec.arn}"
}

# resource "aws_iam_role" "lambda_exec" {
#   name               = "serverless_example_lambda"
#   assume_role_policy = <<EOF
#   {
#       "version": "2019-10-17",
#       "Statement": [
#           {
#               "Action": "sts:AssumeRole",
#               "Principal": {
#                   "Service": "lambda.amazonaws.com"
#               },
#               "Effect": "Allow",
#               "Sid": ""
#           }
#       ]
#   }
#   EOF
# }

resource "aws_lambda_permission" "apigtw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.example.arn}"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_deployment.example.execution_arn}/*/*"
}

