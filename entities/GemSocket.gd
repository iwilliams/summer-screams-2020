extends Area

var joint = null

# Called when the node enters the scene tree for the first time.
func _ready():
    connect("area_entered", self, "_area_entered")


func _area_entered(area: Area):
    if !joint && (area.name == "GemAnchor" || area.name == "GemAnchor2"):
        joint = Generic6DOFJoint.new()
        joint.set_node_a(get_parent().get_path())
        joint.set_node_b(area.get_parent().get_path())
        add_child(joint)
        get_parent().find_node("ray").visible = true
        print("Gotcha")
