.pragma library

// The R2-D2 menu tree. The command bar draws it; r2-d2-menu runs the actions
// and reports which rows exist right now (a laptop lid, a package that is
// installed, a recording already in progress).

function words(text) {
  return String(text || "").toLowerCase().split(/[^a-z0-9]+/).filter(function(w) { return w.length > 0 })
}

function prefixesAll(queryWords, hay) {
  for (var i = 0; i < queryWords.length; i++) {
    var hit = false
    for (var j = 0; j < hay.length && !hit; j++) hit = hay[j].indexOf(queryWords[i]) === 0
    if (!hit) return false
  }
  return true
}

function read(state, path) {
  var cur = state || {}
  var parts = String(path || "").split(".")
  for (var i = 0; i < parts.length; i++) {
    if (cur === null || cur === undefined || typeof cur !== "object") return undefined
    cur = cur[parts[i]]
  }
  return cur
}

function flag(state, key) {
  var name = String(key || "")
  var neg = name.charAt(0) === "!"
  if (neg) name = name.slice(1)
  var on = !!read(state, name)
  return neg ? !on : on
}

function item(id, parent, title, icon, extra) {
  var node = { id: id, parent: parent, title: title, icon: icon || "" }
  if (extra) {
    for (var k in extra) node[k] = extra[k]
  }
  return node
}

