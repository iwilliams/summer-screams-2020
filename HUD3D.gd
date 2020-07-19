extends Spatial


func set_player_rotation(player_rotation_degrees):
    $Pivot.rotation_degrees = player_rotation_degrees * Vector3(-1, 1, 1)
    pass

