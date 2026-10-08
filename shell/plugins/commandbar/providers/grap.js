.pragma library

// File search, folded into the command bar at the bottom of every result
// list. CommandBar.qml runs ripgrep and fd; this only shapes the rows.
//
//   pomodoro          content and filenames under ~
//   @yavin Panel      same search, scoped to ~/yavin
//   @~/.config hypr   an explicit path after @

var LIMIT = 6

function sh(s) { return "'" + String(s).replace(/'/g, "'\\''") + "'" }

function suppressed(query) {
  return /^\s*(w\s|kill(\s|$)|:|\?)/i.test(query)
}

function keywordMode(query, commands) {
  var text = String(query || "").replace(/^\s+/, "")
  var space = text.search(/\s/)
  if (space === -1) return false
  var word = text.slice(0, space).toLowerCase()
  var list = commands || []
  for (var i = 0; i < list.length; i++) {
    if (list[i] && String(list[i].keyword || "").toLowerCase() === word) return true
  }
  return false
}

function shortPath(p, home) {
  var path = String(p || "")
  return home && path.indexOf(home) === 0 ? "~" + path.slice(home.length) : path
}

function baseName(p) {
  var path = String(p || "")
  var i = path.lastIndexOf("/")
  return i === -1 ? path : path.slice(i + 1)
}

// { dir, pattern, label, key } or null when this query should not search.
function parse(query, home) {
  var q = String(query || "").trim()
  var root = String(home || "")
  var dir = root
  var pattern = q
  var label = "~"
  var scoped = /^@(\S+)\s+([\s\S]*)$/.exec(q)
  if (scoped) {
    var raw = scoped[1]
    if (raw.charAt(0) === "~") dir = root + raw.slice(1)
    else if (raw.charAt(0) === "/") dir = raw
    else dir = (root ? root + "/" : "") + raw
    pattern = scoped[2]
    label = raw.charAt(0) === "~" || raw.charAt(0) === "/" ? raw : "~/" + raw
  }
  pattern = pattern.trim()
  if (pattern.length < 2 || pattern.length > 160) return null
  if (!/[A-Za-z]/.test(pattern)) return null
  return { dir: dir, pattern: pattern, label: label, key: dir + "\0" + pattern }
}

// Text and source open in Cursor at the line. Anything whose mime handler is
// a real default app (PDF → zathura, images, video) opens as the file itself,
// so Cursor does not invent a buffer named "report.pdf:1".
function openTarget(file, line) {
  var f = sh(file)
  var loc = sh(file + ":" + line)
  return "mime=$(xdg-mime query filetype " + f + " 2>/dev/null || true); "
    + "desktop=$(xdg-mime query default \"$mime\" 2>/dev/null || true); "
    + "editor=; "
    + "case \"$mime\" in "
    + "text/*|application/javascript|application/json|application/xml|application/x-shellscript|application/x-sh|inode/x-empty) editor=1 ;; "
    + "esac; "
    + "case \"$desktop\" in "
    + "Nano.desktop|nano.desktop|*vim*|*nvim*|*emacs*|*gedit*|*kate*|*code*|*cursor*|*codium*|*zed*|*helix*|*sublime*|*lapce*) editor=1 ;; "
    + "esac; "
    + "if [ -n \"$editor\" ]; then "
    + "command -v cursor >/dev/null 2>&1 && exec uwsm-app -- cursor " + loc
    + " || exec r2-d2-launch-editor " + loc
    + "; fi; "
    + "if command -v uwsm-app >/dev/null 2>&1; then exec setsid uwsm-app -- xdg-open " + f
    + "; else exec xdg-open " + f + "; fi"
}

var provider = {
  id: "grap",
  name: "Grap",
  icon: "󰈞",
  help: [
    { id: "grap", title: "Search files",
      about: "Filenames and lines under your home directory, listed under everything else",
      examples: [
        { q: "pomodoro", note: "Files and matching lines, at the bottom of the list" },
        { q: "@yavin Panel", note: "Scope the search with @path" }
      ] }
  ],
  match: function(query, ctx) {
    if (suppressed(query) || keywordMode(query, ctx.commands)) return []
    var spec = parse(query, ctx.home)
    if (!spec) return []
    if (ctx.requestGrap) ctx.requestGrap(query)

    var cached = ctx.grap && ctx.grap.query === spec.key ? ctx.grap.hits : null
    if (!cached) {
      if (!ctx.grapSearching) return []
      return [{ title: "Searching files…", subtitle: spec.label, score: 12, icon: provider.icon, copy: "" }]
    }

    var out = []
    for (var i = 0; i < cached.length && i < LIMIT; i++) {
      var hit = cached[i]
      var file = String(hit.file || "")
      var dir = file.slice(0, file.lastIndexOf("/"))
      var where = shortPath(dir, ctx.home)
      var snippet = String(hit.snippet || "").replace(/\s+/g, " ").trim()
      if (snippet.length > 90) snippet = snippet.slice(0, 90) + "…"
      out.push({
        title: hit.isFile ? baseName(file) : baseName(file) + ":" + hit.line,
        subtitle: hit.isFile ? where : (snippet ? where + "  " + snippet : where),
        score: 12 - i * 0.01,
        icon: hit.isFile ? "󰈔" : provider.icon,
        copy: file + ":" + hit.line + ":" + (hit.col || 1),
        run: { kind: "run", target: openTarget(file, hit.line || 1), label: "open" }
      })
    }
    return out
  }
}
