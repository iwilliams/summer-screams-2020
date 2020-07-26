extends Area

export(NodePath) var teleporter_position_path
onready var teleporter_position: Position3D = get_node(teleporter_position_path)

func _ready():
    connect("body_entered", self, "body_entered")


func body_entered(body):
    if body is RigidBody && body.has_method("teleport"):
        body.teleport(transform.origin - teleporter_position.transform.origin);
