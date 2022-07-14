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
      url = <<#{meta:host}/sky/event/#{meta:eci}/none/#{event_domain}/name_given>>
      html:header("manage greetings","",null,null,_headers)
      + <<
<h1>Manage greetings</h1>
<p>
Hello, #{ent:name.defaultsTo("world")}!
</p>
>>
      + (ent:name.isnull() => <<
<p>How do you wish to be greeted?</p>
<form action="#{url}">
<input name="name"><br>
<button type="submit">Submit</button>
</form>
>> | "")
<h2>Technical details</h2>
<pre>#{url}</pre>
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
  rule acceptAndStoreName {
    select when org_picostack_hello name_given
      name re#(.+)# setting(new_val)
    fired {
      ent:name := new_val
      raise org_picostack_hello event "name_saved" attributes event:attrs
    }
  }
  rule redirectBack {
    select when org_picostack_hello name_saved
    pre {
      referrer = event:attr("_headers").get("referer") // [sic]
    }
    if referrer then send_directive("_redirect",{"url":referrer})
  }
}
