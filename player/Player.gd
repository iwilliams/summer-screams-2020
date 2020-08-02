extends RigidBody

var linear_thrust = 150
var linear_damping = 20
var torque_thrust = 280
var damping = .5

onready var hud = get_parent().find_node("HUD")

onready var left_arm = get_node("../LeftArm")
onready var left_arm_joint = get_node("../LeftArmJoint")
var left_arm_grab_joint: Joint = null
onready var right_arm = get_node("../RightArm")
onready var right_arm_joint = get_node("../RightArmJoint")
var right_arm_grab_joint: Joint = null
var should_teleport = null
var holding = null

func _ready():
    self.connect("body_entered", self, "_thud")


var local_collision_pos

func _thud(body):
    print("thud")
#    $ThudPlayer.translation = local_collision_pos + translation
    $ThudPlayer.play(0)
    
func _integrate_forces(state: PhysicsDirectBodyState):
    if(state.get_contact_count() >= 1):  #this check is needed or it will throw errors 
        local_collision_pos = state.get_contact_local_position(state.get_contact_count() - 1)
    
    if should_teleport:
        _teleport_state(state, should_teleport, self)
        var left_arm_state = PhysicsServer.body_get_direct_state(RID(left_arm))
        _teleport_state(left_arm_state, should_teleport, left_arm)
        var right_arm_state = PhysicsServer.body_get_direct_state(RID(right_arm))
        _teleport_state(right_arm_state, should_teleport, right_arm)
        if holding:
            _teleport_state(PhysicsServer.body_get_direct_state(RID(holding)), should_teleport, holding)
        should_teleport = null


func teleport(from, to):
    should_teleport = {
        "from_transform": from.global_transform,
        "from_body": from,
        "to_transform": to.global_transform,
        "to_body": to
    }


func _teleport_state(state: PhysicsDirectBodyState, tp, body):
    var to_rot = tp["to_transform"].basis.get_euler()
    var from_rot = tp["from_transform"].basis.get_euler()
    var rot_diff = to_rot + from_rot
            
    var new_t = Transform()
    new_t.origin = state.get_transform().origin - tp["from_transform"].origin
    new_t.basis = state.get_transform().basis

    if rot_diff.y != 0.0:
        new_t = new_t.rotated(Vector3(0, 1, 0), -rot_diff.y)
        state.set_linear_velocity(state.get_linear_velocity().rotated(Vector3(0, 1, 0), -rot_diff.y))
        state.set_angular_velocity(state.get_angular_velocity().rotated(Vector3(0, 1, 0), -rot_diff.y))

    if rot_diff.z != 0.0:
        new_t = new_t.rotated(Vector3(0, 0, 1), rot_diff.z)
        state.set_linear_velocity(state.get_linear_velocity().rotated(Vector3(0, 0, 1), rot_diff.z))
        state.set_angular_velocity(state.get_angular_velocity().rotated(Vector3(0, 0, 1), rot_diff.z))

    if rot_diff.x != 0.0:
        new_t = new_t.rotated(Vector3(1, 0, 0), -rot_diff.x)
        state.set_linear_velocity(state.get_linear_velocity().rotated(Vector3(1, 0, 0), -rot_diff.x))
        state.set_angular_velocity(state.get_angular_velocity().rotated(Vector3(0, 0, 0), -rot_diff.x))
                    
    new_t.origin += tp["from_transform"].origin
    new_t.origin -= tp["from_transform"].origin - tp["to_transform"].origin  
    

    # this is the global direction vector the player is facing, one unit forward minus the players global offset
    var global_player_direction = body.to_global( Vector3.FORWARD ) - body.global_transform.origin
    # now add this direction to the global position of the portal and transform this into local coordinate system of the portal. this is the relative (to the portal) viewing vector of the player.
    var relative_player_direction = tp["from_body"].to_local( tp["from_transform"].origin + global_player_direction)
    # transform this relative direction to global from the coordinate system of the other portal
    var new_direction = tp["to_body"].to_global( relative_player_direction ) - tp["to_transform"].origin

    state.set_transform(new_t)
    
    pass


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
    
    # Let the player decelerate faster then accelerating
    var brake_force = 3.5
    for component in ['x', 'y', 'z']:
        if (linear_velocity[component] < 0 && velocity[component] > 0) || (linear_velocity[component] > 0 && velocity[component] < 0):
            var force_ratio = abs(velocity[component])/linear_thrust_delta
            velocity[component] += (linear_velocity[component] * -brake_force) * force_ratio

    add_central_force(velocity)
    add_torque(torque)
    
# Dampining
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
            holding = null
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
            right_body.get_parent().add_child(right_arm_grab_joint)
            right_arm_grab_joint.global_transform.origin = grab_joint_position
            right_arm_grab_joint.set_node_a(right_arm.get_path())
            right_arm_grab_joint.set_node_b(right_body.get_path())


            
#            left_arm_grab_joint = Generic6DOFJoint.new()
            left_arm_grab_joint = _create_grab_joint()
#            left_arm_grab_joint.translation = left_arm.get_node("GrabPosition").global_transform.origin
            left_body.get_parent().add_child(left_arm_grab_joint)
            left_arm_grab_joint.global_transform.origin = grab_joint_position
            left_arm_grab_joint.set_node_a(left_arm.get_path())
            left_arm_grab_joint.set_node_b(left_body.get_path())


            
#            left_body.mode = RigidBody.MODE_STATIC
            left_body.set_mass(0.1)
            holding = left_body
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

