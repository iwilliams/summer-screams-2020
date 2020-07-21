extends RigidBody

var linear_thrust = 150
var linear_damping = 20
var torque_thrust = 180
var damping = .5

onready var hud = get_parent().find_node("HUD")

onready var left_arm = get_node("../LeftArm")
onready var left_arm_joint = get_node("../LeftArmJoint")
var left_arm_grab_joint: Joint = null
onready var right_arm = get_node("../RightArm")
onready var right_arm_joint = get_node("../RightArmJoint")
var right_arm_grab_joint: Joint = null

func _ready():
    self.connect("body_entered", self, "_thud")


var local_collision_pos

func _thud(body):
    print("thud")
    $ThudPlayer.translation = local_collision_pos + translation
    $ThudPlayer.play(0)
    
func _integrate_forces(state):
    if(state.get_contact_count() >= 1):  #this check is needed or it will throw errors 
        local_collision_pos = state.get_contact_local_position(state.get_contact_count() - 1)


func _create_grab_joint():
    var type = "hinge"
    var joint : Joint
    if type == "hinge":
        joint = HingeJoint.new()
        joint.set_flag(HingeJoint.FLAG_USE_LIMIT, true)
        joint.set_param(HingeJoint.PARAM_LIMIT_UPPER , 0)
        joint.set_param(HingeJoint.PARAM_LIMIT_LOWER , 0)
        joint.set_param(HingeJoint.PARAM_BIAS, .99)
        joint.set_param(HingeJoint.PARAM_LIMIT_SOFTNESS , .99)
        joint.set_param(HingeJoint.PARAM_LIMIT_RELAXATION , 1)
    elif type == "pin":
        joint = PinJoint.new()
        joint.set_param(PinJoint.PARAM_BIAS , .99)
    return joint


func _physics_process(delta):
    var torque_thrust_delta = torque_thrust*delta
    var linear_thrust_delta = linear_thrust*delta
    
    
#    var velocity = linear_velocity * -1 * (1-.5)
    var velocity = Vector3.ZERO
#    var velocity = Vector3.ZERO \
#            - (linear_velocity.normalized() \
#            * Vector3(linear_damping*delta, linear_damping*delta, linear_damping*delta))
    var torque = angular_velocity * -2 * (1-.2)
#    var torque = Vector3.ZERO \
#            - (angular_velocity.normalized() \
#            * Vector3(damping*delta, damping*delta, damping*delta))
    
    if Input.is_action_pressed("drone_pitch_down"):
        torque += global_transform.basis.x.normalized() \
                * torque_thrust_delta \
                * Input.get_action_strength("drone_pitch_down")
    if Input.is_action_pressed("drone_pitch_up"):
        torque += global_transform.basis.x.normalized() \
                * -torque_thrust_delta \
                * Input.get_action_strength("drone_pitch_up")
        
    if Input.is_action_pressed("drone_left"):
        velocity += global_transform.basis.x.normalized() \
                * linear_thrust_delta \
                * Input.get_action_strength("drone_left")
    if Input.is_action_pressed("drone_right"):
        velocity += global_transform.basis.x.normalized() \
                * -linear_thrust_delta \
                * Input.get_action_strength("drone_right")
        
    if Input.is_action_pressed("drone_roll_right"):
        torque += global_transform.basis.z.normalized() * torque_thrust_delta * Input.get_action_strength("drone_roll_right")
    if Input.is_action_pressed("drone_roll_left"):
        torque += global_transform.basis.z.normalized() * -torque_thrust_delta * Input.get_action_strength("drone_roll_left")
    
    if !Input.is_action_pressed("drone_flight_meta"):    
        if Input.is_action_pressed("drone_forward"):
            velocity += global_transform.basis.z.normalized() * linear_thrust_delta * Input.get_action_strength("drone_forward")
        if Input.is_action_pressed("drone_backward"):
            velocity += global_transform.basis.z.normalized() * -linear_thrust_delta * Input.get_action_strength("drone_backward")
        if Input.is_action_pressed("drone_yaw_right"):
            torque += global_transform.basis.y.normalized() * -torque_thrust_delta * Input.get_action_strength("drone_yaw_right")
        if Input.is_action_pressed("drone_yaw_left"):
            torque += global_transform.basis.y.normalized() * torque_thrust_delta * Input.get_action_strength("drone_yaw_left")
        if Input.is_action_pressed("drone_up"):
            velocity += global_transform.basis.y.normalized() * linear_thrust_delta * Input.get_action_strength("drone_up")           
        if Input.is_action_pressed("drone_down"):
            velocity += global_transform.basis.y.normalized() * -linear_thrust_delta * Input.get_action_strength("drone_down")           

    if Input.is_action_pressed("drone_brake"):
        if linear_velocity:
            velocity += linear_velocity*-2
        if angular_velocity:
            torque += angular_velocity*-2

    add_central_force(velocity)
    add_torque(torque)
