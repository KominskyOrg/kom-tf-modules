resource "aws_route53_record" "subdomain_record" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "${var.subdomain_name}.${var.domain_name}"
  type    = "CNAME"
  ttl     = 300
  records = ["dualstack.${kubernetes_service.gocd_server_service.status.0.load_balancer.0.ingress.0.hostname}"]
}