// `when` is a key in the state object from `r2-d2-menu state`. "!" hides the
// row when that key is set. `current`/`value` mark the row that is in effect.
// `run` is the id `r2-d2-menu run` executes. No `run` means the row opens.
var NODES = [
  item("apps", "root", "Apps", "󰀻", { kind: "apps", keywords: "applications launcher walker" }),
  item("trigger", "root", "Trigger", "󱓞"),
  item("setup", "root", "Setup", "", { keywords: "settings" }),
  item("restart", "root", "Restart", "󰍜"),
  item("install", "root", "Install", "󰉉"),
  item("update", "root", "Update", "", { keywords: "upgrade refresh" }),
  item("remove", "root", "Remove", "󰭌", { keywords: "uninstall" }),
  item("about", "root", "About", "", { run: "about" }),
  item("system", "root", "System", "", { keywords: "power" }),

  item("toggle", "trigger", "Toggle", "󰔎"),
  item("screenshot", "trigger", "Screenshot", "", { run: "screenshot", keywords: "capture" }),
  item("screenrecord", "trigger", "Screenrecord", "", { keywords: "record video capture" }),
  item("share", "trigger", "Share", ""),

  item("toggle.bar", "toggle", "Top bar", "󰍜", { run: "toggle.bar" }),
  item("toggle.display", "toggle", "Display", "󰍹", { run: "toggle.display" }),
  item("toggle.mirror", "toggle", "Mirror", "󰍺", { run: "toggle.mirror" }),
  item("toggle.notifications", "toggle", "Notifications", "󰂵", { run: "toggle.notifications" }),
  item("toggle.idle", "toggle", "Idle", "󱫖", { run: "toggle.idle" }),
  item("toggle.layout", "toggle", "Layout", "󱂬", { run: "toggle.layout" }),
  item("toggle.workspaces", "toggle", "Workspace apps", "󰖲", { run: "toggle.workspaces" }),
  item("toggle.scaling", "toggle", "Scaling", "󰍹", { run: "toggle.scaling" }),
  item("toggle.screensaver", "toggle", "Screensaver", "󱄄", { run: "toggle.screensaver" }),
  item("toggle.crash", "toggle", "Crash capture", "󰻌", { run: "toggle.crash" }),

  item("screenrecord.stop", "screenrecord", "Stop recording", "", { run: "screenrecord.stop", when: "recording" }),
  item("screenrecord.none", "screenrecord", "With no audio", "", { run: "screenrecord.none", when: "!recording" }),
  item("screenrecord.desktop", "screenrecord", "With desktop audio", "", { run: "screenrecord.desktop", when: "!recording" }),
  item("screenrecord.mic", "screenrecord", "With desktop + microphone audio", "", { run: "screenrecord.mic", when: "!recording", keywords: "mic" }),
  item("screenrecord.webcam", "screenrecord", "With desktop + microphone audio + webcam", "", { run: "screenrecord.webcam", when: "!recording", keywords: "camera" }),

  item("share.clipboard", "share", "Clipboard", "", { run: "share.clipboard" }),
  item("share.file", "share", "File", "", { run: "share.file" }),
  item("share.folder", "share", "Folder", "", { run: "share.folder" }),

  item("capture", "", "Capture", "", { keywords: "screenshot screenrecord" }),
  item("capture.screenshot", "capture", "Screenshot", "", { run: "screenshot" }),
  item("capture.screenrecord", "capture", "Screenrecord", "", { kind: "menu", menu: "screenrecord" }),
  item("capture.qr", "capture", "QR code", "󰐲", { run: "capture.qr", keywords: "qr" }),

  item("text", "setup", "Text size", ""),
  item("defaults", "setup", "Default apps", ""),
  item("monitors", "setup", "Monitors", "󰍹", { keywords: "display dock laptop" }),
  item("sleep", "setup", "System Sleep", "", { keywords: "suspend hibernate lid" }),
  item("setup.dns", "setup", "DNS", "󰱔", { run: "setup.dns" }),
  item("security", "setup", "Security", ""),
  item("dictation", "setup", "Dictation (Voxtype)", "", { keywords: "voice whisper" }),
  item("setup.webcam", "setup", "Fix webcam (AMD)", "📷", { run: "setup.webcam", keywords: "camera amd" }),
  item("setup.doctor", "setup", "Dependencies", "", { run: "setup.doctor", keywords: "doctor" }),
  item("setup.reset-sudo", "setup", "Reset sudo (lockout)", "󰒲", { run: "setup.reset-sudo", keywords: "sudo" }),

  item("text.10", "text", "Small (10)", "", { run: "text.10", current: "textSize", value: "10" }),
  item("text.12", "text", "Default (12)", "", { run: "text.12", current: "textSize", value: "12" }),
  item("text.14", "text", "Large (14)", "", { run: "text.14", current: "textSize", value: "14" }),
  item("text.16", "text", "Larger (16)", "", { run: "text.16", current: "textSize", value: "16" }),
  item("text.custom", "text", "Custom…", "", { run: "text.custom" }),

  item("defaults.text", "defaults", "Text", "", { run: "defaults.text" }),
  item("defaults.pdf", "defaults", "PDF", "", { run: "defaults.pdf" }),
  item("defaults.images", "defaults", "Images", "", { run: "defaults.images" }),
  item("defaults.video", "defaults", "Video", "", { run: "defaults.video" }),

  item("monitors.save.docked", "monitors", "Save docked", "󰍹", { run: "monitors.save.docked" }),
  item("monitors.save.laptop", "monitors", "Save laptop", "󰍹", { run: "monitors.save.laptop" }),
  item("monitors.apply.docked", "monitors", "Apply docked", "󰍺", { run: "monitors.apply.docked" }),
  item("monitors.apply.laptop", "monitors", "Apply laptop", "󰍺", { run: "monitors.apply.laptop" }),

  item("sleep.suspend.on", "sleep", "Enable Suspend", "󰒲", { run: "sleep.suspend", when: "suspendOff" }),
  item("sleep.suspend.off", "sleep", "Disable Suspend", "󰒲", { run: "sleep.suspend", when: "!suspendOff" }),
  item("sleep.hibernate.on", "sleep", "Enable Hibernate", "󰤁", { run: "sleep.hibernate.on", when: "!hibernate" }),
  item("sleep.hibernate.off", "sleep", "Disable Hibernate", "󰤁", { run: "sleep.hibernate.off", when: "hibernate" }),
  item("lid", "sleep", "Lid", "󰌢", { when: "laptop", keywords: "close laptop" }),

  item("lid.suspend", "lid", "Suspend", "󰒲", { run: "lid.suspend", current: "lid", value: "suspend" }),
  item("lid.lock", "lid", "Lock", "", { run: "lid.lock", current: "lid", value: "lock" }),
  item("lid.ignore", "lid", "Keep running", "󰈈", { run: "lid.ignore", current: "lid", value: "ignore" }),

  item("security.fingerprint", "security", "Fingerprint", "󰈷", { run: "security.fingerprint" }),
  item("security.fido2", "security", "Fido2", "", { run: "security.fido2" }),
  item("security.docker.on", "security", "Sudoless Docker", "", { run: "security.docker.on", when: "dockerSudoless" }),
  item("security.docker.off", "security", "Disable Sudoless Docker", "", { run: "security.docker.off", when: "!dockerSudoless" }),

  item("dictation.config", "dictation", "Config", "", { run: "dictation.config" }),
  item("dictation.models", "dictation", "Model", "󱚤"),
  item("dictation.status", "dictation", "Status", "󰒲", { run: "dictation.status" }),
  item("dictation.model.tiny.en", "dictation.models", "tiny.en", "󱚤", { run: "dictation.model.tiny.en", current: "dictationModel", value: "tiny.en" }),
  item("dictation.model.base.en", "dictation.models", "base.en", "󱚤", { run: "dictation.model.base.en", current: "dictationModel", value: "base.en" }),
  item("dictation.model.small.en", "dictation.models", "small.en", "󱚤", { run: "dictation.model.small.en", current: "dictationModel", value: "small.en" }),
  item("dictation.model.medium.en", "dictation.models", "medium.en", "󱚤", { run: "dictation.model.medium.en", current: "dictationModel", value: "medium.en" }),
  item("dictation.model.large-v3-turbo", "dictation.models", "large-v3-turbo", "󱚤", { run: "dictation.model.large-v3-turbo", current: "dictationModel", value: "large-v3-turbo" }),

  item("restart.shell", "restart", "Shell", "󰍜", { run: "restart.shell" }),
  item("restart.walker", "restart", "Walker", "󰍜", { run: "restart.walker" }),
  item("restart.pipewire", "restart", "Pipewire", "󰍜", { run: "restart.pipewire" }),
  item("restart.terminal", "restart", "Terminal", "󰍜", { run: "restart.terminal" }),
  item("restart.wifi", "restart", "Wifi", "󰍜", { run: "restart.wifi" }),
  item("restart.bluetooth", "restart", "Bluetooth", "󰍜", { run: "restart.bluetooth" }),
  item("restart.hyprctl", "restart", "Hyprctl", "󰍜", { run: "restart.hyprctl" }),

  item("install.package", "install", "Package", "󰣇", { run: "install.package" }),
  item("install.aur", "install", "AUR", "󰣇", { run: "install.aur" }),
  item("install.webapp", "install", "Web App", "", { run: "install.webapp" }),
  item("install.appimage", "install", "AppImage", "󰣇", { run: "install.appimage" }),
  item("install.dev", "install", "Development", "󰵮"),
  item("install.editor", "install", "Editor", "󰆼"),
  item("install.k2so", "install", "K-2SO (companion)", "󰚩", { run: "install.k2so", keywords: "agent" }),
  item("install.brook", "install", "Brook", "󰝚", { run: "install.brook", keywords: "music player" }),
  item("install.dropbox", "install", "Dropbox", "󰒲", { run: "install.dropbox" }),
  item("install.tailscale", "install", "Tailscale", "󰒲", { run: "install.tailscale" }),

  item("install.dev.node", "install.dev", "Node.js", "", { run: "install.dev.node" }),
  item("install.dev.go", "install.dev", "Go", "", { run: "install.dev.go" }),
  item("install.dev.python", "install.dev", "Python", "", { run: "install.dev.python" }),
  item("install.dev.rust", "install.dev", "Rust", "", { run: "install.dev.rust" }),

  item("install.editor.cursor", "install.editor", "Cursor", "󰆾", { run: "install.editor.cursor" }),
  item("install.editor.vscode", "install.editor", "VS Code", "󰨞", { run: "install.editor.vscode" }),
  item("install.editor.t3code", "install.editor", "T3 Code", "󰆼", { run: "install.editor.t3code" }),
  item("install.editor.opencode", "install.editor", "OpenCode", "", { run: "install.editor.opencode" }),
  item("install.editor.hermes", "install.editor", "Hermes", "󰚩", { run: "install.editor.hermes" }),

  item("remove.package", "remove", "Package", "󰣇", { run: "remove.package" }),
  item("remove.drop", "remove", "Drop package (by name)", "󰒲", { run: "remove.drop" }),
  item("remove.webapp", "remove", "Web App", "", { run: "remove.webapp", when: "remove.webapp" }),
  item("remove.webapps", "remove", "Web Apps (all)", "", { run: "remove.webapps", when: "remove.webapp" }),
  item("remove.dev", "remove", "Development", "󰵮", { when: "remove.development" }),
  item("remove.editor", "remove", "Editor", "󰆼", { when: "remove.editor" }),
  item("remove.dictation", "remove", "Dictation", "", { run: "remove.dictation", when: "remove.dictation" }),
  item("remove.fingerprint", "remove", "Fingerprint", "󰈷", { run: "remove.fingerprint", when: "remove.fingerprint" }),
  item("remove.fido2", "remove", "Fido2", "", { run: "remove.fido2", when: "remove.fido2" }),
  item("remove.docker", "remove", "Sudoless Docker", "", { run: "remove.docker", when: "!dockerSudoless" }),

  item("remove.dev.node", "remove.dev", "Node.js", "", { run: "remove.dev.node", when: "remove.node" }),
  item("remove.dev.go", "remove.dev", "Go", "", { run: "remove.dev.go", when: "remove.go" }),
  item("remove.dev.python", "remove.dev", "Python", "", { run: "remove.dev.python", when: "remove.python" }),
  item("remove.dev.rust", "remove.dev", "Rust", "", { run: "remove.dev.rust", when: "remove.rust" }),

  item("remove.editor.cursor", "remove.editor", "Cursor", "󰆾", { run: "remove.editor.cursor", when: "remove.cursor" }),
  item("remove.editor.vscode", "remove.editor", "VS Code", "󰨞", { run: "remove.editor.vscode", when: "remove.vscode" }),
  item("remove.editor.t3code", "remove.editor", "T3 Code", "󰆼", { run: "remove.editor.t3code", when: "remove.t3code" }),
  item("remove.editor.opencode", "remove.editor", "OpenCode", "", { run: "remove.editor.opencode", when: "remove.opencode" }),
  item("remove.editor.hermes", "remove.editor", "Hermes", "󰚩", { run: "remove.editor.hermes", when: "remove.hermes" }),

  item("update.full", "update", "R2-D2 (full)", "", { run: "update.full" }),
  item("update.config", "update", "Config (user config)", "", { run: "update.config" }),
  item("update.packages", "update", "Packages", "󰣇", { run: "update.packages" }),
  item("update.brook", "update", "Brook", "󰝚", { run: "update.brook", when: "brook", keywords: "music player" }),
  item("update.webcam", "update", "Webcam", "📷", { run: "update.webcam" }),
  item("update.password", "update", "Password", ""),
  item("update.timezone", "update", "Timezone & Time", "", { run: "update.timezone" }),
  item("reinstall", "update", "Reinstall", "󰒲"),

  item("update.password.drive", "update.password", "Drive Encryption", "", { run: "update.password.drive" }),
  item("update.password.user", "update.password", "User", "", { run: "update.password.user" }),

  item("reinstall.full", "reinstall", "Reinstall (full)", "󰒲", { run: "reinstall.full" }),
  item("reinstall.packages", "reinstall", "Reinstall packages only", "󰣇", { run: "reinstall.packages" }),
  item("reinstall.configs", "reinstall", "Reinstall configs only", "󰒲", { run: "reinstall.configs" }),
  item("reinstall.git", "reinstall", "Reinstall git (re-clone)", "󰒲", { run: "reinstall.git" }),

  item("system.lock", "system", "Lock", "", { run: "system.lock", keywords: "lock screen" }),
  item("system.screensaver", "system", "Screensaver", "󱄄", { run: "system.screensaver" }),
  item("system.suspend", "system", "Suspend", "󰒲", { run: "system.suspend", when: "!suspendOff", keywords: "sleep" }),
  item("system.hibernate", "system", "Hibernate", "󰤁", { run: "system.hibernate", when: "hibernate" }),
  item("system.logout", "system", "Logout", "󰍃", { run: "system.logout" }),
  item("system.reboot", "system", "Restart", "󰜉", { run: "system.reboot", keywords: "reboot" }),
  item("system.shutdown", "system", "Shutdown", "󰐥", { run: "system.shutdown", keywords: "poweroff power off" })
]

