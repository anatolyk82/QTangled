import QtQuick 2.4
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2


MyPage {
    id: pageSettings
    title: qsTr("Settings")
    clip: true

    ListModel {
        id: modelDateFormat
        ListElement { text: "DD.MM.YYYY"; format: "dd.MM.yyyy" }
        ListElement { text: "DD/MM/YYYY"; format: "dd/MM/yyyy" }
        ListElement { text: "YYYY/MM/DD"; format: "yyyy/MM/dd" }
        ListElement { text: "YYYY-MM-DD"; format: "yyyy-MM-dd" }
    }

    ScrollView {
        id: scrollView
        anchors.fill: parent
        anchors.margins: 15*app.dp
        ColumnLayout {
            spacing: 15*app.dp
            width: scrollView.width

            CheckBox {
                text: qsTr("Sound")
                checked: settings.soundOn
                Layout.fillWidth: true
                onCheckedChanged: {
                    settings.soundOn = checked
                }
            }
            Slider {
                id: soundsVolumeSlider
                enabled: settings.soundOn
                minimumValue: 0.0
                maximumValue: 1.0
                stepSize: 0.05
                value: settings.soundVolume
                Layout.fillWidth: true
                Layout.maximumWidth: 0.9*parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                onValueChanged: {
                    settings.soundVolume = value
                }
            }

            CheckBox {
                text: qsTr("Music")
                checked: settings.musicOn
                Layout.fillWidth: true
                onCheckedChanged: {
                    settings.musicOn = checked
                }
            }

            Slider {
                id: musicVolumeSlider
                enabled: settings.musicOn
                minimumValue: 0.0
                maximumValue: 1.0
                stepSize: 0.05
                value: settings.musicVolume
                Layout.fillWidth: true
                Layout.maximumWidth: 0.9*parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                onValueChanged: {
                    settings.musicVolume = value
                }
            }

            Label {
                text: qsTr("Game field")
                Layout.fillWidth: true
            }

            RowLayout {
                Layout.fillWidth: true
                Item {
                    id: wrapperDotSize
                    anchors.verticalCenter: parent.verticalCenter
                    Layout.minimumWidth: 100*app.dp
                    Layout.minimumHeight: 100*app.dp
                    Image {
                        anchors.centerIn: parent
                        source: "qrc:/images/shadow_circle.png"
                        Rectangle {
                            id: fillingRect
                            width: parent.width*0.8
                            height: width
                            radius: width/2
                            anchors.centerIn: parent
                            color: "#00b300"
                        }
                        width: settings.sizDot*app.dp
                        height: width
                    }
                }
                Slider {
                    id: sizDotSlider
                    minimumValue: 0
                    maximumValue: 80
                    stepSize: 5
                    value: (settings.sizDot - 20)
                    Layout.fillWidth: true
                    anchors.verticalCenter: parent.verticalCenter
                    onValueChanged: {
                        settings.sizDot = (value + 20)
                    }
                }
            }


            RowLayout {
                Layout.fillWidth: true
                Item {
                    id: wrapperSizLine
                    anchors.verticalCenter: parent.verticalCenter
                    Layout.minimumWidth: 100*app.dp
                    Layout.minimumHeight: 20*app.dp
                    Rectangle {
                        anchors.centerIn: parent
                        width: 80*app.dp
                        height: settings.sizLine*app.dp
                        color: "blue"
                    }
                }
                Slider {
                    id: sizLineSlider
                    minimumValue: 0
                    maximumValue: 12
                    stepSize: 1
                    value: (settings.sizLine - 2)
                    Layout.fillWidth: true
                    anchors.verticalCenter: parent.verticalCenter
                    onValueChanged: {
                        settings.sizLine = (value + 2)
                    }
                }
            }

            CheckBox {
                text: qsTr("Open all levels (full version only)")
                checked: settings.openAllLeveles
                Layout.fillWidth: true
                onCheckedChanged: {
                    if( app.fullVersion == false ) {
                        return
                    }
                    settings.openAllLeveles = checked
                }
                onClicked: {
                    if( app.fullVersion == false ) {
                        checked = false
                        dlgWarning.open()
                    }
                }
            }

            CheckBox {
                visible: false //don't need to show it
                text: qsTr("Show Ad (full version only)")
                checked: settings.bannerIsOn
                Layout.fillWidth: true
                onCheckedChanged: {
                    if( app.fullVersion == false ) {
                        return
                    }

                    settings.bannerIsOn = checked
                    if( checked ) {
                        admob.showAd()
                    } else {
                        admob.hideAd()
                    }
                }
                onClicked: {
                    if( app.fullVersion == false ) {
                        checked = true
                        dlgWarning.open()
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.maximumHeight: 2
                Layout.minimumHeight: 2
                color: "gray"
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.minimumHeight: 50*app.dp
                border.color: "gray"
                Label {
                    anchors.centerIn: parent
                    text: qsTr("Version") + ": " + app.version
                }
            }
        }
    }

    MessageDialog {
        id: dlgWarning
        text: qsTr("This option is available for a full version.")
    }
}
