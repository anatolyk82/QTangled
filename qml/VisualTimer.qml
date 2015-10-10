import QtQuick 2.4

Rectangle {
    width: 400
    height: 400

    property color millisecondColor: "blue"
    property color secondColor: "red"
    property color minuteColor: "green"
    property color hourColor: "yellow"

    property int millisecondWidth: 10
    property int secondWidth: 30
    property int minuteWidth: 40
    property int hourWidth: 40

    property int circleWidth: 20

    property alias isWorking: timerOneSec.running

    property int hours: 0
    property int minutes: 0
    property int seconds: 0
    property int milliseconds: 0
    property int millisecondsTotal: 0

    property real _radiusMs: 0
    property real _radiusS: 0
    property real _radiusM: 0
    property real _radiusH: 0

    function start() {
        timerOneSec.start()
    }

    function stop() {
        timerOneSec.stop()
    }

    function restart() {
        clear()
        timerOneSec.start()
    }

    function clear() {
        timerOneSec.stop()
        milliseconds = 0
        seconds = 0
        minutes = 0
        hours = 0
        millisecondsTotal = 0
        var ctx = cnv.getContext("2d")
        ctx.clearRect( 0, 0, cnv.width, cnv.height )
    }

    function calcRadiuses() {
        _radiusMs = Math.min(cnv.width, cnv.height)/2*0.9
        _radiusS = _radiusMs - (millisecondWidth + secondWidth)/2
        _radiusM = _radiusS - (secondWidth+minuteWidth)/2
        _radiusH = _radiusM - (minuteWidth+hourWidth)/2
    }

    onIsWorkingChanged: {
        calcRadiuses()
    }

    Canvas {
        visible: false
        id: cnv
        anchors.fill: parent

        onWidthChanged: {
            calcRadiuses()
        }
        onHeightChanged: {
            calcRadiuses()
        }

        onPaint: {
            var ctx = getContext("2d")

            if( milliseconds == 100 ) {
                ctx.clearRect( 0, 0, cnv.width, cnv.height )
            }

            ctx.lineWidth = hourWidth
            ctx.strokeStyle = hourColor
            ctx.beginPath()
            ctx.arc( cnv.width/2, cnv.height/2, _radiusH, 0-Math.PI/2, (hours/24)*2*Math.PI-Math.PI/2 )
            ctx.stroke();

            ctx.lineWidth = minuteWidth
            ctx.strokeStyle = minuteColor
            ctx.beginPath()
            ctx.arc( cnv.width/2, cnv.height/2, _radiusM, 0-Math.PI/2, (minutes/60)*2*Math.PI-Math.PI/2 )
            ctx.stroke();

            if( minutes > 0 ) {
                ctx.lineWidth = 1
                ctx.strokeStyle = minuteColor
                ctx.beginPath()
                ctx.arc( cnv.width/2, cnv.height/2, _radiusM, 0, 2*Math.PI )
                ctx.stroke();
            }

            ctx.lineWidth = secondWidth
            ctx.strokeStyle = secondColor
            ctx.beginPath()
            ctx.arc( cnv.width/2, cnv.height/2, _radiusS, 0-Math.PI/2, (seconds/60)*2*Math.PI-Math.PI/2 )
            ctx.stroke();

            ctx.lineWidth = 1
            ctx.strokeStyle = secondColor
            ctx.beginPath()
            ctx.arc( cnv.width/2, cnv.height/2, _radiusS, 0, 2*Math.PI )
            ctx.stroke();

            //ctx.lineWidth = millisecondWidth
            //ctx.strokeStyle = millisecondColor
            //ctx.beginPath()
            //ctx.arc( cnv.width/2, cnv.height/2, _radiusMs, 0-Math.PI/2, (milliseconds/1000)*2*Math.PI-Math.PI/2 )
            //ctx.stroke();


        }
    }


    Timer {
        id: timerOneSec
        property bool repaint: false
        onTriggered: {
            millisecondsTotal = millisecondsTotal + 100
            milliseconds = milliseconds + 100
            if( milliseconds == 1100 ) { milliseconds = 100; seconds += 1; timerOneSec.repaint = true }
            if( seconds == 61 ) { seconds = 1; minutes += 1 }
            if( minutes == 61 ) { minutes = 1; hours += 1 }
            if( timerOneSec.repaint ) { cnv.requestPaint(); timerOneSec.repaint = false }
        }
        interval: 100
        repeat: true
    }

}

