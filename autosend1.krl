ruleset autosend1 {
  meta {
    use module io.picolabs.subscription alias subs
  }
  rule sendEvents {
    select when send_event one
    pre {
      other = subs:established().head().get("Tx")
    }
    if other then
    every {
      event:send({"eci":other,"domain":"event","type":"one"})
      event:send({"eci":other,"domain":"event","type":"two"})
    }
  }
}
