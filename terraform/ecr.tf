resource "aws_ecr_repository" "ecr-image" {
  name                 = "${var.cluster_name}-image"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}