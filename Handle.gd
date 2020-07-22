extends RigidBody

export(NodePath) var door_joint: NodePath
var initial_rotation_degrees
var last_rotation_degrees
var ticks = 0
var rotations setget, _get_rotations
var open = false
func _get_rotations():
    return floor(ticks/360)


# Called when the node enters the scene tree for the first time.
func _ready():
    initial_rotation_degrees = rotation_degrees.x
    last_rotation_degrees = initial_rotation_degrees
    $Generic6DOFJoint.set_param(HingeJoint.PARAM_LIMIT_LOWER, deg2rad(0))
    $Generic6DOFJoint.set_param(HingeJoint.PARAM_LIMIT_UPPER, deg2rad(300))


func _physics_process(delta):
    if open:
        return
    var deltar = abs(abs(last_rotation_degrees) - abs(rotation_degrees.x))
    if angular_velocity.x > 0:
        ticks += deltar
    else:
        ticks -= deltar
    last_rotation_degrees = rotation_degrees.x
    var upper_lim = $Generic6DOFJoint.get_param(HingeJoint.PARAM_LIMIT_UPPER)
    if ticks > 200 && upper_lim <= deg2rad(360):
        $Generic6DOFJoint.set_param(HingeJoint.PARAM_LIMIT_UPPER, deg2rad(360))
    elif ticks < 200 && upper_lim > deg2rad(300):
        $Generic6DOFJoint.set_param(HingeJoint.PARAM_LIMIT_UPPER, deg2rad(300))

  
    if _get_rotations() >= 1 && get_node(door_joint).get_param(HingeJoint.PARAM_LIMIT_LOWER) >= deg2rad(-90):
        get_node(door_joint).set_param(HingeJoint.PARAM_LIMIT_LOWER, deg2rad(-90))
        $Generic6DOFJoint.set_param(HingeJoint.PARAM_LIMIT_UPPER, deg2rad(0))
        $Generic6DOFJoint.set_param(HingeJoint.PARAM_LIMIT_LOWER, deg2rad(0))
        open = true
        $VaultPlayer.play()
