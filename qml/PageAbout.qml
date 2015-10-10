import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1


MyPage {
    id: pageAbout
    title: qsTr("QTangled")

    Rectangle {
        id: wrapper
        z: 2
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        color: palette.primary
        Image {
            id: imgQTangled
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width*0.65
            smooth: true
            fillMode: Image.PreserveAspectFit
            source: "qrc:/images/QTangled_small.png"
            antialiasing: true
        }
    }
    Image {
        id: imgShadow
        anchors.top: wrapper.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 10*app.dp
        z: 2
        source: "qrc:/images/shadow_title.png"
        visible: false
    }


    ListView {
        id: listViewAbout
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: wrapper.bottom
        model: modelAbout
        delegate: Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: pageAbout.width
            height: 80*app.dp
            border.color: "lightgray"
            Row {
                anchors.fill: parent
                spacing: 16*app.dp
                Item {
                    anchors.verticalCenter: parent.verticalCenter
                    width: height
                    height: parent.height
                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width*0.6
                        height: width
                        radius: width/2
                        color: circleColor
                        Label {
                            anchors.centerIn: parent
                            text: circleSymbol
                            font.pixelSize: 26*app.dp
                            color: circleTextColor
                        }
                    }
                }
                Column {
                    spacing: 7*app.dp
                    anchors.verticalCenter: parent.verticalCenter
                    Label {
                        text: labelUp
                        font.pixelSize: 16*app.dp
                        textFormat: Text.RichText
                    }
                    Label {
                        text: labelDown
                        font.pixelSize: 16*app.dp
                        textFormat: Text.RichText
                        onLinkActivated: { Qt.openUrlExternally(link) }
                    }
                }
            }
        }
    }

    ListModel {
        id: modelAbout
        ListElement {
            circleColor: "#00b300"
            circleSymbol: "P"
            circleTextColor: "#3078fe"
            labelUp: "Programming"
            labelDown: "Anatoly Kozlov"
        }
        ListElement {
            circleColor: "#ff9f00"
            circleSymbol: "M"
            circleTextColor: "#424242"
            labelUp: "Music"
            labelDown: "<a href='http://soundimage.org'>http://soundimage.org</a>"
        }
        ListElement {
            circleColor: "#80c342"
            circleSymbol: "Qt"
            circleTextColor: "white"
            labelUp: "Powered by"
            labelDown: "Qt Quick (Qt 5.5)"
        }
    }

    SequentialAnimation {
        id: animOfPage
        running: false

        ScriptAction { script: app.topBarShow() }

        PauseAnimation { duration: 800 }

        ScriptAction {
            script: {
                app.topBarShow()
                imgShadow.visible = true
            }
        }

        ScriptAction {
            script:{
                if(app.firstTimeToShowAbout) {
                    app.firstTimeToShowAbout = false
                    animOfPage.running = false
                }
            }
        }

        PropertyAnimation {
            target: wrapper
            property: "anchors.bottomMargin"
            from: 0
            to: pageAbout.height*0.6
            duration: 800
            easing.type: Easing.OutExpo
        }
    }

    Component.onCompleted: {
        animOfPage.running = true
    }
}

