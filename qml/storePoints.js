.pragma library

var _privs = {}
var _count = 0

function priv(key) {
    var h = key.toString()
    var o = _privs[key]
    if (!o) {
        o = {}
        _privs[key] = o
        _count += 1
    }
    return o
}

function length() {
    return _count
}

function clear() {
    _privs = {}
    _count = 0
}

//function
