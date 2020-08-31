extends Spatial

signal completed

export var power_on = false
var open = false

var activated_count = 0


func _turn_power_on():
    $AnimationPlayer.play("Activate")
    open = true
    

func _on_Area_body_entered(body: RigidBody):
    if body && body.name == "Player" && power_on && !open:
        _turn_power_on()


func terminal_activated(activated):
    if activated:
        activated_count += 1
    else:
        activated_count = max(0, activated_count - 1)
        
    if activated_count >= 3:
        emit_signal("completed")
        $OmniLight2/CompletePlayer.play()
