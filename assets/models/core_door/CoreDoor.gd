extends Spatial


var is_open = false

func open():
    is_open = true
    $AnimationPlayer.play("Open")
