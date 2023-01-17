ruleset test.event_send.sub {
  meta {
    use module io.picolabs.subscription alias subs
  }
  global {
    resp = function(candidate_subs){
      candidate_subs{"Rx_role"} == "petitioner"
      && candidate_subs{"Tx_role"} == "responder"
    }
  }
  rule notifyRespondents {
    select when petitioner has_answered
    foreach subs:established().filter(resp) setting(s)
    event:send({"sub":s{"Id"},"eid":"none",
      "domain":"petitioner","type":"has_answered",
      "attrs":event:attrs},s{"Tx_host"})
  }
}
