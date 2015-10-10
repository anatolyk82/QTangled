import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import QtMultimedia 5.4


Item {
    id: root
    anchors.fill: parent
    clip: true
    z: 10

    signal okClicked()
    signal replayClicked()

    property int sizButton: 70*app.dp

    property string time: "00:00.0"
    property int time_ms: 0
    property int level: 0
    property int gameType: 0

    property int dots: 0 //new - for a level icon

    property string bestTime: ""


    function open() { root.state = "visible" }
    function close() { root.state = "hidden" }

    //------------------------

    Rectangle {
        id: background
        anchors.centerIn: parent
        width: height
        radius: width/2
        color: "white"
        //opacity: 0.95
        border.color: "gray"
    }

    state: "hidden"
    states: [
        State {
            name: "visible"
            PropertyChanges { target: background; height: Math.sqrt( root.height*root.height + root.width*root.width ) }
            PropertyChanges { target: imgFrameImgLevel; anchors.verticalCenterOffset: -root.sizButton*1.2 }
            PropertyChanges { target: labelGameLevel; anchors.topMargin: 20*app.dp }
            PropertyChanges { target: rowLabelsTime; anchors.topMargin: 20*app.dp }
        },
        State {
            name: "hidden"
            PropertyChanges { target: root; height: 0 }
            PropertyChanges { target: imgFrameImgLevel; anchors.verticalCenterOffset: root.height/2+imgFrameImgLevel.height }
            PropertyChanges { target: labelGameLevel; anchors.topMargin: root.height/2+imgFrameImgLevel.height }
            PropertyChanges { target: rowLabelsTime; anchors.topMargin: root.height/2+imgFrameImgLevel.height }
        }
    ]
    transitions: [
        Transition {
            from: "hidden"; to: "visible"
            SequentialAnimation {
                NumberAnimation { target: background; properties: "height"; duration: 400 }
                ParallelAnimation {
                    NumberAnimation { target: imgFrameImgLevel; properties: "anchors.verticalCenterOffset"; duration: 250; easing.type: Easing.OutQuart }
                    SequentialAnimation {
                        PauseAnimation { duration: 150 }
                        NumberAnimation { target: labelGameLevel; properties: "anchors.topMargin"; duration: 200; easing.type: Easing.OutQuart }
                    }
                    SequentialAnimation {
                        PauseAnimation { duration: 250 }
                        NumberAnimation { target: rowLabelsTime; properties: "anchors.topMargin"; duration: 200; easing.type: Easing.OutQuart }
                    }
                    SequentialAnimation {
                        PauseAnimation { duration: 400 }
                        ScriptAction { script: btnMenu.state = "visible" }
                    }
                }
            }
        },
        Transition {
            from: "visible"; to: "hidden"
            SequentialAnimation {
                ParallelAnimation {
                    NumberAnimation { target: imgFrameImgLevel; properties: "anchors.verticalCenterOffset"; duration: 300; easing.type: Easing.InQuart }
                    SequentialAnimation {
                        PauseAnimation { duration: 100 }
                        NumberAnimation { target: labelGameLevel; properties: "anchors.topMargin"; duration: 300; easing.type: Easing.InQuart }
                    }
                    SequentialAnimation {
                        PauseAnimation { duration: 200 }
                        NumberAnimation { target: rowLabelsTime; properties: "anchors.topMargin"; duration: 300; easing.type: Easing.InQuart }
                    }
                    SequentialAnimation {
                        PauseAnimation { duration: 400 }
                        ScriptAction { script: btnMenu.state = "hidden" }
                    }
                }
                NumberAnimation { target: background; properties: "height"; duration: 400 }
            }
        }
    ]

    //====================== content


    Image {
        id: imgFrameImgLevel
        source: "qrc:/images/shadow_circle.png"
        width: root.sizButton*1.6
        height: width
        anchors.centerIn: parent
        Image {
            id: imgLevel
            anchors.centerIn: parent
            height: parent.height*0.7
            width: height
            smooth: true
            source: "qrc:/images/dots"+dots+".png"
        }
    }
    Label {
        id: labelGameLevel
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: imgFrameImgLevel.bottom
        text: qsTr("LEVEL") + " " + root.level
        font.pixelSize: 30*app.dp
        color: palette.darkPrimary
    }

    Row {
        id: rowLabelsTime
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: labelGameLevel.bottom
        //anchors.topMargin: 20*app.dp
        spacing: 5*app.dp
        Image {
            anchors.verticalCenter: parent.verticalCenter
            source: "qrc:/images/icon_cap.png"
            width: height
            height: 22*app.dp
            smooth: true
        }
        Label {
            id: labelBestTime
            anchors.verticalCenter: parent.verticalCenter
            text: bestTime == "" ? root.time : bestTime
            font.pixelSize: 22*app.dp
        }
        Item {
            width: height; height: 30*app.dp
        }
        Image {
            anchors.verticalCenter: parent.verticalCenter
            source: "qrc:/images/icon_time.png"
            width: height
            height: 22*app.dp
            smooth: true
        }
        Label {
            id: labelGameTime
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 22*app.dp
            text: root.time
        }
    }



    //====================== buttons

    Rectangle {
        id: curtain
        color: "white"
        opacity: 0
        anchors.fill: parent
        z: 2
    }
    Binding {
        target: curtain
        property: "opacity"
        value: ((btnOk.anchors.bottomMargin-btnMenu.anchors.bottomMargin)/(btnOk.width + btnOk.width/5))*0.9
        when: root.state == "visible"
    }

    //------------------------

    Image {
        id: btnMenu
        z: 5
        source: "qrc:/images/shadow_circle.png"
        width: root.sizButton
        height: width
        anchors.right: parent.right
        anchors.rightMargin: 20*app.dp
        anchors.bottom: parent.bottom
        ///anchors.bottomMargin: root.state == "visible" ? root.sizButton*0.3 : -2*root.sizButton
        state: "hidden"
        states: [
            State { name: "visible"; PropertyChanges { target: btnMenu; anchors.bottomMargin: root.sizButton*0.3 } },
            State { name: "hidden";  PropertyChanges { target: btnMenu; anchors.bottomMargin: -2*root.sizButton } }
        ]
        Behavior on anchors.bottomMargin {
            SequentialAnimation {
                ///PauseAnimation { duration: 300 }
                NumberAnimation { duration: 450; easing.type: Easing.OutQuart }
            }
        }
        Rectangle {
            id: fillingRectMenu
            width: parent.width*0.8
            height: width
            radius: width/2
            anchors.centerIn: parent
            color: palette.accent
            Image {
                anchors.centerIn: parent
                width: parent.width*0.4
                height: width
                smooth: true
                source: "qrc:/images/icon_add.png"
                rotation: btnOk.state == "open" ? 135 : 0
                Behavior on rotation { NumberAnimation { duration: 300; easing.type: Easing.InOutQuart } }
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if( settings.soundOn ) { snd.play() }
                    btnOk.visible = true
                    btnAgain.visible = true
                    btnOk.state = btnOk.state == "open" ? "close" : "open"
                    btnAgain.state = btnAgain.state == "open" ? "close" : "open"
                }
            }
        }
    }

    //------------------------

    Image {
        id: btnOk
        property bool flButtonPressed: false
        visible: false

        z: 4
        state: "close"
        states: [
            State {
                name: "open"
                PropertyChanges { target: btnOk; anchors.bottomMargin: btnMenu.anchors.bottomMargin + btnOk.width + btnOk.width/5 }
            },
            State {
                name: "close"
                PropertyChanges { target: btnOk; anchors.bottomMargin: btnMenu.anchors.bottomMargin }
            }
        ]
        transitions: [
            Transition {
                SequentialAnimation {
                    NumberAnimation { property: "anchors.bottomMargin"; easing.type: Easing.InOutQuart; duration: 500 }
                    PauseAnimation { duration: 150 }
                    ScriptAction {
                        script: {
                            if(btnOk.flButtonPressed) {
                                btnOk.visible = false
                                btnAgain.visible = false
                                btnOk.flButtonPressed = false
                                root.okClicked()
                                root.close()
                            }
                        }
                    }
                }
            }
        ]
        source: "qrc:/images/shadow_circle.png"
        width: root.sizButton
        height: width
        anchors.right: parent.right
        anchors.rightMargin: 20*app.dp
        anchors.bottom: parent.bottom
        //anchors.bottomMargin: parent.height*0.25 - width/2
        Behavior on anchors.bottomMargin {
            SequentialAnimation {
                PauseAnimation { duration: 200 }
                NumberAnimation { duration: 400; easing.type: Easing.InOutQuart }
            }
        }
        Rectangle {
            id: fillingRectOk
            width: parent.width*0.8
            height: width
            radius: width/2
            anchors.centerIn: parent
            color: palette.accent
            Image {
                anchors.centerIn: parent
                source: "qrc:/images/icon_go_right.png"
                width: parent.width*0.4
                height: width
                smooth: true
            }
            MouseArea {
                anchors.fill: parent
                enabled: btnOk.state == "open"
                onClicked: {
                    if( settings.soundOn ) { snd.play() }
                    btnOk.flButtonPressed = true
                    btnOk.state = "close"
                    btnAgain.state = "close"
                }
            }
        }
    }

    Image  {
        id: btnAgain
        property bool flButtonPressed: false
        z: 3
        state: "close"
        states: [
            State {
                name: "open"
                PropertyChanges { target: btnAgain; anchors.bottomMargin: btnMenu.anchors.bottomMargin + 2*(btnOk.width + btnOk.width/5) /*parent.height*0.25 + btnOk.width + btnAgain.width/2 + 10*app.dp*/ }
            },
            State {
                name: "close"
                PropertyChanges { target: btnAgain; anchors.bottomMargin: btnMenu.anchors.bottomMargin/*parent.height*0.25 - btnAgain.width/2*/ }
            }
        ]
        transitions: [
            Transition {
                SequentialAnimation {
                    NumberAnimation { property: "anchors.bottomMargin"; easing.type: Easing.InOutQuart; duration: 500 }
                    PauseAnimation { duration: 150 }
                    ScriptAction {
                        script: {
                            if(btnAgain.flButtonPressed) {
                                btnOk.visible = false
                                btnAgain.visible = false
                                btnAgain.flButtonPressed = false
                                root.replayClicked()
                                root.close()
                            }
                        }
                    }
                }
            }
        ]
        visible: false
        source: "qrc:/images/shadow_circle.png"
        width: root.sizButton
        height: width
        anchors.right: parent.right
        anchors.rightMargin: 20*app.dp
        anchors.bottom: parent.bottom
        Behavior on anchors.bottomMargin {
            SequentialAnimation {
                PauseAnimation { duration: 200 }
                NumberAnimation { duration: 400; easing.type: Easing.InOutQuart }
            }
        }
        Rectangle {
            id: fillingRectAgain
            width: parent.width*0.8
            height: width
            radius: width/2
            anchors.centerIn: parent
            color: palette.accent
            Image {
                anchors.centerIn: parent
                source: "qrc:/images/icon_replay.png"
                width: parent.width*0.4
                height: width
                smooth: true
            }
            MouseArea {
                anchors.fill: parent
                enabled: btnAgain.state == "open"
                onClicked: {
                    if( settings.soundOn ) { snd.play() }
                    btnAgain.flButtonPressed = true
                    btnOk.state = "close"
                    btnAgain.state = "close"
                }
            }
        }
    }

    //------------------------

    Rectangle {
        id: tipOk
        z:5
        anchors.verticalCenter: btnOk.verticalCenter
        anchors.right: btnOk.left
        anchors.rightMargin: btnOk.width/5
        color: "black"
        radius: 5*app.dp
        width: labelNextLevel.paintedWidth*1.3
        height: btnOk.height*0.4
        opacity: btnOk.state == "open" ? 1 : 0
        Behavior on opacity {
            SequentialAnimation {
                NumberAnimation { duration: 600; easing.type: Easing.InOutQuart }
            }
        }
        Label {
            id: labelNextLevel
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            color: "white"
            text: qsTr("Next level")
            font.pixelSize: parent.height*0.6
        }
        Rectangle {
            z:5
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: tipOk.right
            anchors.leftMargin: -width/2
            height: 0.3*parent.height
            width: height
            opacity: tipOk.opacity
            rotation: 45
            color: "black"
        }
    }
    Rectangle {
        id: tipAgain
        z:5
        anchors.verticalCenter: btnAgain.verticalCenter
        anchors.right: btnAgain.left
        anchors.rightMargin: btnAgain.width/5
        color: "black"
        radius: 5*app.dp
        width: labelPlayAgain.paintedWidth*1.3
        height: btnAgain.height*0.4
        opacity: btnAgain.state == "open" ? 1 : 0
        Behavior on opacity {
            SequentialAnimation {
                NumberAnimation { duration: 600; easing.type: Easing.InOutQuart }
            }
        }
        Label {
            id: labelPlayAgain
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            color: "white"
            text: qsTr("Play again")
            font.pixelSize: parent.height*0.6
        }
        Rectangle {
            z:5
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: tipAgain.right
            anchors.leftMargin: -width/2
            height: 0.3*parent.height
            width: height
            opacity: tipAgain.opacity
            rotation: 45
            color: "black"
        }
    }

    //------------------------

    Audio {
        id: snd
        volume: settings.soundVolume
        source: "assets:/sounds/button.mp3"
    }

}
