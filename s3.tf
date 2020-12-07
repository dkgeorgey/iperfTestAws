resource "aws_s3_bucket" "iperf_output" {
  bucket = "temp-iperf3-output"
  acl    = "public-read-write"
  tags   = var.tags
}