tool
extends RigidBody

var og_up = Vector3.UP
var last_up = og_up
var dr = 0

export(bool) var reset setget set_reset
func set_reset(value):
    og_up = transform.basis.y
    last_up = og_up
    dr = 0
    

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


func _physics_process(delta):
    var dummy = get_node('../Dummy')
    dummy.transform.basis = transform.basis
    dr += 1 - last_up.dot(transform.basis.y)
    last_up = transform.basis.y

#    dummy.transform.basis = dummy.transform.looking_at(Vector3.FORWARD, transform.basis.z).basis
#    dummy.transform = dummy.transform.looking_at(Vector3.UP, Vector3.RIGHT)
#    var relOffset = Vector3(0,0,-1)
#    var relRotPos = transform.basis.xform(relOffset)
