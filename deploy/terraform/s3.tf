resource "aws_s3_bucket" "videos_bucket" {
  bucket = "${var.project_name}-videos"

  tags = {
    Name = "${var.project_name}-videos"
  }
}

resource "aws_s3_bucket" "frames_bucket" {
  bucket = "${var.project_name}-frames"

  tags = {
    Name = "${var.project_name}-frames"
  }
}

resource "aws_s3_bucket_notification" "videos_notification" {
  bucket = aws_s3_bucket.videos_bucket.id

  queue {
    queue_arn     = aws_sqs_queue.video_processing_queue.arn
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = ""
    filter_suffix = ""
  }

  depends_on = [aws_sqs_queue_policy.video_processing_queue_policy]
}
