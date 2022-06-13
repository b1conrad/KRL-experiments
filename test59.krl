ruleset test59 {
  meta {
    use module io.picolabs.subscription alias subs
    shares subs_as_children
  }
  global {
    subs_as_children = function(){
      subs:established("Rx_role","participant list")
        .filter(function(s){s{"Tx_role"}=="participant"})
        .map(function(s){
            {"eci":s{"Tx"}, "name":s{"Rx"}.map(participant_name)}
          })
    }
  }
}
