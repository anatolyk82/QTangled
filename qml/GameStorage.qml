import QtQuick 2.0
import QtQuick.LocalStorage 2.0

/************************************
 * Table 'settings'
 *  - variable
 *  - value
 *
 * Table 'scores'
 *  - created_date
 *  - game_type
 *  - level
 *  - time
 *  - score
 *
 *************************************/


Item {
    id: gameStorage

    property var db

    signal gameStorageReady()

    function initStorage()
    {
        db = LocalStorage.openDatabaseSync("QTangled", "1.0", "QTangled storage", 100000)
        db.transaction(
                    function(tx) {
                        // Create the database if it doesn't already exist
                        tx.executeSql('CREATE TABLE IF NOT EXISTS settings(variable TEXT, value TEXT);');
                        tx.executeSql("CREATE TABLE IF NOT EXISTS scores(created_date DATE DEFAULT (datetime('now','localtime')), game_type INTEGER, level INTEGER, `time` TEXT, time_ms INTEGER, score INTEGER);");
                    }
                    )
        gameStorage.gameStorageReady()
    }


    function saveScoreGame( game_type, level, time, time_ms, score )
    {
        db.transaction(
                    function(tx) {
                        //var rs = tx.executeSql('INSERT INTO scores (game_type, level, `time`, time_ms, score) VALUES ('+game_type+', '+level+', "'+time+'", '+time_ms+', '+score+')');
                        var rs = tx.executeSql('INSERT INTO scores (game_type, level, `time`, time_ms, score) VALUES (?, ?, ?, ?, ?);',[game_type,level,time,time_ms,score]);
                    }
                    )
    }

    function clearScores()
    {
        db.transaction(
                    function(tx) {
                        var rs = tx.executeSql('TRUNCATE TABLE scores');
                    }
                    )
    }

    function getLastScores( listModel, limit )
    {
        listModel.clear()
        db.readTransaction(
                    function(tx) {
                        var rs = tx.executeSql('SELECT created_date, game_type, level, `time`, time_ms, score FROM scores ORDER BY score DESC LIMIT '+limit);
                        for(var i = 0; i < rs.rows.length; i++) {
                            listModel.append({
                                                 "date": rs.rows.item(i).created_date,
                                                 "game_type":rs.rows.item(i).game_type,
                                                 "level":rs.rows.item(i).level,
                                                 "time":rs.rows.item(i).time,
                                                 "time_ms":rs.rows.item(i).time_ms,
                                                 "score":rs.rows.item(i).score
                                             })
                        }
                    }
                    )
    }

    function getAllScoresMin( type, listModel )
    {
        listModel.clear()
        db.readTransaction(
                    function(tx) {
                        var rs = tx.executeSql('SELECT created_date, game_type, level, `time`, min(time_ms) as time_ms FROM scores WHERE game_type = '+type+' GROUP BY level');
                        for(var i = 0; i < rs.rows.length; i++) {
                            listModel.append({
                                                 "date": rs.rows.item(i).created_date,
                                                 "game_type":rs.rows.item(i).game_type,
                                                 "level":rs.rows.item(i).level,
                                                 "time":rs.rows.item(i).time,
                                                 "time_ms":rs.rows.item(i).time_ms,
                                                 "score":rs.rows.item(i).score
                                             })
                        }
                    }
                    )
    }

    function getAllScores( game_type, listModelx )
    {
        listModelx.clear()
        db.readTransaction(
                    function(tx) {
                        var rs = tx.executeSql('
                        select level, min(time_ms) as time_min, max(time_ms) as time_max, count(level) as count_attempts from scores where game_type = '+game_type+' group by level ');
                        for(var i = 0; i < rs.rows.length; i++) {
                            listModelx.append({
                                                 "level":rs.rows.item(i).level,
                                                 "time_min":rs.rows.item(i).time_min,
                                                 "time_max":rs.rows.item(i).time_max,
                                                 "count_attempts":rs.rows.item(i).count_attempts
                                             })
                        }
                    }
                    )
    }
    function getBestTimeMs( game_type, level )
    {
        var returnValue = 0
        db.readTransaction(
                    function(tx) {
                        var rs = tx.executeSql('select min(time_ms) as time_min from scores where game_type = ? and level = ?;',[game_type,level]);
                        if( rs.rows.length > 0 ) {
                            returnValue = parseInt(rs.rows.item(0).time_min)
                        } else {
                            returnValue = 0
                        }
                    }
                    )
        //console.log("Ms["+returnValue+"]")
        return returnValue
    }
    function getBestTime( game_type, level )
    {
        var returnValue = ""
        db.readTransaction(
                    function(tx) {
                        var rs = tx.executeSql('select min(time_ms) as time_min, `time` from scores where game_type = ? and level = ?;',[game_type, level]);
                        if( rs.rows.length > 0 ) {
                            returnValue = rs.rows.item(0).time
                        } else {
                            returnValue = ""
                        }
                    }
                    )
        return returnValue
    }
/*
    property int storedRecord: 0
    function getMyRecord( gameType, record )
    {
        db.readTransaction(
                    function(tx) {
                        var rs = tx.executeSql('SELECT MAX(score) AS score FROM scores WHERE game_type = ' + gameType);
                        if( rs.rows.length > 0 ) {
                            storedRecord = rs.rows.item(0).score
                        } else {
                            storedRecord = 0
                        }
                    }
                    )
    }
*/

/********************** settings **********************/
    property string __param: ""
    function _getParam( paramName )
    {
        db.readTransaction(
                    function(tx) {
                        var rs = tx.executeSql('SELECT value FROM settings WHERE variable = ?', [paramName] );
                        if( rs.rows.length > 0 ) {
                            __param = rs.rows.item(0).value
                        } else {
                            __param = ""
                        }
                    }
                    )
    }
    function _setParam( paramName, val )
    {
        _getParam( paramName )
        if( __param != "" )
        {
            //update
            db.transaction(
                        function(tx) {
                            var rs = tx.executeSql('UPDATE settings SET value = ? WHERE variable = ?',[val,paramName]);
                        }
                        )
        }
        else
        {
            //insert
            db.transaction(
                        function(tx) {
                            var rs = tx.executeSql('INSERT INTO settings (variable, value) VALUES (?, ?)',[paramName,val]);
                        }
                        )
        }
    }

    function login() {
        _getParam("login")
        console.log("login:" + __param)
        return __param
    }
    function setLogin( lgn ) { _setParam("login", lgn) }

    function password() {
        _getParam("password")
        console.log("password:" + __param)
        return __param
    }
    function setPassword( pswd ) { _setParam("password", pswd) }



    function soundsOnOff() {
        _getParam("sound")
        return __param == 0 ? false : true
    }
    function setSoundOnOff( isOn ) { _setParam("sound", isOn) }

    function musicOnOff() {
        _getParam("music")
        return __param == 0 ? false : true
    }
    function setMusicOnOff( isOn ) { _setParam("music", isOn) }


    Component.onCompleted: {
        gameStorage.initStorage()
    }
}
