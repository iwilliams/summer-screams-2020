extends Spatial

signal completed

var num_complete = 0

func gem_inserted():
    num_complete += 1
    if num_complete >= 3:
        emit_signal("completed")
        $MachineStartPlayer.play()
        $MachineStartPlayer.connect("finished", $MachineLoopPlayer, "play", [], CONNECT_ONESHOT)
