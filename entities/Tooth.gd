extends RigidBody

var out = false

func pull_out():
    if !out:
        var joint = $Generic6DOFJoint
        remove_child(joint)
        joint.queue_free()
        out = true
