ruleset calibrate_schedule_event {
  meta {
    name "events"
    use module io.picolabs.wrangler alias wrangler
    use module html
    shares event, settings, list
  }
  global {
    event_domain = "calibrate_schedule_event"
    styles = <<<style type="text/css">
table {
  border: 1px solid black;
  border-collapse: collapse;
}
td {
  border: 1px solid black;
  padding: 5px;
  vertical-align: top;
}
</style>
>>
    event = function(_headers){
      delURL = <<#{meta:host}/sky/event/#{meta:eci}/none/#{event_domain}>>
      html:header("manage events",styles,null,null,_headers)
      + <<
<h1
  style="float:right;cursor:pointer"
  title="Settings"
  onclick="location='settings.html'">⚙</h1>
<h1>Manage events</h1>
<pre>
ent:id is #{ent:id.get("id")}
ent:period is #{ent:period}
schedule:list is #{schedule:list().encode()}
</pre>
<table>
<tr>
<td>id</td>
<td>type</td>
<td>when</td>
<td>event</td>
<td>delete</td>
</tr>
#{schedule:list().map(function(v){
type = v{"type"}
<<<tr>
<td>#{v{"id"}}</td>
<td>#{type}</td>
<td>#{type=="repeat" => v{"timespec"} | time:new(v{"time"})}</td>
<td>#{v{"event"}.encode().replace(re#,#g,",<br>")}</td>
<td><a href="#{delURL}/event_not_needed?id=#{v{"id"}}">del</a></td>
</tr>
>>}).values().join("")}
</table>
>>
      + html:footer()
    }
    settings = function(_headers){
      baseURL = <<#{meta:host}/sky/event/#{meta:eci}/none/#{event_domain}>>
      html:header("event settings","",null,null,_headers)
      + <<
<h1>Event Settings</h1>
<h2>Set an event for 8 a.m. daily.</h2>
<form action="#{baseURL}/eight_a_m">
<button type="submit">Set</button>
</form>
<h2>Submit the number of seconds between events.</h2>
<form action="#{baseURL}/new_period">
Every <input type="text" name="period" value="#{ent:period || 5}"> seconds.
<button type="submit">Submit</button>
</form>
<p>Stop current periodic event.</p>
<form action="#{baseURL}/clear_request">
<button type="submit">Stop</button>
</form>
<h2>Set a future one-time event.</h2>
<form action="#{baseURL}/new_one_time_event">
In <input type="number" min="1" name="how_many"> 
<select name="unit" required>
<option value="">Select a unit</option>
<option value="days">days</option>
<option value="weeks">weeks</option>
<option value="hours">hours</option>
<option value="minutes">minutes</option>
<option value="seconds">seconds</option>
</select>.
<button type="submit">Set</button>
</form>
<h2>Cancel and go back to Events page</h2>
<form action="#{baseURL}/settings_cancel">
<button type="submit">Cancel</button>
</form>
>>
      + html:footer()
    }
    list = function(){
      schedule:list()
    }
  }
  rule initialize {
    select when wrangler ruleset_installed where event:attr("rids") >< meta:rid
    every {
      wrangler:createChannel(
        ["events"],
        {"allow":[{"domain":event_domain,"name":"*"}],"deny":[]},
        {"allow":[{"rid":meta:rid,"name":"*"}],"deny":[]}
      )
    }
    fired {
      raise calibrate_schedule_event event "factory_reset"
    }
  }
  rule keepChannelsClean {
    select when calibrate_schedule_event factory_reset
    foreach wrangler:channels(["events"]).reverse().tail() setting(chan)
    wrangler:deleteChannel(chan.get("id"))
  }
  rule checkForValidPeriod {
    select when calibrate_schedule_event new_period
    pre {
      period = event:attr("period").as("Number").math:floor()
      acceptable = 0 < period && period <= 60
    }
    if acceptable then noop()
    fired {
      ent:period := period
    } else {
      last
    }
  }
  rule removeCurrentPeriod {
    select when calibrate_schedule_event new_period
             or calibrate_schedule_event clear_request
             or calibrate_schedule_event eight_a_m
    if ent:id then schedule:remove(ent:id)
    fired {
      clear ent:id
    }
  }
  rule dailyAtEight {
    select when calibrate_schedule_event eight_a_m
    fired {
      schedule notification event "eight_a_m"
        repeat << 0 8 * * * >>  attributes { } setting(id)
      ent:id := id
    }
  }
  rule changePeriod {
    select when calibrate_schedule_event new_period
    fired {
      schedule notification event "repeating_event"
        repeat << */#{ent:period} * * * * * >>  attributes { } setting(id)
      ent:id := id
    }
  }
  rule removeUnneededEvent {
    select when calibrate_schedule_event event_not_needed
      id re#(.+)# setting(id)
    schedule:remove(id)
    fired {
      clear ent:id if ent:id == id || ent:id{"id"} == id
    }
  }
  rule setOneTimeEvent {
    select when calibrate_schedule_event new_one_time_event
      how_many re#(\d+)#
      unit re#(.+)#
      setting(how_many,unit)
    pre {
      quantity = how_many.as("Number")
      when = time:add(time:now(),{}.put(unit,quantity))
    }
    fired {
      schedule notification event "one_time" at when
    }
  }
  rule redirectBack {
    select when calibrate_schedule_event new_period
             or calibrate_schedule_event clear_request
             or calibrate_schedule_event event_not_needed
             or calibrate_schedule_event settings_cancel
             or calibrate_schedule_event new_one_time_event
             or calibrate_schedule_event eight_a_m
    pre {
      referrer = event:attr("_headers").get("referer") // sic
    }
    if referrer then send_directive("_redirect",
      {"url":referrer.replace("settings","event")})
  }
}
