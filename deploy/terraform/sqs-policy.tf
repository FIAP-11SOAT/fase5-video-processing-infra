data "aws_iam_policy_document" "video_processing_queue" {
  statement {
    sid    = "AllowS3ToSendMessage"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions = [
      "sqs:SendMessage",
    ]

    resources = [
      aws_sqs_queue.video_processing_queue.arn,
    ]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"

      values = [
        aws_s3_bucket.videos_bucket.arn,
      ]
    }
  }
}

resource "aws_sqs_queue_policy" "video_processing_queue_policy" {
  queue_url = aws_sqs_queue.video_processing_queue.id
  policy    = data.aws_iam_policy_document.video_processing_queue.json
}