// thanks for http://blog.ivank.net/basic-geometry-functions.html
// http://en.wikipedia.org/wiki/Line-line_intersection

function inRect( a, b, c ) {
    if( (a.x > Math.min(b.x, c.x)) && (a.x < Math.max(b.x, c.x)) && (a.y > Math.min(b.y, c.y)) && (a.y < Math.max(b.y, c.y)) )
        return true
    else if( (a.x == b.x)&&(b.x == c.x)&&(a.y > Math.min(b.y, c.y))&&(a.y < Math.max(b.y, c.y)) )
        return true
    else if( (a.y == b.y)&&(b.y == c.y)&&(a.x > Math.min(b.x, c.x))&&(a.x < Math.max(b.x, c.x)) )
        return true
    return false
}


function getLineIntersection( a1, a2, b1, b2 )
{
    var dax = a1.x - a2.x
    var day = a1.y - a2.y

    var dbx = b1.x - b2.x
    var dby = b1.y - b2.y

    var Den = dax*dby - day*dbx
    if( Den == 0 ) return undefined //lines are parallel

    var A = (a1.x * a2.y - a1.y * a2.x)
    var B = (b1.x * b2.y - b1.y * b2.x)

    var I = Qt.point(0,0)
    I.x = ( A*dbx - dax*B ) / Den
    I.y = ( A*dby - day*B ) / Den

    if( inRect(I, a1, a2) && inRect(I, b1, b2) ) return I
    return undefined
}

function putPointsByCircle( x0, y0, r0, listModel )
{
    var angle = 2*Math.PI/listModel.count
    //console.log("angle="+angle+" x0="+x0+" y0="+y0 + " count="+listModel.count + " r0="+r0)

    var buffRandomIndexes = []
    for( var p = 0; p < listModel.count; p++ ) {
        buffRandomIndexes.push( p )
    }

    //Fisher-Yates shuffle
    var lenModel = buffRandomIndexes.length
    for( var x = 0; x < buffRandomIndexes.length; x++ ) {
        var temp = buffRandomIndexes[x]
        var y = Math.floor( Math.random()*lenModel )
        buffRandomIndexes[x] = buffRandomIndexes[y]
        buffRandomIndexes[y] = temp
    }
    //console.log( buffRandomIndexes )

    for( var f = 0; f < listModel.count; f++ ) {
        var indx = buffRandomIndexes[f]
        var x_i = Math.round( x0 + r0*Math.sin(angle*f) )
        var y_i = Math.round( y0 - r0*Math.cos(angle*f) )
        listModel.setProperty( indx, "point_x", x_i )
        listModel.setProperty( indx, "point_y", y_i )
    }
    return listModel
}


function pointsGenerator( nPointsW, nPointsH, listModel )
{
    listModel.clear()
    for( var indxH=0; indxH<nPointsH; indxH++ )
    {
        for( var indxW=0; indxW<nPointsW; indxW++ ) {
            var label = "p"+indxH+indxW
            listModel.append({"point_x": indxW*100, "point_y": indxH*100, "point_id":label})
        }
    }
}

//actually this function generates a planar graph
function linesGenerator( nPointsW, nPointsH, probOlique, probVert, pointsModel, linesModel )
{
    // *-*-*
    // |\|\|
    // *-*-*
    linesModel.clear()
    //generate horizontal lines
    for( var indxH=0; indxH<nPointsH; indxH++ )
    {
        for( var indxW=0; indxW<(nPointsW-1); indxW++ ) {
            var p_id1 = pointsModel.get( indxH*nPointsW+indxW ).point_id
            var p_id2 = pointsModel.get( indxH*nPointsW+indxW+1 ).point_id
            linesModel.append({"pnt1": p_id1, "pnt2": p_id2})
            //console.log("horizontal line between:"+p_id1+" "+p_id2)
        }
    }
    //generate vertical lines
    for( indxH=0; indxH<(nPointsH-1); indxH++ )
    {
        for( indxW=0; indxW<nPointsW; indxW++ ) {
            if( percentOfEvent(probVert) && (indxW>0) && (indxW<(nPointsW-1)) ) {
                continue
            }
            p_id1 = pointsModel.get( indxH*nPointsW+indxW ).point_id
            p_id2 = pointsModel.get( (indxH+1)*nPointsW+indxW ).point_id
            linesModel.append({"pnt1": p_id1, "pnt2": p_id2})
            //console.log("vertical line between:"+p_id1+" "+p_id2)
        }
    }
    //generate oblique line
    for( indxH=0; indxH<(nPointsH-1); indxH++ )
    {
        for( indxW=0; indxW<(nPointsW-1); indxW++ ) {
            if( !percentOfEvent(probOlique) ) {
                continue
            }
            if( percentOfEvent(50) ) {
                //console.log("\\")
                p_id1 = pointsModel.get( indxH*nPointsW+indxW ).point_id
                p_id2 = pointsModel.get( (indxH+1)*nPointsW+indxW+1 ).point_id
            } else {
                //console.log("/")
                p_id1 = pointsModel.get( indxH*nPointsW+indxW+1 ).point_id
                p_id2 = pointsModel.get( (indxH+1)*nPointsW+indxW ).point_id
            }
            linesModel.append({"pnt1": p_id1, "pnt2": p_id2})
            //console.log("oblique line between:"+p_id1+" "+p_id2)
        }
    }
}


