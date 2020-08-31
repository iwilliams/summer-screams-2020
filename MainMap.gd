extends Spatial

signal task_triggered

onready var player = get_node("PlayerContainer/Player")

var intro_complete = false
var mines_complete = false
var control_complete = false
var inside_complete = false

func mines_completed():
    mines_complete = true
    $Control.power_on = true
    emit_signal("task_triggered", 2)
    
func control_completed():
    if !control_complete:
        control_complete = true
        emit_signal("task_triggered", 3)
    
func inside_completed():
    inside_complete = true


func _physics_process(delta):
    var player_y = player.global_transform.origin.y
    if player_y < -30:
        $inside_bgm.volume_db = 0.0
        $station_bgm.volume_db = -80.0
    elif player_y < -20:
        $inside_bgm.volume_db = lerp(-30, 0, range_lerp(player_y, -20, -30, 0, 1))
        $station_bgm.volume_db = lerp(0, -30, range_lerp(player_y, -20, -30, 0, 1))
    else:
        $station_bgm.volume_db = 0.0
        $inside_bgm.volume_db = -80


func _on_MainRoomTrigger_body_entered(body):
    if body and body.name == "Player":
        if !intro_complete:
            intro_complete = true
            emit_signal("task_triggered", 1)
        if control_complete && !$MainRoom/CoreDoor.is_open:
            $MainRoom/CoreDoor.open()


func _on_Inside_hurt():
    player.add_trauma(5.0)
    pass # Replace with function body.


func _on_Inside_completed():
    emit_signal("task_triggered", 4)
    pass # Replace with function body.
