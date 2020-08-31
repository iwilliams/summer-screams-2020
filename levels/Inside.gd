extends Spatial

signal hurt
signal completed

var complete_count = 0

func _pain_sound(start_index = 1):
    var rand_idx = floor(rand_range(start_index, start_index + 3))
    var player = get_node("Scream" + str(rand_idx))
    player.pitch_scale = rand_range(.9, 1.1)
    player.play()
    $AudioStreamPlayer3D.stop()
    (player as AudioStreamPlayer3D).connect("finished", $AudioStreamPlayer3D, "play", [], CONNECT_ONESHOT)
    emit_signal("hurt")
    $Shake.pitch_scale = rand_range(.9, 1.1)
    $Shake.play()


func _on_Tooth_pulled_out():
    _pain_sound()


func _on_ScrewSocket_screwed_in():
    complete_count += 1
    _pain_sound(4)
    
    if complete_count >= 2:
        emit_signal("completed")
