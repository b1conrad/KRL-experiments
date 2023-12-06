ruleset self {
  meta {
    shares self
  }
  global {
    self = function(){
      s.join(chr(10))
      + "    s = " + s.encode() + chr(10)
      + "    t = " + t.encode()
      + t.join(chr(10))
      + chr(10)
    }
    s = ["ruleset self {","  meta {","    shares self","  }","  global {","    self = function(){","      s.join(chr(10))","      + \"    s = \" + s.encode() + chr(10)","      + \"    t = \" + t.encode()","      + t.join(chr(10))","      + chr(10)","    }",""]
    t = ["","  }","}",""]
  }
}
