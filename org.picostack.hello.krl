ruleset org.picostack.hello {
  meta {
    name "greetings"
    use module io.picolabs.wrangler alias wrangler
    use module html.byu alias html
    shares greeting
  }
  global {
    event_domain = "org_picostack_hello"
    greeting = function(_headers){
      html:header("manage greetings","",null,null,_headers)
      + <<
<h1>Manage greetings</h1>
<p>
Hello, #{ent:name}!
</p>
>>
      + html:footer()
    }
  }
  rule initialize {
    select when wrangler ruleset_installed where event:attr("rids") >< meta:rid
    every {
      wrangler:createChannel(
        ["greetings"],
        {"allow":[{"domain":"org_picostack_hello","name":"*"}],"deny":[]},
        {"allow":[{"rid":meta:rid,"name":"*"}],"deny":[]}
      )
    }
    fired {
      raise org_picostack_hello event "factory_reset"
    }
  }
  rule keepChannelsClean {
    select when org_picostack_hello factory_reset
    foreach wrangler:channels(["greetings"]).reverse().tail() setting(chan)
    wrangler:deleteChannel(chan.get("id"))
  }
}
