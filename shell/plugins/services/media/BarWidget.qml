import QtQuick
import Quickshell
import Quickshell.Io
import qs.Ui
import qs.Commons

BarWidget {
  id: root
  moduleName: "r2-d2.media"

  readonly property var mediaService: bar?.shell?.firstPartyServiceFor("r2-d2.media")
  readonly property var activePlayer: mediaService ? mediaService.activePlayer : null
  readonly property bool hasMedia: activePlayer !== null && (activePlayer.trackTitle || activePlayer.trackArtist)
  readonly property string title: activePlayer ? (activePlayer.trackTitle || "") : ""
  readonly property string artist: activePlayer ? (activePlayer.trackArtist || "") : ""
  readonly property string artUrl: activePlayer && activePlayer.trackArtUrl ? activePlayer.trackArtUrl : ""
  readonly property bool shuffleOn: activePlayer ? activePlayer.shuffle === true : false
  readonly property color ink: bar ? bar.barForeground : Color.foreground
  readonly property bool brookPlayer: {
    var player = activePlayer
    if (!player) return false
    var identity = String(player.identity || "").toLowerCase()
    var entry = String(player.desktopEntry || "").toLowerCase()
    return identity === "brook" || entry === "brook" || entry === "dev.skyguy.brook"
  }
  property bool cardOpen: false
  property bool popoutSwitchClosing: false
  property bool pickerOpen: false
  property var results: []
  property string searchError: ""
  property bool searchQueued: false
  property bool searchSettled: false
  property real playbackRatio: 0
  property string progressTrack: ""
  property bool progressHeld: false
  property real progressHeldElapsed: 0
  property double progressHeldAt: 0
  property real progressLastReported: 0
  readonly property int artBasisWidth: Style.space(280)
  readonly property int artBasisCover: Style.space(64)
  readonly property real artScale: artBasisWidth > 0 ? titleSlot.width / artBasisWidth : 1
  readonly property int artCoverSide: Math.max(artBasisCover, card.contentHeight - card.verticalContentInset)

  function refreshProgress() {
    var player = activePlayer
    var key = title + "\n" + artist
    var now = Date.now()
    if (key !== progressTrack) {
      var hadTrack = progressTrack !== ""
      progressTrack = key
      progressLastReported = player ? player.position : 0
      progressHeld = hadTrack && progressLastReported > 1.5
      progressHeldElapsed = 0
      progressHeldAt = now
      playbackRatio = 0
      if (progressHeld) return
    }
    if (!player || !(player.length > 0)) {
      playbackRatio = 0
      progressHeldAt = now
      return
    }
    var reported = player.position
    if (progressHeld) {
      var jumpedBack = progressLastReported > 2 && reported + 1 < progressLastReported
      if (jumpedBack || reported < 1.5) {
        progressHeld = false
      } else {
        if (player.isPlaying) progressHeldElapsed += Math.max(0, (now - progressHeldAt) / 1000)
        progressHeldAt = now
        progressLastReported = reported
        playbackRatio = Math.max(0, Math.min(1, progressHeldElapsed / player.length))
        return
      }
    }
    progressLastReported = reported
    playbackRatio = Math.max(0, Math.min(1, reported / player.length))
  }

  function close() {
    cardOpen = false
    pickerOpen = false
  }

  function openPicker() {
    if (!brookPlayer) return
    cardOpen = false
    results = []
    searchError = ""
    searchSettled = false
    pickerOpen = true
    searchField.text = ""
    searchFocus.restart()
    scheduleSearch()
  }

  function scheduleSearch() {
    searchDebounce.restart()
  }

  function runSearch() {
    if (!pickerOpen) return
    if (searchProc.running) {
      searchQueued = true
      return
    }
    searchError = ""
    searchProc.command = ["brook", "--search", searchField.text]
    searchProc.running = true
  }

  function applySearch(raw) {
    if (!pickerOpen) return
    searchSettled = true
    var parsed
    try {
      parsed = JSON.parse(String(raw || ""))
    } catch (e) {
      results = []
      searchError = "Couldn't search the library"
      return
    }
    searchError = ""
    var rows = []
    var playlists = parsed.playlists || []
    var tracks = parsed.tracks || []
    if (playlists.length) {
      rows.push({ kind: "header", label: "Playlists" })
      for (var i = 0; i < playlists.length; i++) {
        rows.push({ kind: "playlist", id: playlists[i].id, label: playlists[i].name || "Playlist", detail: "" })
      }
    }
    if (tracks.length) {
      rows.push({ kind: "header", label: "Tracks" })
      for (var j = 0; j < tracks.length; j++) {
        var track = tracks[j]
        var detail = track.artist || ""
        if (track.album) detail = detail ? detail + "  ·  " + track.album : track.album
        rows.push({ kind: "track", id: track.id, label: track.title || track.id, detail: detail })
      }
    }
    results = rows
  }

  function playFirst() {
    for (var i = 0; i < results.length; i++) {
      if (results[i].kind === "playlist" || results[i].kind === "track") {
        playRow(results[i])
        return
      }
    }
  }

  function playRow(row) {
    if (!row || (row.kind !== "playlist" && row.kind !== "track")) return
    var flag = row.kind === "playlist" ? "--play-playlist" : "--play-track"
    Quickshell.execDetached(["brook", "--headless", flag, row.id])
    pickerOpen = false
  }

  visible: hasMedia
  implicitWidth: hasMedia ? row.implicitWidth + Style.space(16) : 0
  implicitHeight: barSize

  onHasMediaChanged: if (!hasMedia) close()
  onActivePlayerChanged: refreshProgress()
  onTitleChanged: refreshProgress()
  onArtistChanged: refreshProgress()

  Timer {
    interval: 500
    repeat: true
    running: root.hasMedia
    onTriggered: root.refreshProgress()
  }

  Rectangle {
    anchors.fill: parent
    radius: Math.min(height / 2, Style.cornerRadius)
    color: Qt.rgba(root.ink.r, root.ink.g, root.ink.b, 0.1)
  }

  Rectangle {
    anchors.left: parent.left
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    width: parent.width * root.playbackRatio
    radius: Math.min(height / 2, Style.cornerRadius)
    color: Qt.rgba(root.ink.r, root.ink.g, root.ink.b, 0.28)
  }

  Row {
    id: row
    anchors.left: parent.left
    anchors.leftMargin: Style.space(8)
    anchors.verticalCenter: parent.verticalCenter
    spacing: Style.space(6)
    z: 1

    WidgetButton {
      bar: root.bar
      text: "󰒮"
      fontSize: Style.font.display
      horizontalMargin: 6
      tooltipText: ""
      dimmed: !root.activePlayer || !root.activePlayer.canGoPrevious
      interactive: root.activePlayer && root.activePlayer.canGoPrevious
      onPressed: if (root.mediaService) root.mediaService.runAction("previous", false)
    }

    WidgetButton {
      bar: root.bar
      text: root.activePlayer && root.activePlayer.isPlaying ? "󰏤" : "󰐊"
      fontSize: Style.font.display
      horizontalMargin: 6
      tooltipText: ""
      onPressed: if (root.mediaService) root.mediaService.runAction("playPause", false)
    }

    WidgetButton {
      bar: root.bar
      text: "󰒭"
      fontSize: Style.font.display
      horizontalMargin: 6
      tooltipText: ""
      dimmed: !root.activePlayer || !root.activePlayer.canGoNext
      interactive: root.activePlayer && root.activePlayer.canGoNext
      onPressed: if (root.mediaService) root.mediaService.runAction("next", false)
    }

    WidgetButton {
      bar: root.bar
      text: "󰒝"
      fontSize: Style.font.display
      horizontalMargin: 6
      tooltipText: ""
      active: root.shuffleOn
      dimmed: !root.activePlayer || !root.activePlayer.shuffleSupported
      interactive: root.activePlayer && root.activePlayer.shuffleSupported
      onPressed: {
        var player = root.activePlayer
        if (player && player.shuffleSupported) player.shuffle = !player.shuffle
      }
    }

    Item {
      id: titleSlot
      anchors.verticalCenter: parent.verticalCenter
      width: Style.space(360)
      implicitWidth: width
      height: root.barSize
      clip: true

      readonly property string label: root.title + (root.artist ? "  ·  " + root.artist : "")
      readonly property real gap: Style.space(48)
      readonly property bool overflows: titleLabel.implicitWidth > width + 1
      readonly property real cycle: titleLabel.implicitWidth + gap
      property real marqueeOffset: 0
      property bool marqueeReady: false

      function armMarquee() {
        marqueeScroll.stop()
        marqueeHold.stop()
        marqueeOffset = 0
        if (overflows)
          marqueeHold.start()
      }

      function startScroll() {
        if (!overflows) return
        marqueeScroll.from = 0
        marqueeScroll.to = -cycle
        marqueeScroll.duration = Math.max(2500, Math.round(cycle / 40 * 1000))
        marqueeScroll.start()
      }

      onLabelChanged: if (marqueeReady) Qt.callLater(function() { armMarquee() })
      onOverflowsChanged: if (marqueeReady) armMarquee()
      Component.onCompleted: {
        marqueeReady = true
        armMarquee()
      }

      Text {
        id: titleLabel
        x: titleSlot.overflows ? titleSlot.marqueeOffset : 0
        anchors.verticalCenter: parent.verticalCenter
        textFormat: Text.PlainText
        text: titleSlot.label
        color: root.ink
        font.family: root.bar ? root.bar.fontFamily : Style.font.family
        font.pixelSize: Style.font.body
      }

      Text {
        visible: titleSlot.overflows
        x: titleLabel.x + titleSlot.cycle
        anchors.verticalCenter: parent.verticalCenter
        textFormat: Text.PlainText
        text: titleSlot.label
        color: root.ink
        font.family: root.bar ? root.bar.fontFamily : Style.font.family
        font.pixelSize: Style.font.body
      }

      MouseArea {
        id: titleHover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.brookPlayer ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: if (root.brookPlayer) root.openPicker()
        onContainsMouseChanged: {
          if (root.pickerOpen) {
            root.cardOpen = false
            return
          }
          if (containsMouse) {
            cardClose.stop()
            root.cardOpen = root.hasMedia
          } else {
            cardClose.restart()
          }
        }
      }

      Timer {
        id: marqueeHold
        interval: 3000
        onTriggered: titleSlot.startScroll()
      }

      NumberAnimation {
        id: marqueeScroll
        target: titleSlot
        property: "marqueeOffset"
        easing.type: Easing.Linear
        onFinished: {
          titleSlot.marqueeOffset = 0
          if (titleSlot.overflows)
            marqueeHold.start()
        }
      }
    }
  }

  Timer {
    id: cardClose
    interval: 160
    onTriggered: if (!card.containsMouse) root.cardOpen = false
  }

  PopupCard {
    id: card
    anchorItem: titleSlot
    bar: root.bar
    owner: root
    triggerMode: "hover"
    open: root.cardOpen && root.hasMedia
    contentWidth: card.fittedContentWidth(titleSlot.width)
    contentHeight: {
      var scaled = Math.round(card.fittedContentHeight(root.artBasisCover) * root.artScale)
      var cap = card.availableCardHeight > 0 ? card.availableCardHeight : scaled
      return Math.round(Math.min(scaled, cap))
    }

    onContainsMouseChanged: {
      if (root.pickerOpen) return
      if (containsMouse) {
        cardClose.stop()
        root.cardOpen = true
      } else if (!titleHover.containsMouse) {
        cardClose.restart()
      }
    }

    Row {
      id: cardRow
      anchors.fill: parent
      spacing: Style.space(10)

      BorderSurface {
        id: artCover
        width: root.artCoverSide
        height: root.artCoverSide
        radius: Style.spacing.labelGap
        color: Style.normalFillFor(root.bar ? root.bar.foreground : Color.foreground, Color.accent)
        borderSpec: Border.controlSpec("normal", root.bar ? root.bar.foreground : Color.foreground, Color.accent)

        Image {
          anchors.fill: parent
          anchors.margins: Style.space(2)
          fillMode: Image.PreserveAspectCrop
          asynchronous: true
          source: root.artUrl
          visible: root.artUrl !== ""
        }

        Text {
          anchors.centerIn: parent
          visible: root.artUrl === ""
          text: "󰝚"
          color: root.bar ? root.bar.foreground : Color.foreground
          font.family: root.bar ? root.bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.displayLarge
        }
      }

      Column {
        width: Math.max(0, parent.width - artCover.width - parent.spacing)
        spacing: Style.space(4)
        anchors.verticalCenter: parent.verticalCenter

        Text {
          textFormat: Text.PlainText
          text: root.title || "Nothing playing"
          color: root.bar ? root.bar.foreground : Color.foreground
          font.family: root.bar ? root.bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.subtitle
          font.bold: true
          elide: Text.ElideRight
          width: parent.width
        }

        Text {
          textFormat: Text.PlainText
          text: root.artist
          color: Qt.darker(root.bar ? root.bar.foreground : Color.foreground, 1.3)
          font.family: root.bar ? root.bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.bodySmall
          elide: Text.ElideRight
          width: parent.width
          visible: text !== ""
        }
      }
    }
  }

  Timer {
    id: searchFocus
    interval: 80
    onTriggered: if (root.pickerOpen) searchField.forceActiveFocus()
  }

  Timer {
    id: searchDebounce
    interval: 150
    onTriggered: root.runSearch()
  }

  Process {
    id: searchProc
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        root.applySearch(text)
        if (root.searchQueued) {
          root.searchQueued = false
          root.runSearch()
        }
      }
    }
  }

  KeyboardPanel {
    id: picker
    anchorItem: root
    bar: root.bar
    owner: root
    focusTarget: searchField
    open: root.pickerOpen && root.hasMedia
    padding: Style.space(8)
    contentWidth: picker.fittedContentWidth(Style.space(360))
    contentHeight: picker.fittedContentHeight(pickerCol.implicitHeight, Style.space(420))

    Column {
      id: pickerCol
      width: parent.width
      spacing: Style.space(6)

      TextField {
        id: searchField
        width: parent.width
        foreground: root.ink
        accent: Color.accent
        placeholderText: "Playlist or track"
        font.family: root.bar ? root.bar.fontFamily : Style.font.family
        verticalPadding: Style.space(4)
        onTextChanged: if (root.pickerOpen) root.scheduleSearch()
        Keys.onReturnPressed: root.playFirst()
        Keys.onEscapePressed: root.pickerOpen = false
      }

      Text {
        textFormat: Text.PlainText
        width: parent.width
        visible: root.searchError !== "" || (root.searchSettled && root.results.length === 0)
        text: root.searchError !== "" ? root.searchError : (searchField.text !== "" ? "Nothing matches" : "No playlists")
        color: Qt.darker(root.ink, 1.3)
        font.family: root.bar ? root.bar.fontFamily : Style.font.family
        font.pixelSize: Style.font.bodySmall
        wrapMode: Text.WordWrap
      }

      Repeater {
        model: root.results

        delegate: Item {
          required property var modelData
          width: pickerCol.width
          implicitHeight: modelData.kind === "header" ? headerLabel.implicitHeight : rowLabel.implicitHeight + Style.space(8)

          Text {
            id: headerLabel
            visible: modelData.kind === "header"
            text: modelData.label || ""
            color: Qt.darker(root.ink, 1.4)
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
            font.pixelSize: Style.font.bodySmall
          }

          Rectangle {
            visible: modelData.kind !== "header"
            anchors.fill: parent
            radius: Style.cornerRadius
            color: rowMouse.containsMouse ? Qt.rgba(root.ink.r, root.ink.g, root.ink.b, 0.12) : "transparent"

            Column {
              id: rowLabel
              anchors.left: parent.left
              anchors.right: parent.right
              anchors.verticalCenter: parent.verticalCenter
              anchors.leftMargin: Style.space(6)
              anchors.rightMargin: Style.space(6)

              Text {
                textFormat: Text.PlainText
                width: parent.width
                text: modelData.label || ""
                color: root.ink
                font.family: root.bar ? root.bar.fontFamily : Style.font.family
                font.pixelSize: Style.font.body
                elide: Text.ElideRight
              }

              Text {
                textFormat: Text.PlainText
                width: parent.width
                visible: (modelData.detail || "") !== ""
                text: modelData.detail || ""
                color: Qt.darker(root.ink, 1.3)
                font.family: root.bar ? root.bar.fontFamily : Style.font.family
                font.pixelSize: Style.font.bodySmall
                elide: Text.ElideRight
              }
            }

            MouseArea {
              id: rowMouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: root.playRow(modelData)
            }
          }
        }
      }
    }
  }
}
