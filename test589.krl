ruleset test589 {
  rule one {
    select when test one
    fired {
      raise test event "two" attributes {"test":"two"}
      raise test event "three" attributes {"test":"three"}
    }
  }
  rule two {
    select when test two
  }
  rule three {
    select when test three
  }
}
