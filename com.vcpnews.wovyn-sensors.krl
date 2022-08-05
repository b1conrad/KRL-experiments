ruleset com.vcpnews.wovyn-sensors {
  meta {
    name "wovyn_sensors"
    use module io.picolabs.wrangler alias wrangler
    shares wovyn_sensor
  }
  global {
    event_domain = "com_vcpnews_wovyn_sensors"
    wovyn_sensor = function(_headers){
      ent:lastResponse
    }
    url = "https://byname.byu.edu:8080/sky/event/cl6gkrzzt04mpjbpb7hfx3ufp/hb/com_vcpnews_wovyn_sensors/heartbeat"
  }
  rule initialize {
    select when wrangler ruleset_installed where event:attr("rids") >< meta:rid
    every {
      wrangler:createChannel(
        ["wovyn_sensors"],
        {"allow":[{"domain":event_domain,"name":"*"}],"deny":[]},
        {"allow":[{"rid":meta:rid,"name":"*"}],"deny":[]}
      )
    }
    fired {
      raise com_vcpnews_wovyn_sensors event "factory_reset"
    }
  }
  rule keepChannelsClean {
    select when com_vcpnews_wovyn_sensors factory_reset
    foreach wrangler:channels(["wovyn_sensors"]).reverse().tail() setting(chan)
    wrangler:deleteChannel(chan.get("id"))
  }
  rule forwardHeartbeat {
    select when com_vcpnews_wovyn_sensors heartbeat
    http:post(url,json=event:attrs) setting(response)
    fired {
      ent:lastResponse := response
    }
  }
}
