ruleset meta {
  meta {
    shares meta
  }
  global {
    meta = function(rid=meta:rid){
      ctx:rulesets
        .filter(function(rs){rs.get("rid")==rid})
        .head()
        .get(["meta","krl"])
      + chr(10)
    }
  }
}
