ruleset url {
  meta {
    shares url
  }
  global {
    url = function(){
      bare_host = meta:host.split("/").splice(0,2).join("/")
      //<<<script>document.write(location.href.substring(7))</script> >>
      <<#{bare_host}/c/#{meta:eci}/query/url/url.txt>>
    }
  }
}
