import QtQuick 2.4
import QtQuick.Controls 1.4
import QtMultimedia 5.4

Image {
    id: dragPoint

    property alias size: dragPoint.width
    property alias color: fillingRect.color
    signal drag( int x, int y )
    signal dragCheck()
    signal dragStoped()
    property string label: ""
    property alias _labelColor: labelDebug.color
    property bool debug: false
    property bool dragEnabled: true
    clip: false

    source: "qrc:/images/shadow_circle.png"
    width: 50
    height: width

    property bool limitMovementsEnabled: false
    property int limitMovements: -1
    property int currentMovements: 0
    property alias colorText: labelDrag.color

    Rectangle {
        id: fillingRect
        width: parent.width*0.8
        height: width
        radius: width/2
        anchors.centerIn: parent
        color: dragPoint.limitMovementsEnabled ? (dragPoint.currentMovements < dragPoint.limitMovements ? "#00b300" : "red") : "#00b300"
    }

    property int countDrag: 0
    onCountDragChanged: {
        if( !(countDrag % 10) ) {
            //console.log(""+countDrag+" signal")
            dragPoint.dragCheck()
        }// else console.log(""+countDrag)
    }

    Label {
        id: labelDebug
        visible: dragPoint.debug
        anchors.centerIn: parent
        font.pixelSize: 8
        text: label + " " + (dragPoint.x+dragPoint.size/2)+";"+(dragPoint.y+dragPoint.size/2)
        color: "blue"
    }

    Label {
        id: labelDrag
        anchors.centerIn: parent
        font.pixelSize: parent.height*0.4
        text: (dragPoint.limitMovements - dragPoint.currentMovements)
        color: "blue"
        visible: dragPoint.limitMovementsEnabled
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        drag.target: dragPoint
        drag.axis: Drag.XAndYAxis
        drag.minimumX: 0
        drag.minimumY: 0
        drag.maximumX: dragPoint.parent.width - dragPoint.width
        drag.maximumY: dragPoint.parent.height - dragPoint.height
        onMouseXChanged: {
            countDrag += 1
            dragPoint.drag( mouseX, mouseY )
        }
        onPressed: {
            dragPoint.scale = 1.3
            if( settings.soundOn && (snd_press.status != Audio.PlayingState) && (!dragPoint.limitMovementsEnabled) ) {
                snd_press.play()
            } else if(settings.soundOn && (snd_press.status != Audio.PlayingState) && (dragPoint.limitMovementsEnabled) && (dragPoint.currentMovements < dragPoint.limitMovements)) {
                snd_press.play()
            }
        }
        onReleased: {
            if( countDrag > 0 ) {
                dragPoint.currentMovements += 1
            }
            dragPoint.scale = 1.0
            dragPoint.dragStoped()
            countDrag = 0
            if( settings.soundOn && (snd_release.status != Audio.PlayingState) && (!dragPoint.limitMovementsEnabled) ) {
                snd_release.play()
            } else if( settings.soundOn && (snd_release.status != Audio.PlayingState) && (dragPoint.limitMovementsEnabled) && (dragPoint.currentMovements <= dragPoint.limitMovements) ) {
                snd_release.play()
            }
        }
        enabled: dragPoint.limitMovementsEnabled ? (dragPoint.currentMovements < dragPoint.limitMovements)&&dragPoint.dragEnabled : dragPoint.dragEnabled
    }
    MouseArea {
        anchors.fill: parent
        enabled: !ma.enabled
        onPressed: {
            if(settings.soundOn && (snd_forbidden.status != Audio.PlayingState) && (dragPoint.limitMovementsEnabled) && (dragPoint.currentMovements >= dragPoint.limitMovements)) {
                snd_forbidden.play()
            }
        }
    }

    Behavior on scale { NumberAnimation { duration: 100 } }

    /*SoundEffect {
        id: snd
        source: "assets:/sounds/drag_point.wav"
    }*/

    Audio {
        id: snd_press
        volume: settings.soundVolume
        source: "assets:/sounds/drag_point_press.mp3"
    }

    Audio {
        id: snd_release
        volume: settings.soundVolume
        source: "assets:/sounds/drag_point_release.mp3"
    }

    Audio {
        id: snd_forbidden
        volume: settings.soundVolume
        source: "assets:/sounds/access_denied.mp3"
    }
}
