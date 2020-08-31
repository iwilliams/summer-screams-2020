extends RigidBody

signal pulled_out

var out = false

func pull_out():
    if !out:
        var joint = $Generic6DOFJoint
        remove_child(joint)
        joint.queue_free()
        out = true
        emit_signal("pulled_out")
        $AudioStreamPlayer3D.pitch_scale = rand_range(.9, 1.1)
        $AudioStreamPlayer3D.play()
