ruleset notification {
  meta {
    name "notification"
    description <<
sends and receives notification with
  - application (optional) - name of the application/ruleset raising the notification event. If not application is given, the current ruleset ID is used.
  - subject (required) - subject (title) of the notification. Typically a subject is one line.
  - description (optional) - additional information beyond what is in the subject.
  - priority (optional) - Every notification has a priority. If not priority is given, the priority is 0. The priorities are:
    - -2 (Very low)
    - -1 (Moderate)
    - 0 (Normal)
    - +1 (High)
    - +2 (Emergency)
  - id (optional) - a unique identifier that the event raiser chooses.
Credit: <a href="https://www.windley.com/archives/2011/12/notifications_in_a_personal_event_networks.shtml">Notifications in Personal Event Networks</a>
>>
    use module io.picolabs.wrangler alias wrangler
    provides send_notification
  }
  global {
    send_notification = defaction(application,subject,description,priority,id){
      rid = meta:rid.klog("rid")
      app = application || rid
      level = priority || 0
      eci = meta:eci.klog("eci")
        || wrangler:channels("system,self").head().get("id")
      event:send({"eci":eci,"domain":"notification","type":"status",
        "attrs":{
          "application":app,
          "subject":subject,
          "description":description ||
            <<A status notification with priority 
              #{level} was received from #{app}.>>,
          "priority":level,
          "id":id
        }
      })
    }
  }
}
