extends Spatial

signal screwed_in

export var is_demo = false

var min_distance = -.30
var max_distance = 0
var current_distance = 0
var done = false

# Called when the node enters the scene tree for the first time.
func _ready():
    ($Screw/SliderJoint as SliderJoint).set_param(SliderJoint.PARAM_ANGULAR_LIMIT_LOWER, deg2rad(-270))
    
    if is_demo:
        $Screw/SliderJoint.set_param(SliderJoint.PARAM_LINEAR_LIMIT_UPPER, min_distance)
        $Screw/SliderJoint.set_param(SliderJoint.PARAM_LINEAR_LIMIT_LOWER, min_distance)
        $Screw.axis_lock_angular_y = true


func _physics_process(delta):
    if is_demo:
        return
        
    if $Screw.angular_velocity.y < -.5 && current_distance > min_distance:
        current_distance -= delta * .05
        $Screw/SliderJoint.set_param(SliderJoint.PARAM_LINEAR_LIMIT_UPPER, current_distance)
        $Screw/SliderJoint.set_param(SliderJoint.PARAM_LINEAR_LIMIT_LOWER, current_distance)
    elif $Screw.angular_velocity.y > .5 && current_distance < max_distance:
        current_distance += delta * .05
        $Screw/SliderJoint.set_param(SliderJoint.PARAM_LINEAR_LIMIT_UPPER, current_distance)
        $Screw/SliderJoint.set_param(SliderJoint.PARAM_LINEAR_LIMIT_LOWER, current_distance)

    if current_distance <= min_distance && !done:
        done = true
        $Screw.axis_lock_angular_y = true
        $LockedPlayer.play()
        emit_signal("screwed_in")
