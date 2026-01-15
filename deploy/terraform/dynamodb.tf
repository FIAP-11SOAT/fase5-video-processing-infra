resource "aws_dynamodb_table" "video_processing" {
  name         = "${var.project_name}-video-processing"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name = "${var.project_name}-video-processing"
  }
}