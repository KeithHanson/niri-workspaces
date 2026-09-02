import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import qs.Commons
import qs.Ui

Item {
  id: root

  property var manifest: null
  readonly property string pluginDir: manifest && manifest.__sourceDir ? String(manifest.__sourceDir) : ""
  readonly property string overviewDir: pluginDir + "/overview"
  readonly property string hotCornerScript: pluginDir + "/scripts/niri-workspaces-hot-corner"

  function workspaceById(id) {
    var values = Hyprland.workspaces.values
    for (var i = 0; i < values.length; i++) {
      if (values[i].id === id) return values[i]
    }
    return null
  }

  function workspaceIds() {
    var ids = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    var values = Hyprland.workspaces.values

    for (var i = 0; i < values.length; i++) {
      var id = values[i].id
      if (id > 0 && ids.indexOf(id) === -1) ids.push(id)
    }

    ids.sort(function(left, right) { return left - right })
    return ids
  }

  function focusWorkspace(id) {
    Util.execDetached("hyprctl dispatch " + Util.shellQuote("hl.dsp.focus({ workspace = \"" + id + "\" })"))
  }

  function overviewShell(action) {
    if (!overviewDir || overviewDir === "/overview") return ""
    var dir = Util.shellQuote(overviewDir)
    return "pgrep -af " + Util.shellQuote("^qs .* -p " + overviewDir + "|^qs -p " + overviewDir) + " >/dev/null || qs -d -p " + dir + "; qs ipc -p " + dir + " call overview " + action
  }

  function openOverview() {
    if (hotCornerCooldown.running) return
    hotCornerCooldown.restart()
    var command = overviewShell("open")
    if (command) Util.execDetached("sh -lc " + Util.shellQuote(command))
  }

  function toggleOverview() {
    var command = overviewShell("toggle")
    if (command) Util.execDetached("sh -lc " + Util.shellQuote(command))
  }

  function startHotCornerDaemon() {
    if (!pluginDir || pluginDir === "" || !hotCornerScript) return
    var command = "pkill -f " + Util.shellQuote(hotCornerScript) + " 2>/dev/null || true; " + Util.shellQuote(hotCornerScript) + " " + Util.shellQuote(overviewDir) + " >/tmp/niri-workspaces-hot-corner.log 2>&1 &"
    Util.execDetached("sh -lc " + Util.shellQuote(command))
  }

  Timer {
    id: hotCornerCooldown
    interval: 900
    repeat: false
  }

  readonly property int dotCount: root.workspaceIds().length
  readonly property int dotPanelWidth: 36
  readonly property int dotPanelHeight: root.dotCount * 18 + Math.max(0, root.dotCount - 1) * 10 + 72

  IpcHandler {
    target: "niri-workspaces"

    function openOverview(): void { root.openOverview() }
    function toggleOverview(): void { root.toggleOverview() }
  }

  Component.onCompleted: root.startHotCornerDaemon()

  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: panel
      required property var modelData

      screen: modelData
      visible: true
      color: "transparent"
      implicitWidth: 54
      exclusionMode: ExclusionMode.Ignore

      anchors {
        top: true
        bottom: true
        left: true
      }

      WlrLayershell.namespace: "niri-workspaces-dots"
      WlrLayershell.layer: WlrLayer.Top
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

      Item {
        id: dotPanel
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: root.dotPanelWidth
        height: root.dotPanelHeight

        Canvas {
          id: panelCanvas
          z: 0
          anchors.fill: parent
          opacity: 0.96

          onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.clearRect(0, 0, width, height)
            ctx.beginPath()
            // Slanted top/bottom edges run all the way back to the screen edge.
            var slant = 28
            ctx.moveTo(0, 0)
            ctx.lineTo(width, slant)
            ctx.lineTo(width, height - slant)
            ctx.lineTo(0, height)
            ctx.closePath()
            ctx.fillStyle = "#01080f"
            ctx.fill()
            ctx.lineWidth = 1
            ctx.strokeStyle = "#468aba"
            ctx.stroke()
          }

          onWidthChanged: requestPaint()
          onHeightChanged: requestPaint()
          Component.onCompleted: requestPaint()
        }

        ColumnLayout {
          id: dots
          z: 1
          anchors.centerIn: parent
          spacing: 10

          Repeater {
            model: root.workspaceIds()

            Item {
              required property int modelData

              readonly property var workspace: root.workspaceById(modelData)
              readonly property bool occupied: workspace !== null && workspace.toplevels.values.length > 0
              readonly property bool focused: Hyprland.focusedWorkspace !== null && Hyprland.focusedWorkspace.id === modelData
              readonly property int dotSize: focused ? 12 : 7

              Layout.alignment: Qt.AlignHCenter
              implicitWidth: 18
              implicitHeight: 18

              Rectangle {
                anchors.centerIn: parent
                width: parent.dotSize
                height: parent.dotSize
                radius: width / 2
                color: parent.focused ? Color.bar.active : Color.bar.text
                opacity: parent.focused ? 1.0 : (parent.occupied ? 0.7 : 0.35)

                Behavior on width { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
                Behavior on height { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
                Behavior on opacity { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
              }

              MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton
                onClicked: root.focusWorkspace(parent.modelData)
              }
            }
          }
        }
      }
    }
  }

  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: hotCorner
      required property var modelData

      screen: modelData
      visible: true
      color: "transparent"
      implicitWidth: 24
      implicitHeight: 24
      exclusionMode: ExclusionMode.Ignore

      anchors {
        top: true
        left: true
      }

      WlrLayershell.namespace: "niri-workspaces-hot-corner"
      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

      // Invisible input target in the absolute top-left corner.
      // Keep this on the overlay layer so the top bar cannot steal the hover.
      Rectangle {
        anchors.fill: parent
        color: "transparent"

        MouseArea {
          anchors.fill: parent
          hoverEnabled: true
          acceptedButtons: Qt.NoButton
          onEntered: root.openOverview()
        }
      }
    }
  }
}
