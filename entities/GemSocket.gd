extends StaticBody

signal gem_inserted

var joint = null

onready var socket_player = find_node("SocketPlayer")

# Called when the node enters the scene tree for the first time.
func _ready():
    $Area.connect("area_entered", self, "_area_entered")


func _area_entered(area: Area):
    if !joint && (area.name == "GemAnchor" || area.name == "GemAnchor2"):
        joint = Generic6DOFJoint.new()
        joint.set_node_a(get_path())
        joint.set_node_b(area.get_parent().get_path())
        add_child(joint)
        $ray.visible = true
        socket_player.play()
        emit_signal("gem_inserted")
