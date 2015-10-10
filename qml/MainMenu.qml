import QtQuick 2.4
import QtQuick.Controls 1.2


Item {
    id: menu

    signal menuItemClicked( string item, string page )
    property alias currentItem: listViewMenu.currentIndex

    ListModel {
        id: modelMenu
        ListElement {
            item: "classic_game"
            icon: "qrc:/images/icon_game.png"
            page: "PageSimpleGameLevels.qml"
        }
        ListElement {
            item: "invisible_lines"
            icon: "qrc:/images/icon_game.png"
            page: "PageInvLinesGameLevels.qml"
        }
        ListElement {
            item: "limited_mevements"
            icon: "qrc:/images/icon_game.png"
            page: "PageLimitedMovementsGameLevels.qml"
        }
        ListElement {
            item: "settings"
            icon: "qrc:/images/icon_settings.png"
            page: "PageSettings.qml"
        }
        ListElement {
            item: "about"
            icon: "qrc:/images/icon_info.png"
            page: "PageAbout.qml"
        }
    }

    function textItemMenu( item )
    {
        var textReturn = ""
        switch( item ) {
        case "classic_game":
            textReturn = qsTr("Classic game")
            break;
        case "invisible_lines":
            textReturn = qsTr("Invisible lines")
            break;
        case "limited_mevements":
            textReturn = qsTr("Limited movements")
            break;
        case "settings":
            textReturn = qsTr("Settings")
            break;
        case "about":
            textReturn = qsTr("About")
            break;
        case "log":
            textReturn = "Log"
            break;
        }
        return textReturn
    }

    Rectangle {
        id: logoWtapper
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        width: parent.width
        height: width*0.5
        color: palette.primary
        clip: true
        Image {
            id: lollipop_bottom_middle
            source: "qrc:/images/lollipop_bottom_middle.png"
            anchors.bottom: parent.bottom
            anchors.bottomMargin: (app._progressOpening-1)*(height/2)// - 7*app.dp
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: -10*app.dp
            width: parent.width/3
            fillMode: Image.PreserveAspectFit
            antialiasing: true
        }
        Image {
            id: lollipop_top_right
            source: "qrc:/images/lollipop_top_right.png"
            anchors.top: parent.top
            anchors.topMargin: (app._progressOpening-1)*(height/2)// - 5*app.dp
            anchors.right: parent.right
            anchors.rightMargin: parent.width/17
            width: parent.width/3
            fillMode: Image.PreserveAspectFit
            antialiasing: true
        }
        Image {
            id: lollipop_top_left
            source: "qrc:/images/lollipop_top_left.png"
            anchors.top: parent.top
            anchors.topMargin: (app._progressOpening-1)*(height/2)// - 10*app.dp
            anchors.left: parent.left
            //anchors.leftMargin: parent.width/20
            width: parent.width/3
            fillMode: Image.PreserveAspectFit
            antialiasing: true
        }
        Image {
            id: imgLogoQTangled
            source: "qrc:/images/QTangled_small.png"
            height: parent.height/4
            antialiasing: true
            smooth: true
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.leftMargin: -(app._progressOpening-1)*parent.width + 10*app.dp
            fillMode: Image.PreserveAspectFit
        }
    }
    Image {
        id: imgShadow
        anchors.top: logoWtapper.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 10*app.dp
        z: 4
        source: "qrc:/images/shadow_title.png"
    }
    ListView {
        id: listViewMenu
        anchors.top: logoWtapper.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        clip: true
        model: modelMenu
        delegate: componentDelegate
        anchors.leftMargin: (app._progressOpening-1)*60*app.dp
    }

    Component {
        id: componentDelegate

        Rectangle {
            id: wrapperItem
            height: 60*app.dp
            width: parent.width
            color: wrapperItem.ListView.isCurrentItem || ma.pressed ? palette.currentHighlightItem : "transparent"
            Image {
                id: imgItem
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 0.5*imgItem.width
                height: parent.height*0.5
                width: height
                source: icon
                visible: icon != ""
                smooth: true
                antialiasing: true
            }

            Label {
                id: textItem
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: imgItem.right
                anchors.leftMargin: 0.7*imgItem.width
                text: textItemMenu( item )
                font.pixelSize: parent.height*0.3
                color: wrapperItem.ListView.isCurrentItem ? palette.darkPrimary : palette.primaryText
            }


            MouseArea {
                id: ma
                anchors.fill: parent
                enabled: app._menu_shown
                onClicked: {
                    menu.menuItemClicked( item, page )
                    listViewMenu.currentIndex = index
                }
            }
        }

    }
}

