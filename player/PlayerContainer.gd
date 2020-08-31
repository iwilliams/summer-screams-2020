extends Spatial

onready var player = find_node("Player")
onready var hud_3d = find_node("Hud3D")


func _process(delta):
    hud_3d.set_player_basis(player.global_transform.basis)
