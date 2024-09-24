provider "aws" {
 region = "us-east-1"
 }

terraform {
  backend "s3" {
    bucket = "yusuf-docker-tfstate"
    key    = "project/terraform.tsstate"
    region = "us-east-1"
  }
}


variable "environment_name" {
  type  = string
  }
resource "aws_s3_bucket" "app_bucket" {
  bucket = "my-app-${var.environment_name}-bucket"

  versioning {
   enabled = true
}
  website {
  index_document = "index.html"
  error_document = "error.html"

  }
}
resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.app_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket" "example" {
  bucket = "example"
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.app_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_object" "object" {
  for_each = fileset ("home/runner/work/fullstackproject/fullstackproject/build", "**")
  bucket = aws_s3_bucket.app_bucket.bucket
  key    = "each.value"
  source = "home/runner/work/fullstackproject/fullstackproject/build/${each.value}"
  acl = "public-read"
}

output "bucket_url" {
   value = aws_s3_bucket.app_bucket.website_endpoint
  }

  
