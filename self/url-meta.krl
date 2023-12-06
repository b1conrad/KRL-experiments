ruleset url-meta {
  meta {
    shares url
  }
  global {
    url = function(){
      <<
<pre style="word-wrap: break-word;white-space: pre-wrap;">
<script>document.write(location.href.split("/").slice(2).join("/"))</script>
</pre>
      >>
    }
  }
}
