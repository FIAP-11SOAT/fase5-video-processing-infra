# resource "aws_sns_topic" "alarms_topic" {
#   name = "${var.project_name}-alarms-topic"
#
#   tags = {
#     Name = "${var.project_name}-alarms-topic"
#   }
# }