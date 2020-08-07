extends Area

func _ready():
    connect("body_entered", self, "_body_entered")
    

func _body_entered(body: PhysicsBody):
    if body.name == "Plug" || body.name == "Plug2":
        var joint := Generic6DOFJoint.new()
        joint.set_node_a(get_parent().get_path())
        joint.set_node_b(body.get_path())
        add_child(joint)
        pass
