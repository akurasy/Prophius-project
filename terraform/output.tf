output "ecr_image" {
  value = aws_ecr_repository.ecr-image.repository_url
}