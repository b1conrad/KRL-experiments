ruleset autosend2 {
  meta {
    shares lastHttpResponse
  }
  global {
    lastHttpResponse = function(){
      ent:last_http_response
    }
  }
  rule eventOne {
    select when event one
    http:post("https://example.com",
      autosend = {"eci": event:eci, "domain": "http", "type": "post", "name": "post"}
    )
  }
  rule save_last_http_response {
    select when http post
    fired {
      ent:last_http_response := event:attrs
    }
  }
  rule eventTwo {
    select when event two
  }
}
