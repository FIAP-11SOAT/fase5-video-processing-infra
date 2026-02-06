resource "aws_dynamodb_table" "video_processing" {
  name         = "fase5-video-processing"
  billing_mode = "PAY_PER_REQUEST"

  hash_key  = "id"
  range_key = "userId"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "userId"
    type = "S"
  }

  global_secondary_index {
    hash_key        = "userId"
    name            = "userId-index"
    projection_type = "ALL"
  }

  tags = {
    Name = "${var.project_name}-video-processing"
  }
}
