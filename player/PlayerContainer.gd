extends Spatial

onready var player = find_node("Player")
onready var player_pivot = player.find_node("Pivot")
onready var hud_3d = find_node("Hud3D")


func _process(delta):
    hud_3d.set_player_rotation(player.get_node("Pivot").rotation_degrees)
