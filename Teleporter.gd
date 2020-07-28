extends Area

export(NodePath) var teleporter_to_path
onready var teleporter_to: Position3D = get_node(teleporter_to_path)


func _ready():
    $MeshInstance.queue_free()
    connect("body_entered", self, "body_entered")


func body_entered(body):
    if body is RigidBody && body.has_method("teleport"):       
        body.teleport(
            global_transform, 
            teleporter_to.global_transform
        )
