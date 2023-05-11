output "load_balancer_arn" {
  value = aws_lb.instance-lb.arn
}

output "lb-dns" {
  value = aws_lb.instance-lb.dns_name
}