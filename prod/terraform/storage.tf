data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_s3_bucket" "s3" {
  for_each = local.s3s

  bucket = format("%s-%s-%s-an", each.value.name, data.aws_caller_identity.current.account_id, data.aws_region.current.region)

  tags = {
    Name = each.value.name
  }
}