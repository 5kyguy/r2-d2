import QtQuick
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
  property bool cardOpen: false
  property real playbackRatio: 0

  function refreshProgress() {
    var player = activePlayer
    if (!player || !player.length || player.length <= 0) {
      playbackRatio = 0
      return
    }
    var ratio = player.position / player.length
    playbackRatio = Math.max(0, Math.min(1, ratio))
  }

  function close() { cardOpen = false }

  visible: hasMedia
  implicitWidth: hasMedia ? row.implicitWidth + Style.space(16) : 0
  implicitHeight: barSize

  onHasMediaChanged: if (!hasMedia) cardOpen = false
  onActivePlayerChanged: refreshProgress()

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
    spacing: Style.space(2)
    z: 1

    WidgetButton {
      bar: root.bar
      text: "󰒮"
      horizontalMargin: 4
      tooltipText: ""
      dimmed: !root.activePlayer || !root.activePlayer.canGoPrevious
      interactive: root.activePlayer && root.activePlayer.canGoPrevious
      onPressed: if (root.mediaService) root.mediaService.runAction("previous", false)
    }

    WidgetButton {
      bar: root.bar
      text: root.activePlayer && root.activePlayer.isPlaying ? "󰏤" : "󰐊"
      horizontalMargin: 4
      tooltipText: ""
      onPressed: if (root.mediaService) root.mediaService.runAction("playPause", false)
    }

    WidgetButton {
      bar: root.bar
      text: "󰒭"
      horizontalMargin: 4
      tooltipText: ""
      dimmed: !root.activePlayer || !root.activePlayer.canGoNext
      interactive: root.activePlayer && root.activePlayer.canGoNext
      onPressed: if (root.mediaService) root.mediaService.runAction("next", false)
    }

    WidgetButton {
      bar: root.bar
      text: "󰒝"
      horizontalMargin: 4
      tooltipText: ""
      active: root.shuffleOn
      dimmed: !root.activePlayer || !root.activePlayer.shuffleSupported
      interactive: root.activePlayer && root.activePlayer.shuffleSupported
      onPressed: {
        var player = root.activePlayer
        if (player && player.shuffleSupported) player.shuffle = !player.shuffle
      }
    }

    Text {
      textFormat: Text.PlainText
      anchors.verticalCenter: parent.verticalCenter
      text: root.title + (root.artist ? "  ·  " + root.artist : "")
      color: root.ink
      font.family: root.bar ? root.bar.fontFamily : Style.font.family
      font.pixelSize: Style.font.body
      elide: Text.ElideRight
      width: Style.space(360)
    }
  }

  HoverHandler {
    id: islandHover
    onHoveredChanged: {
      if (hovered) {
        cardClose.stop()
        root.cardOpen = root.hasMedia
      } else {
        cardClose.restart()
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
    anchorItem: root
    bar: root.bar
    owner: root
    triggerMode: "hover"
    open: root.cardOpen && root.hasMedia
    contentWidth: card.fittedContentWidth(Style.space(280))
    contentHeight: card.fittedContentHeight(cardRow.implicitHeight)

    onContainsMouseChanged: {
      if (containsMouse) {
        cardClose.stop()
        root.cardOpen = true
      } else if (!islandHover.hovered) {
        cardClose.restart()
      }
    }

    Row {
      id: cardRow
      anchors.fill: parent
      spacing: Style.space(10)

      BorderSurface {
        width: Style.space(64)
        height: Style.space(64)
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
        width: parent.width - Style.space(74)
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
}
