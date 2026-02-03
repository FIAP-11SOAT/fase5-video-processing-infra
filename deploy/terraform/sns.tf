resource "aws_sns_topic" "alarms_topic" {
  name = "fase5-alarms-topic"

  tags = {
    Name = "${var.project_name}-alarms-topic"
  }
}