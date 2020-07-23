extends RigidBody

export(NodePath) var door: NodePath
var initial_rotation_degrees
var last_rotation_degrees
var ticks = 0
var rotations setget, _get_rotations
var open = false


onready var joint := HingeJoint.new()

func _get_local_angular_velocity():
    return angular_velocity.rotated(rotation.normalized(), -rotation.length())

func _get_rotations():
    return floor(ticks/360)
    
# Called when the node enters the scene tree for the first time.
func _ready():
    initial_rotation_degrees = rotation_degrees
    last_rotation_degrees = rotation_degrees.rotated(initial_rotation_degrees.normalized(), deg2rad(initial_rotation_degrees.length()))
    joint.set_flag(HingeJoint.FLAG_USE_LIMIT, true)
    joint.set_param(HingeJoint.PARAM_BIAS, .99)
    joint.set_param(HingeJoint.PARAM_LIMIT_LOWER, deg2rad(0))
    joint.set_param(HingeJoint.PARAM_LIMIT_UPPER, deg2rad(135))
    joint.set_node_a(self.get_path())
    joint.set_node_b(get_node(door).get_path())
    joint.transform = $JointSpawn.transform
    add_child(joint)


func _physics_process(delta):
    if open:
        return
    # This still isn't right
    var local_angular_velocity = angular_velocity.rotated(initial_rotation_degrees.normalized(), -deg2rad(initial_rotation_degrees.length()))
    var local_rotation_degrees = rotation_degrees.rotated(initial_rotation_degrees.normalized(), deg2rad(initial_rotation_degrees.length()))
    var deltar = abs(abs(last_rotation_degrees.x) - abs(local_rotation_degrees.x))
    if local_angular_velocity.x > 0:
        ticks += deltar
    else:
        ticks -= deltar

    last_rotation_degrees = local_rotation_degrees
    var upper_lim = joint.get_param(HingeJoint.PARAM_LIMIT_UPPER)
    if ticks > 50 && upper_lim <= deg2rad(360):
        joint.set_param(HingeJoint.PARAM_LIMIT_UPPER, deg2rad(360))
    elif ticks < 50 && upper_lim > deg2rad(135):
        joint.set_param(HingeJoint.PARAM_LIMIT_UPPER, deg2rad(135))

  
    if _get_rotations() >= 1 && get_node(door).locked:
        get_node(door).unlock()
        joint.set_param(HingeJoint.PARAM_LIMIT_UPPER, deg2rad(0))
        joint.set_param(HingeJoint.PARAM_LIMIT_LOWER, deg2rad(0))
        open = true
        $VaultPlayer.play()
