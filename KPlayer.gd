extends KinematicBody

var velocity = Vector3()

func _physics_process(delta):
    
    var scale = 1

    if Input.is_action_pressed("ui_up"):
        velocity += global_transform.basis.z.normalized() * -scale
    if Input.is_action_pressed("ui_down"):
        velocity += global_transform.basis.z.normalized() * scale
    velocity = move_and_slide(velocity)
    
#    var torque = Vector3()
#    if Input.is_action_pressed("ui_right"):
#        torque += global_transform.basis.y.normalized() * -scale
#    if Input.is_action_pressed("ui_left"):
#        torque += global_transform.basis.y.normalized() * scale
#    add_torque(torque)
        
    if Input.is_action_just_pressed("drone_flashlight"):
        $SpotLight.visible = !$SpotLight.visible
        
    $Camera/CanvasLayer/CenterContainer/TextureRect2.rect_rotation = rotation_degrees.z
