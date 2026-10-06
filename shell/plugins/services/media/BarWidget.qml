import QtQuick
import Quickshell.Services.Mpris
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
  readonly property bool repeatOn: activePlayer && activePlayer.loopState !== MprisLoopState.None
  readonly property string repeatIcon: activePlayer && activePlayer.loopState === MprisLoopState.Track ? "󰑘" : "󰑖"
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

  function cycleRepeat() {
    var player = activePlayer
    if (!player || !player.loopSupported) return
    if (player.loopState === MprisLoopState.None) player.loopState = MprisLoopState.Playlist
    else if (player.loopState === MprisLoopState.Playlist) player.loopState = MprisLoopState.Track
    else player.loopState = MprisLoopState.None
  }

  visible: hasMedia
  implicitWidth: hasMedia ? row.implicitWidth : 0
  implicitHeight: barSize

  onHasMediaChanged: if (!hasMedia) cardOpen = false
  onActivePlayerChanged: refreshProgress()

  Timer {
    interval: 500
    repeat: true
    running: root.hasMedia
    onTriggered: root.refreshProgress()
  }

  Row {
    id: row
    anchors.verticalCenter: parent.verticalCenter
    spacing: Style.space(2)

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
      text: "󰒮"
      horizontalMargin: 4
      tooltipText: ""
      dimmed: !root.activePlayer || !root.activePlayer.canGoPrevious
      interactive: root.activePlayer && root.activePlayer.canGoPrevious
      onPressed: if (root.mediaService) root.mediaService.runAction("previous", false)
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

    WidgetButton {
      bar: root.bar
      text: root.repeatIcon
      horizontalMargin: 4
      tooltipText: ""
      active: root.repeatOn
      dimmed: !root.activePlayer || !root.activePlayer.loopSupported
      interactive: root.activePlayer && root.activePlayer.loopSupported
      onPressed: root.cycleRepeat()
    }

    Text {
      textFormat: Text.PlainText
      anchors.verticalCenter: parent.verticalCenter
      text: root.title + (root.artist ? "  ·  " + root.artist : "")
      color: root.bar ? root.bar.barForeground : Color.foreground
      font.family: root.bar ? root.bar.fontFamily : Style.font.family
      font.pixelSize: Style.font.body
      elide: Text.ElideRight
      width: Math.min(implicitWidth, Style.space(160))
    }

    Item {
      width: Style.space(72)
      height: parent.height

      Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: Style.space(3)
        radius: height / 2
        color: root.bar ? Qt.rgba(root.bar.barForeground.r, root.bar.barForeground.g, root.bar.barForeground.b, 0.28) : Color.foreground

        Rectangle {
          width: parent.width * root.playbackRatio
          height: parent.height
          radius: parent.radius
          color: root.bar ? root.bar.barForeground : Color.foreground
        }
      }
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
