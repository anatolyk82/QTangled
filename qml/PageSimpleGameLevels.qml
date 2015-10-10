import QtQuick 2.4
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
import QtMultimedia 5.4


MyPage {
    id: pageLevels
    title: qsTr("Classic game")
    clip: true    


    ListView {
        anchors.fill: parent
        model: simpleGameLevels
        delegate: componentLevel
        spacing: 5*app.dp
    }

    Component {
        id: pressedButton
        Rectangle {
            id: rectButtonStart
            z: 10
            width: height
            radius: width/2
            Behavior on scale {
                SequentialAnimation {
                    NumberAnimation { duration: 1300 }
                    ScriptAction {
                        script: {
                            app.currentPage = "PageSimpleGame.qml"
                        }
                    }
                }
            }

            Component.onCompleted: { rectButtonStart.scale = 1000 }
        }
    }

    Component {
        id: componentLevel
        Rectangle {
            id: rootWrapper
            width: pageLevels.width
            height: 100*app.dp //pageLevels.width/4
            property bool currentLevelIsLocked: false

            Image {
                id: imgWrapperImage
                source: "qrc:/images/shadow_rectangle.png"
                width: parent.width
                height: parent.height
                Rectangle {
                    id: innerWrapper
                    anchors.centerIn: parent
                    width: parent.width*0.98
                    height: parent.height*0.946
                    color: "transparent"
                    Image {
                        id: imgLevel
                        anchors.left: parent.left
                        anchors.leftMargin: 12*app.dp //this!
                        anchors.verticalCenter: parent.verticalCenter
                        height: parent.height*0.75 //this!
                        width: height
                        source: "qrc:/images/dots"+(columns*rows)+".png"
                        smooth: true
                        z: 3
                    }
                    Column {
                        spacing: 0.06*rootWrapper.height //12*app.dp
                        anchors.left: imgLevel.right
                        anchors.leftMargin: 30*app.dp //this!
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.verticalCenterOffset: -5*app.dp
                        Label {
                            id: labelLevel
                            text: qsTr("LEVEL") + ": " + level
                            font.pixelSize: 0.18*rootWrapper.height //22*app.dp
                        }
                        Row {
                            spacing: 5*app.dp
                            Image {
                                anchors.verticalCenter: parent.verticalCenter
                                source: "qrc:/images/icon_time.png"
                                width: 0.16*rootWrapper.height
                                height: width
                                smooth: true
                            }
                            Label {
                                id: labelTime
                                anchors.verticalCenter: parent.verticalCenter
                                text: time
                                font.pixelSize: 0.16*rootWrapper.height
                                color: rootWrapper.currentLevelIsLocked ? "grey" : "black"
                            }
                        }

                    }

                    Label {
                        id: labelLocked
                        anchors.right: parent.right
                        anchors.rightMargin: 8*app.dp
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 5*app.dp
                        text: rootWrapper.currentLevelIsLocked ? qsTr("LOCKED") : ""
                        font.pixelSize: 0.13*rootWrapper.height
                        color: rootWrapper.currentLevelIsLocked ? "red" : "white"
                    }

                    MouseArea {
                        id: maItem
                        anchors.fill: parent
                        onClicked: {
                            if( settings.soundOn ) {
                                snd.source = rootWrapper.currentLevelIsLocked ? "assets:/sounds/access_denied.mp3" : "assets:/sounds/button.mp3"
                                snd.play()
                            }
                            if( rootWrapper.currentLevelIsLocked ) {
                                //imgTypeButton.rotation = imgTypeButton.rotation + 180
                            } else {
                                var pos = mapToItem( pageLevels,maItem.mouseX, maItem.mouseY )
                                pressedButton.createObject(pageLevels,{
                                                               "x": pos.x,
                                                               "y": pos.y,
                                                               "height": 10/*buttonStart.height*///,
                                                               //"width": 10/*buttonStart.width*/,
                                                               //"radius": 5/*buttonStart.radius*/
                                                           })
                                gameSettings.currentGameLevel = level
                                gameSettings.currentColumns = columns
                                gameSettings.currentRows = rows
                                gameSettings.currentPVertical = pobver
                                gameSettings.currentPOblique = pobliq
                            }
                        }
                        onPressedChanged: {
                            if( pressed ) {
                                innerWrapper.color = palette.currentHighlightItem
                            } else {
                                innerWrapper.color = "white"
                            }
                        }
                    }

                }
            }
            Component.onCompleted: {
                rootWrapper.currentLevelIsLocked = isLevelLock(index, time_ms)
            }
        }
    }

    function isLevelLock( index, time ) {
        if( settings.openAllLeveles ) return false
        if( index == 0 ) {
            return false
        } else if(time != 0 ) {
            return false
        } else {
            var prev_time = simpleGameLevels.get((index-1)).time_ms
            if( prev_time != 0 ) {
                return false
            } else {
                return true
            }
        }
    }

    Audio {
        id: snd
        volume: settings.soundVolume
    }

    Component.onCompleted: {
        gameSettings.currentGameLevel = 0
        initSimpleGameLevels()
    }
}
