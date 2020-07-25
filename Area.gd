extends Area


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
    connect("body_entered", self, "load_big_room")
    pass # Replace with function body.


func load_big_room(body):
    print("load")
    get_node('../bigroom').replace_by_instance()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
