ruleset test59 {
  meta {
    use module io.picolabs.wrangler alias wrangler
    use module io.picolabs.subscription alias subs
    shares subs_as_children
  }
  global {
    subs_as_children = function(){
      participant_name = function(eci){
        wrangler:channels()
          .filter(function(c){c{"id"}==eci})
          .head()
          .get("tags")
          .filter(function(t){t != "participant"})
          .head()
      }
      subs:established("Rx_role","participant list")
        .filter(function(s){s{"Tx_role"}=="participant"})
        .map(function(s){
            {"eci":s{"Tx"}, "name":s{"Rx"}.participant_name()}
          })
    }
  }
}
