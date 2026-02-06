resource "aws_sqs_queue" "video_processing_queue" {
  name = "fase5-video-processing-queue"

  tags = {
    Name = "${var.project_name}-video-processing-queue"
  }
}

resource "aws_sqs_queue" "video_notification_queue" {
  name = "fase5-video-notification-queue"

  tags = {
    Name = "${var.project_name}-video-notification-queue"
  }
}
