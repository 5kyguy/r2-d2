.pragma library
.import "apps.js" as Apps

// When nothing installed matches, the selected row is a Google search and the
// row under it asks K-2SO. A matching app, sum, conversion or window stays
// selected because those score higher, and this provider stays quiet once an
// app matches so the list is just those apps.

function shellQuote(s) { return "'" + String(s).replace(/'/g, "'\\''") + "'" }

function keywordQuery(query, commands) {
  var text = String(query || "").replace(/^\s+/, "")
  var space = text.search(/\s/)
  var word = (space === -1 ? text : text.slice(0, space)).toLowerCase()
  var list = commands || []
  for (var i = 0; i < list.length; i++) {
    if (list[i] && String(list[i].keyword || "").toLowerCase() === word) return true
  }
  return false
}

var provider = {
  id: "search",
  name: "Search",
  icon: "󰍉",
  help: [
    { id: "search", title: "Search", about: "A query that names no app opens Google, with K-2SO on the next row",
      examples: ["weather tomorrow"] }
  ],
  match: function(query, ctx) {
    var q = String(query || "").trim()
    if (!q || keywordQuery(query, ctx.commands)) return []
    if (/^\s*(w\s|kill(\s|$)|:)/i.test(query)) return []
    if (Apps.provider.match(query, ctx).length > 0) return []

    var google = "https://www.google.com/search?q=" + encodeURIComponent(q)
    var ask = "if k2so ask " + shellQuote(q) + "; then "
      + "r2-d2-notification-send -g '󰚩' 'K-2SO' 'Task queued' -t 3000; "
      + "else r2-d2-notification-send -g '󰚩' --urgency critical 'K-2SO' 'Failed to queue task — is k2so serve running?' -t 5000; exit 1; fi"
    return [
      { title: "Google", subtitle: q, score: 40, icon: "󰖟", copy: q, run: { kind: "open", target: google, label: "search" } },
      { title: "Ask K-2SO", subtitle: q, score: 39, icon: "󰚩", copy: q, run: { kind: "run", target: ask, label: "ask" } }
    ]
  }
}
