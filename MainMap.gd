extends Spatial

onready var player = get_node("PlayerContainer/Player")

func _physics_process(delta):
    var player_y = player.global_transform.origin.y
    if player_y < -30:
        $inside_bgm.volume_db = 1.0
        $station_bgm.volume_db = -80.0
    elif player_y < -20:
        $inside_bgm.volume_db = lerp(-30, 1, range_lerp(player_y, -20, -30, 0, 1))
        $station_bgm.volume_db = lerp(1, -30, range_lerp(player_y, -20, -30, 0, 1))
    else:
        $station_bgm.volume_db = 1.0
        $inside_bgm.volume_db = -80
