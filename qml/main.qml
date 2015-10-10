import QtQuick 2.4
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import Qt.labs.settings 1.0
import QtQuick.Controls 1.2
import QtQuick.XmlListModel 2.0
import QtMultimedia 5.4

import myadmob 1.0
import mydevice 1.0

ApplicationWindow {
    id: app

    property bool fullVersion: false

    property string appTitle: "QTangled"
    width: 360
    height: 640
    visible: true

    property bool isActive: true //it defines whether the app is active or not
    property alias dp: device.dp

    MyAdmob { id: admob }
    MyDevice { id: device }


    QtObject {
        id: palette
        //http://www.materialpalette.com/indigo/yellow
        property color darkPrimary: "#303F9F"
        property color primary: "#3F51B5"
        property color lightPrimary: "#C5CAE9"
        property color text: "#FFFFFF"
        property color accent: "#FFEB3B"
        property color primaryText: "#212121"
        property color secondaryText: "#727272"
        property color divider: "#B6B6B6"

        property color currentHighlightItem: "#dcdcdc"
    }


    property int orientationPortrait: 1
    property int orientationLandscape: 2
    property int orientation: 0
    onWidthChanged: {
        if( width > height ) {
            app.orientation = app.orientationLandscape
        } else {
            app.orientation = app.orientationPortrait
        }
    }

    Settings {
        id: settings
        property string formatDate
        property int formatDateIndex: 0
        property bool bannerIsOn: !app.fullVersion
        property bool soundOn: true
        property real soundVolume: 1.0
        property bool musicOn: true
        property real musicVolume: 0.5
        property bool openAllLeveles: false
        property int sizDot: 70
        property int sizLine: 6

        onMusicOnChanged: {
            setGameMusic()
        }
    }

    property string version: "2015101001"
    property bool firstTimeToShowAbout: true

    property alias currentPage: loader.source

    property int durationOfMenuAnimation: 500
    property int howMuchTheMenuOpen: app.orientation == app.orientationLandscape ? app.dp*300 : app.width*0.85
    property int widthSiezue: app.dp*15
    property bool menuIsOpening: false

    property bool _menu_shown: mormalView.x < (howMuchTheMenuOpen*0.5) ? false : true
    property real _progressOpening

    property bool contextMenuButtonVisible: false
    signal contextMenuButtonClicked()


    function topBarShow() { menuBar.state = "visible" }
    function topBarHide() { menuBar.state = "hidden" }


    /* this rectangle contains the "menu" */
    Rectangle {
        id: menuView
        anchors.left: parent.left
        anchors.top: parent.top
        height: parent.height
        width: (howMuchTheMenuOpen + app.dp*10)
        MainMenu {
            id: mainMenu
            anchors.fill: parent
            onMenuItemClicked: {
                onMenu()
                loader.source = page
            }
        }
    }

    /* this rectangle contains the "normal" view in your app */
    Rectangle {
        id: mormalView
        x: 0
        y: 0
        Behavior on x { NumberAnimation { duration: app.durationOfMenuAnimation; easing.type: Easing.OutQuad } }
        onXChanged: {
            _progressOpening = mormalView.x/howMuchTheMenuOpen
            if( !settings.bannerIsOn ) { admob.hideAd() }
            if( x != 0 ) {
                if( !app.menuIsOpening ) {
                    app.menuIsOpening = true
                }
                if( admob.isAdVisible && settings.bannerIsOn ) admob.hideAd()
            } else {
                if( app.menuIsOpening ) {
                    app.menuIsOpening = false
                }
                if( (!admob.isAdVisible) && settings.bannerIsOn ) admob.showAd()
            }
        }

        width: parent.width
        height: parent.height
        color: "white"

        property alias colorTopBarUnder: topBarUnder.color
        Rectangle {
            id: topBarUnder
            z: 4
            anchors.top: parent.top
            anchors.topMargin: 0
            width: parent.width
            height: app.orientation == app.orientationLandscape ? app.dp*40 : app.dp*50
            color: palette.primary
        }

        Rectangle {
            id: menuBar
            z: 5
            state: "hidden"
            states: [
                State { name: "visible"; PropertyChanges { target: menuBar; anchors.topMargin: 0 } },
                State { name: "hidden"; PropertyChanges { target: menuBar; anchors.topMargin: -menuBar.height } }
            ]
            transitions: Transition {
                NumberAnimation {
                    target: menuBar
                    property: "anchors.topMargin"
                    duration: 500
                    easing.type: Easing.OutQuad
                }
            }
            anchors.top: parent.top
            anchors.topMargin: 0
            width: parent.width
            height: app.orientation == app.orientationLandscape ? app.dp*40 : app.dp*50
            color: palette.darkPrimary
            Rectangle {
                id: menuButton
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: 1.1*height
                height: parent.height
                scale: ma_.pressed ? 1.2 : 1
                color: "transparent"
                MenuIconLive {
                    id: menuBackIcon
                    scale: (parent.height/height)*0.65
                    anchors.centerIn: parent
                    value: mormalView.x/howMuchTheMenuOpen
                }
                MouseArea {
                    id: ma_
                    anchors.fill: parent
                    onClicked: onMenu()
                }
                clip: true
            }
            Label {
                id: titleText
                anchors.left: menuButton.right
                anchors.verticalCenter: parent.verticalCenter
                text: appTitle
                font.pixelSize: 0.35*parent.height
                color: "white"
                anchors.leftMargin: app._progressOpening*60*app.dp
            }
            VisualTimer {
                id: gameTimer
                visible: gameSettings.gameActive && (app.contextMenuButtonVisible == false)
                color: "transparent"
                height: parent.height*0.94
                width: height
                anchors.right: parent.right
                anchors.rightMargin: 10*app.dp
                anchors.verticalCenter: parent.verticalCenter

                millisecondColor: "lightblue"
                secondColor: "red"
                minuteColor: "yellow"
                hourColor: "white"

                millisecondWidth: 3*app.dp
                secondWidth: 5*app.dp
                minuteWidth: 5*app.dp
                hourWidth: 5*app.dp
            }
            Rectangle {
                id: wrapperGameMenu
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: height
                height: parent.height
                color: maGameMenu.pressed ? "#22ffffff" : "transparent"
                clip: true
                Image {
                    id: imgMenu
                    visible: app.contextMenuButtonVisible
                    source: "qrc:/images/icon_menu.png"
                    height: parent.height*0.7
                    anchors.centerIn: parent
                    fillMode: Image.PreserveAspectFit
                }
                MouseArea {
                    id: maGameMenu
                    anchors.fill: parent
                    enabled: imgMenu.visible
                    onClicked: {
                        app.contextMenuButtonClicked()
                    }
                }
            }
        }
        Image {
            id: imgShadow
            anchors.top: menuBar.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 10*app.dp
            z: 4
            source: "qrc:/images/shadow_title.png"
        }


        Loader {
            id: loader
            anchors.top: topBarUnder.bottom;
            anchors.bottom: bannerPlace.top
            anchors.left: parent.left
            anchors.right: parent.right

            //asynchronous: true
            onStatusChanged: {
                if( status == Loader.Loading ) {
                    curtainLoading.visible = true
                    titleText.text = appTitle
                } else if( status == Loader.Ready ) {
                    curtainLoading.visible = false
                } else if( status == Loader.Error ) {
                    curtainLoading.visible = false
                }
            }
            onLoaded: {
                titleText.text = item.title
            }
            Rectangle {
                id: curtainLoading
                anchors.fill: parent
                visible: false
                color: "white"
                opacity: 0.8
                BusyIndicator {
                    anchors.centerIn: parent
                }
            }
        }

        Rectangle {
            id: bannerPlace
            anchors.bottom: parent.bottom;
            anchors.left: parent.left;
            anchors.right: parent.right;
            height: settings.bannerIsOn ? app.dp*50 : 0
            visible: settings.bannerIsOn
            Rectangle {
                id: curtain
                color: "black"
                opacity: app._progressOpening*0.5
                anchors.fill: parent
                z: 100
            }
        }

        /* put this last to "steal" touch on the normal window when menu is shown */
        MouseArea {
            anchors.left: parent.left
            anchors.top: topBarUnder.bottom
            width: app._menu_shown ? parent.width : widthSiezue
            height: parent.height
            drag {
                target: mormalView
                axis: Drag.XAxis
                minimumX: 0
                maximumX: howMuchTheMenuOpen
            }
            onClicked: {
                if(app._menu_shown) app.onMenu()
            }
            onReleased: {
                if( mormalView.x < 0.5*howMuchTheMenuOpen ) {
                    mormalView.x = 0 //close the menu
                } else {
                    mormalView.x = howMuchTheMenuOpen //fully opened
                }
            }
        }
    }

    Image {
        id: imgShadowNormalView
        anchors.top: mormalView.top
        anchors.bottom: mormalView.bottom
        anchors.right: mormalView.left
        width: 6*app.dp
        z: 5
        source: "qrc:/images/shadow_long.png"
    }

    function onMenu()
    {
        mormalView.x = app._menu_shown ? 0 : howMuchTheMenuOpen
    }



    /****************( GUI settings )****************/

    QtObject {
        id: guiSettings

        property int dialodWidth: app.width*0.85
        property int dialodHeigth: app.height*0.5
    }


    /****************( Game settings )****************/
    QtObject {
        id: gameSettings
        property bool gameActive: false
        property int currentGameLevel: 0
        property int currentColumns: 0
        property int currentRows:0
        property int currentPOblique:0
        property int currentPVertical:0
        property int currentLimit:0
        property string currrentBestTime: ""

        onGameActiveChanged: {
            setGameMusic()
        }
    }

    /****************( Game storage )****************/

    GameStorage {
        id: gameStorage
    }
    ListModel { id: dataFromStorage }

    /***********************( SIMPLE GAME )*************************/
    ListModel { id: simpleGameLevels }
    function initSimpleGameLevels()
    {
        simpleGameLevels.clear()
        gameStorage.getAllScoresMin( 0, dataFromStorage )
        for( var k=0; k<simpleGameLevelsXML.count; k++ )
        {
            var level = simpleGameLevelsXML.get(k).level
            simpleGameLevels.append({
                                  "level":simpleGameLevelsXML.get(k).level,
                                  "columns":simpleGameLevelsXML.get(k).columns,
                                  "rows":simpleGameLevelsXML.get(k).rows,
                                  "pobliq":simpleGameLevelsXML.get(k).pobliq,
                                  "pobver":simpleGameLevelsXML.get(k).pobver,
                                  "time":"00:00.0",
                                  "time_ms":0
                              })
            for( var p=0; p<dataFromStorage.count; p++ ) {
                var levelStorgae = dataFromStorage.get(p).level
                if( levelStorgae == level ) {
                    simpleGameLevels.setProperty(k,"time",dataFromStorage.get(p).time)
                    simpleGameLevels.setProperty(k,"time_ms",dataFromStorage.get(p).time_ms)
                    break
                }
            }
        }
    }

    XmlListModel {
        id: simpleGameLevelsXML
        query: "/levels/level"
        source: "qrc:/levels/levels.xml"

        XmlRole { name: "level"; query: "number/number()" }
        XmlRole { name: "columns"; query: "columns/number()" }
        XmlRole { name: "rows"; query: "rows/number()" }
        XmlRole { name: "pobliq"; query: "pobliq/number()" }
        XmlRole { name: "pobver"; query: "pobver/number()" }

        onStatusChanged: {
            if( status == XmlListModel.Error ) {
                console.log("Error: " + errorString() )
            }
            if( status == XmlListModel.Ready ) {
                initSimpleGameLevels()
            }
        }
    }
    /************************************************/


    /***********************( INVISIBLE LINES GAME )*************************/
    ListModel { id: invLinesGameLevels }
    function initInvLinesGameLevels()
    {
        invLinesGameLevels.clear()
        gameStorage.getAllScoresMin( 1, dataFromStorage )
        for( var k=0; k<invLinesGameLevelsXML.count; k++ )
        {
            var level = invLinesGameLevelsXML.get(k).level
            invLinesGameLevels.append({
                                  "level":invLinesGameLevelsXML.get(k).level,
                                  "columns":invLinesGameLevelsXML.get(k).columns,
                                  "rows":invLinesGameLevelsXML.get(k).rows,
                                  "pobliq":invLinesGameLevelsXML.get(k).pobliq,
                                  "pobver":invLinesGameLevelsXML.get(k).pobver,
                                  "time":"00:00.0",
                                  "time_ms":0
                              })
            for( var p=0; p<dataFromStorage.count; p++ ) {
                var levelStorgae = dataFromStorage.get(p).level
                if( levelStorgae == level ) {
                    invLinesGameLevels.setProperty(k,"time",dataFromStorage.get(p).time)
                    invLinesGameLevels.setProperty(k,"time_ms",dataFromStorage.get(p).time_ms)
                    break
                }
            }
        }
    }

    XmlListModel {
        id: invLinesGameLevelsXML
        query: "/levels/level"
        source: "qrc:/levels/invLinesLevels.xml"

        XmlRole { name: "level"; query: "number/number()" }
        XmlRole { name: "columns"; query: "columns/number()" }
        XmlRole { name: "rows"; query: "rows/number()" }
        XmlRole { name: "pobliq"; query: "pobliq/number()" }
        XmlRole { name: "pobver"; query: "pobver/number()" }

        onStatusChanged: {
            if( status == XmlListModel.Error ) {
                console.log("Error: " + errorString() )
            }
            if( status == XmlListModel.Ready ) {
                initInvLinesGameLevels()
            }
        }
    }
    /************************************************/


    /***********************( LIMITED MOVEMENTS GAME )*************************/
    ListModel { id: limitedMovementsGameLevels }
    function initLimitedMovementsGameLevels()
    {
        limitedMovementsGameLevels.clear()
        gameStorage.getAllScoresMin( 2, dataFromStorage )
        for( var k=0; k<limitedMovementsGameLevelsXML.count; k++ )
        {
            var level = limitedMovementsGameLevelsXML.get(k).level
            limitedMovementsGameLevels.append({
                                  "level":limitedMovementsGameLevelsXML.get(k).level,
                                  "columns":limitedMovementsGameLevelsXML.get(k).columns,
                                  "rows":limitedMovementsGameLevelsXML.get(k).rows,
                                  "pobliq":limitedMovementsGameLevelsXML.get(k).pobliq,
                                  "pobver":limitedMovementsGameLevelsXML.get(k).pobver,
                                  "limit":limitedMovementsGameLevelsXML.get(k).limit,
                                  "time":"00:00.0",
                                  "time_ms":0
                              })
            for( var p=0; p<dataFromStorage.count; p++ ) {
                var levelStorgae = dataFromStorage.get(p).level
                if( levelStorgae == level ) {
                    limitedMovementsGameLevels.setProperty(k,"time",dataFromStorage.get(p).time)
                    limitedMovementsGameLevels.setProperty(k,"time_ms",dataFromStorage.get(p).time_ms)
                    break
                }
            }
        }
    }

    XmlListModel {
        id: limitedMovementsGameLevelsXML
        query: "/levels/level"
        source: "qrc:/levels/limitedMovementsLevels.xml"

        XmlRole { name: "level"; query: "number/number()" }
        XmlRole { name: "columns"; query: "columns/number()" }
        XmlRole { name: "rows"; query: "rows/number()" }
        XmlRole { name: "pobliq"; query: "pobliq/number()" }
        XmlRole { name: "pobver"; query: "pobver/number()" }
        XmlRole { name: "limit"; query: "limit/number()" }

        onStatusChanged: {
            if( status == XmlListModel.Error ) {
                console.log("Error: " + errorString() )
            }
            if( status == XmlListModel.Ready ) {
                initLimitedMovementsGameLevels()
            }
        }
    }
    /************************************************/


    Audio {
        id: gameMusicPlayer
        muted: (!settings.musicOn) || (Qt.application.state !== Qt.ApplicationActive)
        volume: settings.musicVolume
        onPlaybackStateChanged: {
            if( playbackState == Audio.StoppedState ) {
                setGameMusic()
            }
        }
    }

    function setGameMusic()
    {
        gameMusicPlayer.stop()
        if( gameSettings.gameActive ) {
            var value = Math.floor( Math.random()*3 )
            //console.log(value)
            if( value == 0 ) {
                gameMusicPlayer.source = "assets:/sounds/game_music_01.mp3"
            } else if(value == 1) {
                gameMusicPlayer.source = "assets:/sounds/game_music_02.mp3"
            } else if(value == 2) {
                gameMusicPlayer.source = "assets:/sounds/game_music_03.mp3"
            }
        } else {
            gameMusicPlayer.source = "assets:/sounds/menu_music_01.mp3"
        }
        if( settings.musicOn ) {
            gameMusicPlayer.play()
        }
    }

    Timer {
        id: timerOpenMenu
        interval: 1000
        triggeredOnStart: false
        repeat: false
        onTriggered: onMenu()
    }

    onClosing: {
        if( app._progressOpening == 1 ) {
            close.accepted = true
        } else {
            close.accepted = false
            onMenu()
        }
    }

    Item {
        id: itemState
        states: [
            State {
                name: "active"
                when: Qt.application.state === Qt.ApplicationActive
            },
            State {
                name: "inactive"
                when: Qt.application.state !== Qt.ApplicationActive
            }
        ]

        onStateChanged: { app.isActive = (itemState.state == "active") }
    }

    Component.onCompleted: {
        if( !settings.bannerIsOn ) admob.hideAd()
        currentPage = "PageAbout.qml"
        mainMenu.currentItem = 4
        setGameMusic()
        timerOpenMenu.start()
    }
}
