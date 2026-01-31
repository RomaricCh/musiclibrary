output "api_gateway_endpoint" {
  description = "The base URL of the API Gateway stage"
  value       = aws_api_gateway_stage.main.invoke_url
}
