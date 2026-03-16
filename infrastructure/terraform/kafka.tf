resource "aws_sqs_queue" "booking_events_dlq" {
  name = "${var.project_name}-booking-events-dlq"
}

resource "aws_sqs_queue" "pricing_events_dlq" {
  name = "${var.project_name}-pricing-events-dlq"
}

# In a managed deployment this module would be replaced by MSK, Confluent Cloud,
# or an equivalent event streaming service with topics for booking, fleet, and pricing events.
