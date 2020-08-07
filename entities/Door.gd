extends RigidBody

export(NodePath) var anchor_node_path
onready var anchor_node = get_node(anchor_node_path)

export(bool) var locked = false

onready var joint := HingeJoint.new()
onready var joint_spawn := find_node("JointSpawn")

# Called when the node enters the scene tree for the first time.
func _ready():
    joint.set_flag(HingeJoint.FLAG_USE_LIMIT, true)
    joint.set_param(HingeJoint.PARAM_LIMIT_UPPER, deg2rad(0))
    if locked:
        joint.set_param(HingeJoint.PARAM_LIMIT_LOWER, deg2rad(0))
    else:
        joint.set_param(HingeJoint.PARAM_LIMIT_LOWER, deg2rad(-180))
    joint.set_node_a(self.get_path())
    if anchor_node is QodotMap:
        joint.set_node_b(anchor_node.get_child(0).get_path())
    else:
        joint.set_node_b(anchor_node.get_path())
    joint.transform = joint_spawn.transform
    add_child(joint)


func unlock():
    joint.set_param(HingeJoint.PARAM_LIMIT_LOWER, deg2rad(-180))
