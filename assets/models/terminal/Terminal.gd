extends StaticBody

signal activated

var is_on setget set_is_on, get_is_on
func set_is_on(value):
    $ray.visible = value
    _is_on = value
    emit_signal("activated", _is_on)


func get_is_on():
    return _is_on
    
var _is_on = false


# Called when the node enters the scene tree for the first time.
func _ready():
    set_is_on(_is_on)
