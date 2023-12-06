ruleset self {
  meta {
    shares self
  }
  global {
    LF = chr(10)
    self = function(){
      s.join(LF)
      + "    s = " + s.pp() + LF
      + "    t = " + t.pp() + LF
      + t.join(LF) + LF
    }
    s = [
      "ruleset self {",
      "  meta {",
      "    shares self",
      "  }",
      "  global {",
      "    LF = chr(10)",
      "    self = function(){",
      "      s.join(LF)",
      "      + \"    s = \" + s.pp() + LF",
      "      + \"    t = \" + t.pp() + LF",
      "      + t.join(LF) + LF",
      "    }",
      "",
    ]
    t = [
      "    po = function(a,v){",
      "      a + LF + \"      \" + v.encode() + \",\"",
      "    }",
      "    pp = function(st){",
      "      st.reduce(po,\"[\") + LF + \"    ]\"",
      "    }",
      "  }",
      "}",
      "",
    ]
    po = function(a,v){
      a + LF + "      " + v.encode() + ","
    }
    pp = function(st){
      st.reduce(po,"[") + LF + "    ]"
    }
  }
}

