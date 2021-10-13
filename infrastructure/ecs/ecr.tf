variable "repository_name" {
  type    = string
  default = "petclinic"
}

resource "aws_ecr_repository" "ECRRepository" {
  name = var.repository_name
}

output "repository_url" {
  value = aws_ecr_repository.ECRRepository.repository_url
}

