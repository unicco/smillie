google.load("feeds", "1");
function initialize() {
  var feed = new google.feeds.Feed("http://blog.smillie.jp/?feed=rss2");
  feed.load(function(result) {
    if (!result.error) {
      var container = document.getElementById("feed");
      for (var i = 0; i < result.feed.entries.length; i++) {
        var entry = result.feed.entries[i];
        var li = document.createElement("li");
        var a = document.createElement("a");
        a.href = entry.link;
        a.appendChild(document.createTextNode(entry.title));
        li.appendChild(a);
        container.appendChild(li);
      }
    }
  });
}
google.setOnLoadCallback(initialize);
