resource "aws_dynamodb_table" "video_processing" {
  name         = "${var.project_name}-video-processing"
  billing_mode = "PAY_PER_REQUEST"

  hash_key     = "videoKey"

  attribute {
    name = "videoKey"
    type = "S"
  }

  attribute {
    name = "userId"
    type = "S"
  }

  global_secondary_index {
    name            = "userId-index"
    hash_key        = "userId"
    projection_type = "ALL"
  }

  tags = {
    Name = "${var.project_name}-video-processing"
  }
}
