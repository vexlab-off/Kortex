import QtQuick
import Quickshell
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "omarchy.menu"

  implicitWidth: Style.space(32)
  implicitHeight: root.barSize

  Item {
    id: button
    anchors.fill: parent

    Rectangle {
      id: hoverBg
      anchors.fill: parent
      anchors.margins: Style.space(2)
      radius: Style.cornerRadius
      color: mouseArea.containsMouse ? (root.bar ? Qt.rgba(root.bar.barForeground.r, root.bar.barForeground.g, root.bar.barForeground.b, 0.14) : Qt.rgba(1, 1, 1, 0.14)) : "transparent"
      Behavior on color { ColorAnimation { duration: 120 } }
    }

    Image {
      id: iconImage
      anchors.centerIn: parent
      width: Style.space(20)
      height: Style.space(20)
      fillMode: Image.PreserveAspectFit
      smooth: true
      mipmap: true
      sourceSize.width: 64
      sourceSize.height: 64
      source: "../../branding/kortex-symbolic.png"
    }

    MouseArea {
      id: mouseArea
      anchors.fill: parent
      hoverEnabled: true
      acceptedButtons: Qt.LeftButton | Qt.RightButton
      cursorShape: Qt.PointingHandCursor
      onClicked: function(mouse) {
        if (!root.bar) return
        if (mouse.button === Qt.RightButton) root.bar.run("xdg-terminal-exec")
        else root.bar.run("omarchy-shell shell toggle omarchy.menu '{\"menu\":\"root\"}'")
      }
    }
  }
}