#    if velocity.abs() > Vector3.ZERO:
#        add_central_force(velocity)
#    else:
#        velocity += linear_velocity*-1*.5
#        add_central_force(velocity)
#    if torque.abs() > Vector3.ZERO:
#        add_torque(torque)
#    else:
#        torque += angular_velocity*-1*.5
#        add_torque(torque)



    if Input.is_action_just_pressed("drone_flashlight"):
        $SpotLight.visible = !$SpotLight.visible
        
    var joint = (get_node("../RightArmJoint") as Generic6DOFJoint)
    var joint2 = (get_node("../LeftArmJoint") as Generic6DOFJoint)
    var joint_velocity = .5
    if Input.is_action_pressed("drone_tool_primary"):
        joint.set_param_y(17, -joint_velocity)
        joint2.set_param_y(17, joint_velocity)   
    elif Input.is_action_pressed("drone_tool_secondary"):
        joint.set_param_y(17, joint_velocity)
        joint2.set_param_y(17, -joint_velocity)
        
        if left_arm_grab_joint:
            get_node(right_arm_grab_joint.get_node_b()).set_mass(1)
            right_arm_grab_joint.get_parent().remove_child(right_arm_grab_joint)
            left_arm_grab_joint.get_parent().remove_child(left_arm_grab_joint)
            right_arm_grab_joint.queue_free()
            left_arm_grab_joint.queue_free()
            right_arm_grab_joint = null
            left_arm_grab_joint = null
    else:
        joint.set_param_y(17, 0)
        joint2.set_param_y(17, 0)
        
    var right_colliding_bodies = right_arm.get_colliding_bodies()
    var left_colliding_bodies = left_arm.get_colliding_bodies()
    
    if Input.is_action_pressed("drone_tool_primary") \
            && right_colliding_bodies.size() > 0 \
            && left_colliding_bodies.size() > 0:
        var right_body = right_colliding_bodies[0]
        var left_body = left_colliding_bodies[0]
        
        if right_body == left_body \
                && right_arm_grab_joint == null \
                && left_arm_grab_joint == null \
                && (right_body is RigidBody || right_body is PhysicalBone) \
                && (left_body is RigidBody || left_body is PhysicalBone):
            
            var grab_joint_position = (right_arm.get_node("GrabPosition").global_transform.origin \
                    + left_arm.get_node("GrabPosition").global_transform.origin) \
                    / 2
            
#            right_arm_grab_joint = Generic6DOFJoint.new()
            right_arm_grab_joint = _create_grab_joint()
#            right_arm_grab_joint.translation = right_arm.get_node("GrabPosition").global_transform.origin
            right_arm_grab_joint.translation = grab_joint_position
            right_arm_grab_joint.set_node_a(right_arm.get_path())
            right_arm_grab_joint.set_node_b(right_body.get_path())
            right_body.get_parent().add_child(right_arm_grab_joint)

            
#            left_arm_grab_joint = Generic6DOFJoint.new()
            left_arm_grab_joint = _create_grab_joint()
#            left_arm_grab_joint.translation = left_arm.get_node("GrabPosition").global_transform.origin
            left_arm_grab_joint.translation = grab_joint_position
            left_arm_grab_joint.set_node_a(left_arm.get_path())
            left_arm_grab_joint.set_node_b(left_body.get_path())
            left_body.get_parent().add_child(left_arm_grab_joint)

            
#            left_body.mode = RigidBody.MODE_STATIC
            left_body.set_mass(0.1)
            print("GRAB")
    
    
    hud.set_pos(translation, rotation_degrees)
    
    var thrusters = {
        $ForwardThrustPlayer: ["drone_forward"],
        $BackwardThrustPlayer: ["drone_backward"],
        $RightThrustPlayer: ["drone_right", "drone_yaw_right", "drone_roll_right"],
        $LeftThrustPlayer: ["drone_left", "drone_yaw_left", "drone_roll_left"],
        $UpThrustPlayer: ["drone_up", "drone_pitch_up"],
        $DownThrustPlayer: ["drone_down", "drone_pitch_down"]   
    }
    
    for thruster in thrusters:
        var actions = thrusters[thruster]
        var just_pressed = false
        for action in actions:
            just_pressed = just_pressed || Input.is_action_just_pressed(action)
        if just_pressed && !thruster.playing:
            (thruster as AudioStreamPlayer3D).pitch_scale = rand_range(.9, 1.1)
            thruster.play()
        else:
            var not_pressed = true
            for action in actions:
                not_pressed = not_pressed && !Input.is_action_pressed(action)
            if not_pressed && thruster.playing:
                thruster.stop()
    
    
var mouse_sensitivity = .1
        
onready var cam = find_node("Pivot")
func _input(event):
    if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
        var movement = event.relative
        cam.rotation.x += deg2rad(movement.y * mouse_sensitivity)
        cam.rotation.x = clamp(cam.rotation.x, deg2rad(-45), deg2rad(45))
        cam.rotation.y += -deg2rad(movement.x * mouse_sensitivity)
        cam.rotation.y = clamp(cam.rotation.y, deg2rad(-45), deg2rad(45))
