resource "aws_api_gateway_rest_api" "example" {
  name        = "ServerlessExample"
  description = "Terraform Serverless application example"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = "${aws_api_gateway_rest_api.example.id}"
  parent_id   = "${aws_api_gateway_rest_api.example.root_resource_id}"
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = "${aws_api_gateway_rest_api.example.id}"
  resource_id   = "${aws_api_gateway_resource.proxy.id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "labda" {
  rest_api_id             = "${aws_api_gateway_rest_api.example.id}"
  resource_id             = "${aws_api_gateway_method.proxy.resource_id}"
  http_method             = "${aws_api_gateway_method.proxy.http_method}"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.example.invoke_arn}"
}

resource "aws_api_gateway_deployment" "example" {
  depends_on = [
    "aws_api_gateway_integration.labda"
  ]
  rest_api_id = "${aws_api_gateway_rest_api.example.id}"
  stage_name  = "test"
}

output "API_REST_base_url" {
  value = "${aws_api_gateway_deployment.example.invoke_url}"
}