var BY_ID = {}
var CHILDREN = {}
for (var i = 0; i < NODES.length; i++) {
  BY_ID[NODES[i].id] = NODES[i]
  var parent = NODES[i].parent || ""
  if (!CHILDREN[parent]) CHILDREN[parent] = []
  CHILDREN[parent].push(NODES[i])
}

var ALIASES = {
  go: "root",
  root: "root",
  apps: "apps",
  trigger: "trigger",
  capture: "capture",
  share: "share",
  screenrecord: "screenrecord",
  toggle: "toggle",
  setup: "setup",
  lid: "lid",
  defaults: "defaults",
  monitors: "monitors",
  restart: "restart",
  install: "install",
  remove: "remove",
  update: "update",
  system: "system",
  about: "about"
}

function byId(id) { return BY_ID[String(id || "")] || null }

function resolve(name) {
  var key = String(name || "").trim().toLowerCase()
  if (!key) return "root"
  if (ALIASES[key]) return ALIASES[key]
  if (BY_ID[key]) return key
  return "root"
}

function parentOf(id) {
  if (!id || id === "root") return ""
  var node = byId(id)
  if (!node || !node.parent) return "root"
  return node.parent
}

function title(id) {
  if (!id || id === "root") return "Menu"
  var node = byId(id)
  return node ? node.title : "Menu"
}

