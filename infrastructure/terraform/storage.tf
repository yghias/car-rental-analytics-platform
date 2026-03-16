resource "aws_s3_bucket" "raw" {
  bucket = "${var.project_name}-raw-demo"
}

resource "aws_s3_bucket" "curated" {
  bucket = "${var.project_name}-curated-demo"
}
