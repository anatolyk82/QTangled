import QtQuick 2.0

Item {
    id: myLine

    property color color: "gray"
    property int thickness: 1

    property bool flIntersection: false

    property variant point1
    property variant point2

    property int x1: point1.x + point1.size/2
    property int y1: point1.y + point1.size/2

    property int x2: point2.x + point2.size/2
    property int y2: point2.y + point2.size/2


    property bool flInvisibleLine: false
    property var _cntx
    property bool _flHideLine: false

    function draw( cntx ) {
        _cntx = cntx
        //console.log( "draw():"+point1.label + point2.label+" " +flIntersection)
        cntx.beginPath()

        //cntx.shadowBlur = 0.5
        //cntx.shadowOffsetX = thickness*0.4
        //cntx.shadowOffsetY = thickness*0.4

        cntx.strokeStyle = flIntersection ? "red" : _flHideLine ? "transparent" : "blue"
        cntx.lineWidth = flIntersection ? thickness : _flHideLine ? 0 : thickness
        cntx.moveTo(x1,y1)
        cntx.lineTo(x2,y2);
        cntx.stroke();

        if( flInvisibleLine && (!flIntersection) ) {
            _flHideLine = true
            timerInvisibleLine.start()
        }
    }

    Timer {
        id: timerInvisibleLine
        onTriggered: {
            draw(_cntx)
        }
        triggeredOnStart: false
        interval: 1000
        repeat: false
    }
}
