# =============================================================================
# Terraform Backend Configuration (S3)
# =============================================================================
# 
# Le nom du bucket est configuré via la variable d'environnement.
# Initialiser avec :
#   terraform init -backend-config="bucket=$bucket_name"
#
# =============================================================================

terraform {
  backend "s3" {
    # bucket est passé via -backend-config="bucket=$bucket_name"
    key     = "musiclibrary/terraform.tfstate"
    region  = "eu-west-1"
    encrypt = true
  }
}
