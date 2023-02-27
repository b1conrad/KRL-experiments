ruleset net.atlassian.picolabs.HTTP {
  meta {
    description <<
      Check sample KRL code in the documentation page.
    >>
  }
  rule r1 {
   select when web pageview url re#/archives/#
   http:post("http://www.example.com/go", form = {"answer": "x"})
  }
  rule r2 {
   select when web pageview url re#/archives/#
   http:post("https://example.com/printenv.pl",
     body =
                << <?xml encoding='UTF-8'?>
                   <feed version='0.3'>
                   </feed> >>,
     headers = {"content-type": "application/xml"});
  }
  rule r1 {
    select when web pageview url re#archives/(\d+)# setting(year) 
    http:post("http://www.example.com/go"),
      form = {"answer": "x"},
      autoraise = "example");
  }
  rule r1 {
    select when web pageview url re#archives/(\d+)# setting(year) 
    http:post("http://www.example.com/go", form = {"answer": "x}) setting (resp)
    always {
      raise explicit event "post" attributes resp
    }
  }
  rule r2 {
    select when http post 
                 label re#example#
                 status_code re#(2\d\d)# setting (status)
    send_directive("Status", {"status":"Success! The status is " + status});
  }
   
  rule r3 {
    select when http post
                 label re#example#
                 status_code re#([45]\d\d)# setting (status)
    fired {
      log error <<#{status}: #{event:attr("status_line")}>>;
      last;
    }
  }
  rule r4 {
    select when http post label re#example#
    if(event:attr("content_type") like "^text/") then
      send_directive("Page says...", {"content":event:attr("content")});
  }
}