function ancestors(node) {
  var out = []
  var guard = 0
  var cur = node
  while (cur && cur.parent && guard < 8) {
    var parent = byId(cur.parent)
    if (!parent) break
    out.unshift(parent.title)
    cur = parent
    guard++
  }
  return out
}

function crumb(node) {
  var names = ancestors(node)
  return names.join(" › ")
}

function chip(id) {
  if (!id || id === "root") return { label: "Menu", icon: "󰍜" }
  var node = byId(id)
  if (!node) return { label: "Menu", icon: "󰍜" }
  var path = ancestors(node).concat([node.title]).join(" › ")
  return { label: path, icon: node.icon || "󰍜" }
}

function shown(node, state) {
  if (!node || node.kind === "apps") return true
  if (!node.when) return true
  return flag(state, node.when)
}

function isCurrent(node, state) {
  if (!node.current) return false
  return String(read(state, node.current) || "") === String(node.value)
}

function shellQuote(s) { return "'" + String(s).replace(/'/g, "'\\''") + "'" }

function shape(node, state, score, searching) {
  var openId = node.kind === "menu" ? node.menu : (!node.run && node.kind !== "apps" ? node.id : "")
  var branch = !!openId
  var apps = node.kind === "apps"
  var path = crumb(node)
  var subtitle = ""
  if (isCurrent(node, state)) subtitle = "Current"
  else if (searching && path) subtitle = path
  var run
  if (apps) run = { kind: "apps", target: "", label: "search" }
  else if (branch) run = { kind: "menu", target: openId, label: "open" }
  else run = { kind: "run", target: "r2-d2-menu run " + shellQuote(node.run), label: "run" }
  return {
    provider: "menu",
    providerName: "Menu",
    icon: node.icon || "",
    image: "",
    title: node.title,
    subtitle: subtitle,
    copy: "",
    run: run,
    complete: "",
    select: false,
    actionLabel: apps ? "Search" : (branch ? "Open" : "Run"),
    score: score,
    group: "Menu",
    section: "",
    hero: false
  }
}

function children(id, state) {
  var list = CHILDREN[id || ""] || []
  var out = []
  for (var i = 0; i < list.length; i++) {
    if (shown(list[i], state)) out.push(list[i])
  }
  return out
}

function browse(id, state) {
  var list = children(id || "root", state)
  var rows = []
  for (var i = 0; i < list.length; i++) rows.push(shape(list[i], state, 1000 - i, false))
  if (rows.length > 0) rows[0].section = title(id)
  return rows
}

function rank(node, q, qw) {
  var title = node.title.toLowerCase()
  if (title === q) return 96
  if (title.indexOf(q) === 0) return 92
  if (prefixesAll(qw, words(node.title + " " + (node.keywords || "")))) return 86
  if (prefixesAll(qw, words(crumb(node) + " " + node.title + " " + (node.keywords || "")))) return 78
  return 0
}

function searchHits(query, state) {
  var q = String(query || "").trim().toLowerCase().replace(/\s+/g, " ")
  var qw = words(q)
  if (!q || qw.length === 0) return []
  var hits = []
  for (var i = 0; i < NODES.length; i++) {
    var node = NODES[i]
    if (!shown(node, state)) continue
    var score = rank(node, q, qw)
    if (score > 0) hits.push({ node: node, rank: score, seq: i })
  }
  hits.sort(function(a, b) {
    if (b.rank !== a.rank) return b.rank - a.rank
    return a.seq - b.seq
  })
  return hits
}

function search(query, state) {
  var hits = searchHits(query, state)
  var rows = []
  for (var i = 0; i < hits.length && i < 30; i++) rows.push(shape(hits[i].node, state, hits[i].rank, true))
  if (rows.length > 0) rows[0].section = "Menu"
  return rows
}

// Super+Space. Kept under app matches (those score from the mid-70s up) and
// above Google (40), so a menu action is selected only when no app is.
function cap(rank) {
  if (rank >= 96) return 74
  if (rank >= 92) return 73
  if (rank >= 86) return 71
  return 68
}

function suppressed(query) {
  return /^\s*(w\s|kill(\s|$)|:|\?)/i.test(query)
}

function providerRows(query, state) {
  var q = String(query || "").trim()
  if (q.length < 2 || suppressed(query)) return []
  var hits = searchHits(q, state).slice(0, 6)
  var rows = []
  for (var i = 0; i < hits.length; i++) {
    var row = shape(hits[i].node, state, cap(hits[i].rank), true)
    rows.push({
      title: row.title,
      subtitle: row.subtitle,
      icon: row.icon,
      score: row.score,
      copy: "",
      run: row.run,
      actionLabel: row.actionLabel
    })
  }
  return rows
}

function splice(rows, hits) {
  if (!hits || hits.length === 0) return rows || []
  var list = rows ? rows.slice() : []
  var score = hits[0].score
  var at = 0
  while (at < list.length && list[at].score >= score) at++
  var block = []
  for (var i = 0; i < hits.length; i++) {
    var row = hits[i]
    row.provider = "menu"
    row.providerName = "Menu"
    row.group = "Menu"
    row.section = i === 0 ? "Menu" : ""
    row.hero = false
    row.image = row.image || ""
    row.copy = ""
    block.push(row)
  }
  return list.slice(0, at).concat(block).concat(list.slice(at))
}

var provider = {
  id: "menu",
  name: "Menu",
  icon: "󰍜",
  help: [
    { id: "menu", title: "Menu", about: "System actions: lock, record, install, update. Super+Alt+Space opens the list",
      examples: ["lock", "screenrecord", { q: "update", note: "Opens Update" }] }
  ],
  match: function(query, ctx) {
    if (ctx && ctx.menuId) return []
    return providerRows(query, ctx && ctx.menuState)
  }
}
