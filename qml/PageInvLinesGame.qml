import QtQuick 2.4
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
import QtMultimedia 5.4
import QtQuick.Dialogs 1.2
import "./engine.js" as Engine
import "./storeLines.js" as L
import "./storePoints.js" as P

import QMLObjectStore 1.0

MyPage {
    id: pageSimpleGame

    title: qsTr("Invisible lines")
    clip: true

    property bool flDebug: true

    QtObject {
        id: gameGUI
        property int sizDots: settings.sizDot*app.dp
        property int sizFont: 18*app.dp
    }

    property int x0: canvas.width/2 - gameGUI.sizDots/2
    property int y0: canvas.height/2 - gameGUI.sizDots/2
    property int r0: Math.min( canvas.width, canvas.height )*0.8/2

    property int typeOfThisGame: 1

    QMLObjectStore { id: storePoints }
    QMLObjectStore { id: storeLines }

    ListModel { id: pointsModel }
    ListModel { id: linesModel }


    /* This is true when there are intersections */
    property bool intersectionExists: false

    function checkIntersection()
    {
        intersectionExists = false
        for( var pp=0; pp<storeLines.length(); pp++ ) {
            var line = storeLines.getQMLObjectIndx( pp )
            var keyOfLine = storeLines.getKeyByIndex( pp )
            line.flIntersection = false
            storeLines.setQMLObject( keyOfLine, line )
        }

        for( var ii=0; ii<storeLines.length(); ii++ ) {
            var line1 = storeLines.getQMLObjectIndx( ii )
            var keyOfLine1 = storeLines.getKeyByIndex(ii)
            for( var jj=ii+1; jj<storeLines.length(); jj++ ) {
                var line2 = storeLines.getQMLObjectIndx( jj )
                var keyOfLine2 = storeLines.getKeyByIndex(jj)
                var intersection = Engine.getLineIntersection( line1.point1, line1.point2, line2.point1, line2.point2 )
                if( intersection != undefined )
                {
                    //console.log( keyOfLine1+" x "+keyOfLine2+" x="+intersection.x+"; y="+intersection.y)
                    line1.flIntersection = true
                    line2.flIntersection = true
                    storeLines.setQMLObject( keyOfLine1, line1 )
                    storeLines.setQMLObject( keyOfLine2, line2 )
                    intersectionExists = true
                }
            }
        }
    }

    function checkFinish() {
        checkIntersection() //need ?
        if( !intersectionExists ) {
            //LEVEL COMPLETED !
            app.contextMenuButtonVisible = false///new-menu
            gameTimer.stop()

            try {
                var bestTimeForThisLVL = gameStorage.getBestTime( typeOfThisGame, gameSettings.currentGameLevel )
                dlgEndGame.bestTime = bestTimeForThisLVL
            } catch(e) {
                dlgEndGame.bestTime = ""
            }

            gameStorage.saveScoreGame(typeOfThisGame, gameSettings.currentGameLevel, labelGameTime.text, gameTimer.millisecondsTotal, 0)

            dlgEndGame.open()

            if( settings.soundOn ) {
                snd.play()
            }
        }
    }

    Canvas {
        id: canvas
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        onPaint: {
            var cntx = canvas.getContext("2d");
            cntx.clearRect(0,0,canvas.width,canvas.height)
            for( var ii=0; ii<storeLines.length(); ii++ ) {
                var line = storeLines.getQMLObjectIndx( ii )
                line.draw(cntx)
            }
        }

        Repeater {
            id: repeaterPoints
            model: pointsModel
            DragPoint {
                id: point
                dragEnabled: intersectionExists
                x: point_x; y: point_y
                size: gameGUI.sizDots // dragPointSize //settings.sizDragPoint
                label: point_id
                //debug: true
                onDragCheck: { checkIntersection() }
                onDrag: { canvas.requestPaint() }
                onDragStoped: {
                    checkFinish()
                }
                Component.onCompleted: {
                    storePoints.setQMLObject( point_id, point )
                    timerDelayVisiblePoints.start()
                }
                visible: false
                Timer {
                    id: timerDelayVisiblePoints
                    repeat: false
                    interval: 50*index
                    triggeredOnStart: false
                    onTriggered: point.visible = true
                }
            }
            onItemAdded: {
                if( index == (pointsModel.count-1) ) {
                    //console.log( "--> all points was added:"+storePoints.length() )
                    repeaterLines.model = linesModel
                }
            }
        }


        Repeater {
            id: repeaterLines
            MyLine {
                id: line
                thickness: settings.sizLine*app.dp
                point1: storePoints.getQMLObject( pnt1 )
                point2: storePoints.getQMLObject( pnt2 )
                Component.onCompleted: {
                    storeLines.setQMLObject( pnt1+pnt2, line )
                }
                flInvisibleLine: true
            }
            onItemAdded: {
                timerCheckIntersetion.stop()
                timerCheckIntersetion.start()
            }
        }

    } //Canvas


    Timer {
        id: timerCheckIntersetion
        repeat: false
        interval: 1000
        triggeredOnStart: false
        onTriggered: {
            checkIntersection()
            checkFinish()
            canvas.requestPaint()
        }
    }

    Row {
        anchors.top: parent.top
        anchors.topMargin: 10*app.dp
        anchors.left: parent.left
        anchors.leftMargin: 10*app.dp
        spacing: 5*app.dp
        Image {
            anchors.verticalCenter: parent.verticalCenter
            source: "qrc:/images/icon_game.png"
            width: height
            height: labelGameLevel.paintedHeight
            smooth: true
        }
        Label {
            id: labelGameLevel
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr("Level") + ": " + gameSettings.currentGameLevel// + " " + (gameStorage.getBestTime(typeOfThisGame, gameSettings.currentGameLevel) != "" ? (qsTr("Best") + ": " + Engine.formatTime(gameStorage.getBestTime(gameField.typeOfThisGame, gameSettings.currentGameLevel))) : "")
            font.pixelSize: gameGUI.sizFont
        }
    }

    Row {
        spacing: 5*app.dp
        anchors.top: parent.top
        anchors.topMargin: 10*app.dp
        anchors.right: parent.right
        anchors.rightMargin: 10*app.dp
        Image {
            anchors.verticalCenter: parent.verticalCenter
            source: "qrc:/images/icon_time.png"
            width: height
            height: labelGameTime.paintedHeight
            smooth: true
        }
        Label {
            id: labelGameTime
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: gameGUI.sizFont
            text: (gameTimer.minutes < 10 ? "0"+gameTimer.minutes : (gameTimer.minutes == 60 ? "00" : gameTimer.minutes)) +":"+
                  (gameTimer.seconds < 10 ? "0"+gameTimer.seconds : (gameTimer.seconds == 60 ? "00" : gameTimer.seconds)) + "."+
                  (gameTimer.milliseconds == 1000 ? "0" : gameTimer.milliseconds/100)
                  //(gameTimer.milliseconds < 100 ? "0"+gameTimer.milliseconds/10 : (gameTimer.milliseconds == 1000 ? "00" : gameTimer.milliseconds/10))
        }
    }


    property bool flCompleteSoundHasPlayed: false

    Audio {
        id: snd
        volume: settings.soundVolume
        source: "assets:/sounds/level_completed.mp3"
    }


    function initGame() {
        gameTimer.clear()
        canvas.visible = false

        gameSettings.gameActive = true
        var n = gameSettings.currentColumns
        var m = gameSettings.currentRows
        var po = gameSettings.currentPOblique
        var pv = gameSettings.currentPVertical
        //console.log("Level:" + settings.currentGameLevel+" n="+n+" m="+m+" po="+po+" pv="+pv)
        Engine.pointsGenerator( n, m, pointsModel )
        Engine.linesGenerator( n, m, po, pv, pointsModel, linesModel )
        Engine.putPointsByCircle(x0, y0, r0, pointsModel)

        canvas.visible = true
        gameTimer.restart()

        //checkIntersection() // to make lines invisible if they don't have intersections
        app.contextMenuButtonVisible = true///new-menu
    }


    DialogEndGame3 {
        id: dlgEndGame
        time: labelGameTime.text
        time_ms: gameTimer.millisecondsTotal
        level: gameSettings.currentGameLevel
        gameType: pageSimpleGame.typeOfThisGame
        dots: gameSettings.currentColumns*gameSettings.currentRows
        onOkClicked: {
            if( gameSettings.currentGameLevel < (invLinesGameLevels.count-1) ) {
                gameSettings.currentGameLevel += 1

                //clear canvas field
                var cntx = canvas.getContext("2d");
                cntx.clearRect(0,0,canvas.width,canvas.height)
                //clear lines and points store
                storeLines.clear()
                storePoints.clear()
                //clear all models, repeaters and sources
                //linesModel.source = ""
                //repeaterPoints.model = 0
                //repeaterLines.model = 0
                //sound of complete may play again
                flCompleteSoundHasPlayed = false

                //console.log("columns:" + invLinesGameLevels.get( (settings.currentLevel-1) ).columns)
                //console.log("rows:" + invLinesGameLevels.get( (settings.currentLevel-1) ).rows)
                gameSettings.currentColumns = invLinesGameLevels.get( (gameSettings.currentGameLevel-1) ).columns
                gameSettings.currentRows = invLinesGameLevels.get( (gameSettings.currentGameLevel-1) ).rows
                gameSettings.currentPOblique = invLinesGameLevels.get( (gameSettings.currentGameLevel-1) ).pobliq
                gameSettings.currentPVertical = invLinesGameLevels.get( (gameSettings.currentGameLevel-1) ).pobver
                gameSettings.currrentBestTime = invLinesGameLevels.get( (gameSettings.currentGameLevel-1) ).time
                initGame()
            } else {
                app.currentPage = "PageInvLinesGameLevels.qml"
            }
        }
        onReplayClicked: {
            var cntx = canvas.getContext("2d");
            cntx.clearRect(0,0,canvas.width,canvas.height)
            //clear lines and points store
            storeLines.clear()
            storePoints.clear()

            initGame()
        }
    }


    Rectangle {
        id: rectButtonPause
        property bool isPaused: false
        z: 10
        anchors.centerIn: parent
        height: isPaused ? Math.sqrt( parent.height*parent.height + parent.width*parent.width ) : 0
        width: height
        radius: width*0.5
        visible: height != 0
        clip: true
        border.color: "lightgray"
        border.width: app.dp
        ColumnLayout {
            anchors.centerIn: parent
            spacing: 10*app.dp
            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Pause")
                font.pixelSize: 34*app.dp
            }
            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Tap to continue")
            }
        }

        Behavior on height {
            SequentialAnimation {
                ScriptAction {
                    script: {
                        gameTimer.isWorking = rectButtonPause.isPaused ? false : true
                        ///app.contextMenuButtonVisible = !app.contextMenuButtonVisible
                    }
                }
                NumberAnimation { duration: 350 }
            }
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                rectButtonPause.isPaused = false
            }
        }
    }

    Connections {
        target: app
        onMenuIsOpeningChanged: {
            if( (app.menuIsOpening == true) && (rectButtonPause.isPaused == false) && (dlgEndGame.state == "hidden") ) {
                rectButtonPause.isPaused = true
            }
        }
        onContextMenuButtonClicked: {
            contextMenu.popup()
            rectButtonPause.isPaused = true///new-menu
        }
        onIsActiveChanged: {
            if( (app.isActive == true) && (rectButtonPause.isPaused == false) && (dlgEndGame.state == "hidden") ) {
                rectButtonPause.isPaused = true
            }
        }
    }


    Menu {
        id: contextMenu
        MenuItem {
            text: qsTr("Restart")
            onTriggered: {
                var cntx = canvas.getContext("2d");
                cntx.clearRect(0,0,canvas.width,canvas.height)
                //clear lines and points store
                storeLines.clear()
                storePoints.clear()
                initGame()
                rectButtonPause.isPaused = false
            }
        }
        MenuItem {
            text: qsTr("Unpause")
            onTriggered: {
                rectButtonPause.isPaused = false
            }
        }
    }


    Component.onCompleted: {
        initGame()
    }

    Component.onDestruction: {
        gameTimer.stop()
        gameSettings.gameActive = false
        app.contextMenuButtonVisible = false
    }
}

