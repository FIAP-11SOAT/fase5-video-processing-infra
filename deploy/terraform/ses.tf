resource "aws_ses_domain_identity" "main" {
  domain = local.domain_name
}

resource "cloudflare_dns_record" "ses_verification" {
  zone_id = local.aws_master_secrets["CLOUDFLARE_ZONE_ID"]
  name    = "_amazonses.${local.domain_name}"
  type    = "TXT"
  content = aws_ses_domain_identity.main.verification_token
  ttl     = 3600
}

resource "aws_ses_domain_dkim" "main" {
  domain = aws_ses_domain_identity.main.domain
}

resource "cloudflare_dns_record" "dkim" {
  count   = 3
  zone_id = local.aws_master_secrets["CLOUDFLARE_ZONE_ID"]
  name    = "${element(aws_ses_domain_dkim.main.dkim_tokens, count.index)}._domainkey.${local.domain_name}"
  type    = "CNAME"
  content = "${element(aws_ses_domain_dkim.main.dkim_tokens, count.index)}.dkim.amazonses.com"
  ttl     = 3600
}

resource "cloudflare_dns_record" "spf" {
  zone_id = local.aws_master_secrets["CLOUDFLARE_ZONE_ID"]
  name    = local.domain_name
  type    = "TXT"
  content = "v=spf1 include:amazonses.com ~all"
  ttl     = 3600
}

resource "cloudflare_dns_record" "dmarc" {
  zone_id = local.aws_master_secrets["CLOUDFLARE_ZONE_ID"]
  name    = "_dmarc.${local.domain_name}"
  type    = "TXT"
  content = "v=DMARC1; p=quarantine; rua=mailto:dmarc@${local.domain_name}; fo=1"
  ttl     = 3600
}

resource "aws_ses_domain_mail_from" "main" {
  domain           = aws_ses_domain_identity.main.domain
  mail_from_domain = "mail.${local.domain_name}"
}

resource "cloudflare_dns_record" "mail_from_mx" {
  zone_id  = local.aws_master_secrets["CLOUDFLARE_ZONE_ID"]
  name     = "mail.${local.domain_name}"
  type     = "MX"
  content  = "feedback-smtp.us-east-1.amazonses.com"
  priority = 10
  ttl      = 3600
}

resource "cloudflare_dns_record" "mail_from_spf" {
  zone_id = local.aws_master_secrets["CLOUDFLARE_ZONE_ID"]
  name    = "mail.${local.domain_name}"
  type    = "TXT"
  content = "v=spf1 include:amazonses.com ~all"
  ttl     = 3600
}

resource "aws_ses_email_identity" "emails_teste" {
  email = "teteuoliveira12@gmail.com"
}