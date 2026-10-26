import QtQuick

// Matrix digital rain drawn on a single retained canvas: each tick paints
// only the falling glyph heads and covers the frame with a translucent
// black wash that fades their trails — the classic single-canvas technique.
// The timer runs only while visible, so a hidden saver costs nothing.
Canvas {
  id: root

  // Glyph pool: half-width katakana, digits, and a few symbols, matching
  // the flavor of the tte screensaver show.
  readonly property string glyphs: "ｦｧｨｩｪｫｬｭｮｯｰｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜﾝ0123456789Z:・.\"=*+-<>¦╌"

  property int fontSize: Math.max(14, Math.min(28, Math.round(height / 42)))
  readonly property real columnWidth: fontSize * 1.25
  readonly property int columnCount: Math.max(1, Math.ceil(width / columnWidth))

  // Per-column fall state: head position in rows (negative counts down to
  // entry above the top edge) and rows advanced per tick, for fall-speed
  // variety across columns.
  property var drops: []
  property var speeds: []
  property bool needsClear: true

  onFontSizeChanged: reset()
  onWidthChanged: reset()
  onHeightChanged: reset()

  function reset() {
    drops = []
    speeds = []
    for (var i = 0; i < columnCount; i++) {
      drops.push(Math.random() * -columnCount)
      speeds.push(0.5 + Math.random() * 0.9)
    }
    needsClear = true
    requestPaint()
  }

  Timer {
    interval: 50
    running: root.visible
    repeat: true
    onTriggered: root.requestPaint()
  }

  onPaint: {
    var ctx = getContext("2d")

    if (needsClear) {
      ctx.fillStyle = "#000000"
      ctx.fillRect(0, 0, width, height)
      needsClear = false
    }

    // The wash fades last tick's heads into trails.
    ctx.fillStyle = "rgba(0, 0, 0, 0.08)"
    ctx.fillRect(0, 0, width, height)

    ctx.font = fontSize + "px monospace"
    ctx.textBaseline = "top"

    for (var i = 0; i < columnCount; i++) {
      var row = drops[i]
      if (row < 0) {
        // Still above the top edge; fall silently so columns enter staggered.
        drops[i] = row + speeds[i]
        continue
      }

      var x = i * columnWidth
      ctx.fillStyle = Math.random() < 0.07 ? "#d6ffd6" : "#00ff41"
      ctx.fillText(glyphs.charAt(Math.floor(Math.random() * glyphs.length)), x, row * fontSize)

      row += speeds[i]
      if (row * fontSize > height && Math.random() > 0.975) row = Math.random() * -24
      drops[i] = row
    }
  }
}
