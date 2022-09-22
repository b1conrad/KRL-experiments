ruleset testnotification {
  meta {
    use module notification
  }
  rule tester {
    select when testnotification test
      notification:send_notification(subject="this is a test")
  }
}
