extends Spatial

export(NodePath) var door: NodePath
var open = false
var initial_up: Vector3
var initial_right: Vector3

onready var joint := HingeJoint.new()
onready var body = get_node("ValveBody")
onready var joint_spawn = get_node("JointSpawn")

# Called when the node enters the scene tree for the first time.
func _ready():
    initial_up = body.transform.basis.y
    initial_right = body.transform.basis.x

    joint.set_flag(HingeJoint.FLAG_USE_LIMIT, true)
    joint.set_param(HingeJoint.PARAM_BIAS, .99)
    joint.set_param(HingeJoint.PARAM_LIMIT_LOWER, deg2rad(1))
    joint.set_param(HingeJoint.PARAM_LIMIT_UPPER, deg2rad(135))
    joint.set_node_a(body.get_path())
    joint.set_node_b(get_node(door).get_path())
    joint.transform = joint_spawn.transform
    add_child(joint)


func _physics_process(delta):
    if open:
        return
        
    var now_up = body.transform.basis.y
    var rot = initial_up.dot(now_up)
    rot += 1
    rot /= 2
    rot *= 180
    if initial_right.dot(now_up) < 0:
        rot = 180 - rot
        pass
    else:
        rot = 180 + rot

    if rot <= 90:
        joint.set_param(HingeJoint.PARAM_LIMIT_LOWER, deg2rad(1))
        joint.set_param(HingeJoint.PARAM_LIMIT_UPPER, deg2rad(135))
    elif rot > 90  && rot < 270:
        joint.set_param(HingeJoint.PARAM_LIMIT_LOWER, deg2rad(1))
        joint.set_param(HingeJoint.PARAM_LIMIT_UPPER, deg2rad(360))
    elif rot >= 270 && rot < 355:
        joint.set_param(HingeJoint.PARAM_LIMIT_LOWER, deg2rad(-90))
        joint.set_param(HingeJoint.PARAM_LIMIT_UPPER, deg2rad(-10))

    if floor(rot) == 350 && !open:
        get_node(door).unlock()
        joint.set_param(HingeJoint.PARAM_LIMIT_UPPER, deg2rad(0))
        joint.set_param(HingeJoint.PARAM_LIMIT_LOWER, deg2rad(0))
        open = true
        $VaultPlayer.play()
