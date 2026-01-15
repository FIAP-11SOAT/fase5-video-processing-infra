resource "aws_sqs_queue" "video_processing_queue" {
  name = "${var.project_name}-video-processing-queue"

  tags = {
    Name = "${var.project_name}-video-processing-queue"
  }
}

resource "aws_sqs_queue_policy" "video_processing_queue_policy" {
  queue_url = aws_sqs_queue.video_processing_queue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowS3ToSendMessage"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action   = "SQS:SendMessage"
        Resource = aws_sqs_queue.video_processing_queue.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_s3_bucket.videos_bucket.arn
          }
        }
      }
    ]
  })
}

