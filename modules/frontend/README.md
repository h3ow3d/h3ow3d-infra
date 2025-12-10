# Frontend Module

Creates an S3-hosted static website, CloudFront distribution, and an artifacts bucket for build artifacts.

## Usage

```hcl
module "frontend" {
  source = "git::https://github.com/h3ow3d/h3ow3d-infra.git//modules/frontend?ref=v1.0.0"

  project_name = var.project_name
  environment  = var.environment
  domain_name  = "example.com"  # optional
  acm_certificate_arn = "arn:aws:acm:..." # optional
  tags = var.tags
}
```

## Outputs
- `s3_bucket_name`
- `cloudfront_domain_name`
- `cloudfront_distribution_id`
- `artifacts_bucket_name`
