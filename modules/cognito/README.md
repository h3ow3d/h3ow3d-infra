# Cognito Module

Creates a Cognito User Pool, Google Identity Provider, App Client, and Hosted UI domain.

## Usage

```hcl
module "cognito" {
  source = "git::https://github.com/h3ow3d/h3ow3d-infra.git//modules/cognito?ref=v1.0.0"

  project_name         = var.project_name
  environment          = var.environment
  google_client_id     = var.google_client_id
  google_client_secret = var.google_client_secret
  callback_urls        = ["https://example.com"]
  domain_prefix        = "h3ow3d-auth"
  tags = var.tags
}
```

## Inputs
- `project_name`, `environment`, `google_client_id`, `google_client_secret`, `callback_urls`, `domain_prefix`, `tags`

## Outputs
- `user_pool_id`, `client_id`, `domain`