function percentOfEvent( percent )
{
    if( percent == 0 ) return false
    if( percent == 100 ) return true
    var value = Math.floor( Math.random()*100 )
    //console.log( value + " " + percent )
    if( value > percent )
        return false
    else
        return true
}

//====================================
function formatTime( msec ) {
    var str = ""
    var sec = msec / 1000 | 0

    var min = sec/60|0;

    if(min < 10) {
        str += "0"+min+":"
    } else {
        str += min+":"
    }

    sec = sec - min*60
    var msec_new = (msec - sec*1000)

    if( sec < 10) {
        str += "0"+sec
        if( msec_new < 100 ) {
            str += ".0"+(msec_new/100)
        } else {
            str += "."+(msec_new/100)
        }
    } else {
        str += sec
        if( msec_new < 100 ) {
            str += ".0"+(msec_new/100)
        } else {
            str += "."+(msec_new/100)
        }
    }
    return str
}

//====================================

var deltaXPoints = 100;
var deltaYPoints = 100

function pointsGeneratorRandom( nPointsW, nPointsH, PPointsCreate, listModel )
{
    listModel.clear()
    for( var indxH=0; indxH<nPointsH; indxH++ )
    {
        for( var indxW=0; indxW<nPointsW; indxW++ ) {
            var label = "p"+indxH+indxW
            if( percentOfEvent(PPointsCreate) ) {
                listModel.append({"point_x": indxW*deltaXPoints, "point_y": indxH*deltaYPoints, "point_id":label})
            }
        }
    }
}
function linesGeneratorRandom( nPointsW, nPointsH, probOlique, probVert, pointsModel, linesModel )
{

    linesModel.clear()

    //generate horizontal lines
    for( var c=0; c<(pointsModel.count-1); c++ ) {
        var p1 = pointsModel.get( c ).point_id
        var p1y = pointsModel.get( c ).point_y

        var p2 = pointsModel.get( (c+1) ).point_id
        var p2y = pointsModel.get( (c+1) ).point_y

        if( p1y == p2y) {
            linesModel.append({"pnt1": p1, "pnt2": p2})
        }
    }

    //generate vertical lines
    for( var u=0; u<(pointsModel.count-1); u++ ) {
        var p1x = pointsModel.get( u ).point_x
        var p1y = pointsModel.get( u ).point_y
        var p1 = pointsModel.get( u ).point_id
        for( var g=0; g<(pointsModel.count-1); g++ ) {
            var p2 = pointsModel.get( g ).point_id
            var p2x = pointsModel.get( g ).point_x
            var p2y = pointsModel.get( g ).point_y
            if( (p1x == p2x) && ( Math.abs(p2y-p1y) == deltaYPoints ) ) {
                linesModel.append({"pnt1": p1, "pnt2": p2})
            }
        }
    }

    return


    for( var indxH=0; indxH<nPointsH; indxH++ )
    {
        for( var indxW=0; indxW<(nPointsW-1); indxW++ )
        {

            if( p1y == p2y ) {
                if( percentOfEvent(50) ) {
                    linesModel.append({"pnt1": p1, "pnt2": p2})
                }
            }
            //console.log("horizontal line between:"+p_id1+" "+p_id2)
        }
    }


    for( indxH=0; indxH<(nPointsH-1); indxH++ )
    {
        for( indxW=0; indxW<nPointsW; indxW++ ) {
            if( percentOfEvent(30) ) {
                continue
            }
            p_id1 = pointsModel.get( indxH*nPointsW+indxW ).point_id
            p_id2 = pointsModel.get( (indxH+1)*nPointsW+indxW ).point_id
            linesModel.append({"pnt1": p_id1, "pnt2": p_id2})
            //console.log("vertical line between:"+p_id1+" "+p_id2)
        }
    }

    return
    //generate oblique line
    for( indxH=0; indxH<(nPointsH-1); indxH++ )
    {
        for( indxW=0; indxW<(nPointsW-1); indxW++ ) {
            if( !percentOfEvent(probOlique) ) {
                continue
            }
            if( percentOfEvent(50) ) {
                //console.log("\\")
                p_id1 = pointsModel.get( indxH*nPointsW+indxW ).point_id
                p_id2 = pointsModel.get( (indxH+1)*nPointsW+indxW+1 ).point_id
            } else {
                //console.log("/")
                p_id1 = pointsModel.get( indxH*nPointsW+indxW+1 ).point_id
                p_id2 = pointsModel.get( (indxH+1)*nPointsW+indxW ).point_id
            }
            linesModel.append({"pnt1": p_id1, "pnt2": p_id2})
            //console.log("oblique line between:"+p_id1+" "+p_id2)
        }
    }
}


