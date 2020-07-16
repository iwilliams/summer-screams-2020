extends RigidBody

var thrust = 20
var torque_thrust = thrust*.5

onready var hud = find_node("HUD")

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


func _physics_process(delta):
    var torque_thrust_delta = torque_thrust*delta
    var thrust_delta = thrust*delta
    
    if Input.is_action_pressed("flight_brake"):
        if linear_velocity:
            add_central_force(linear_velocity*-1)
        if angular_velocity:
            add_torque(angular_velocity*-1)
    elif Input.is_action_pressed("flight_meta"):
        var torque = Vector3()
        if Input.is_action_pressed("ui_up"):
            torque += global_transform.basis.x.normalized() * torque_thrust_delta
        if Input.is_action_pressed("ui_down"):
            torque += global_transform.basis.x.normalized() * -torque_thrust_delta
        if Input.is_action_pressed("ui_right"):
            torque += global_transform.basis.z.normalized() * torque_thrust_delta
        if Input.is_action_pressed("ui_left"):
            torque += global_transform.basis.z.normalized() * -torque_thrust_delta
        add_torque(torque)
    else:
        var velocity = Vector3()
        if Input.is_action_pressed("ui_up"):
            velocity += global_transform.basis.z.normalized() * thrust_delta
        if Input.is_action_pressed("ui_down"):
            velocity += global_transform.basis.z.normalized() * -thrust_delta
        add_central_force(velocity)

        var torque = Vector3()
        if Input.is_action_pressed("ui_right"):
            torque += global_transform.basis.y.normalized() * -torque_thrust_delta
        if Input.is_action_pressed("ui_left"):
            torque += global_transform.basis.y.normalized() * torque_thrust_delta
        add_torque(torque)
        
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
    
    if Input.is_action_pressed("drone_tool_primary") && right_colliding_bodies.size() > 0 && left_colliding_bodies.size() > 0:
        var right_body = right_colliding_bodies[0]
        var left_body = left_colliding_bodies[0]
        if right_body == left_body && right_arm_grab_joint == null && left_arm_grab_joint == null && right_body is RigidBody && left_body is RigidBody:
            right_arm_grab_joint = Generic6DOFJoint.new()
            right_arm_grab_joint.translation = right_arm.get_node("GrabPosition").global_transform.origin
            right_arm_grab_joint.set_node_a(right_arm.get_path())
            right_arm_grab_joint.set_node_b(right_body.get_path())
#            get_parent().add_child(right_arm_grab_joint)
            right_body.get_parent().add_child(right_arm_grab_joint)
            
            left_arm_grab_joint = Generic6DOFJoint.new()
            left_arm_grab_joint.translation = left_arm.get_node("GrabPosition").global_transform.origin
            left_arm_grab_joint.set_node_a(left_arm.get_path())
            left_arm_grab_joint.set_node_b(left_body.get_path())
            left_body.get_parent().add_child(left_arm_grab_joint)
#            get_parent().add_child(left_arm_grab_joint)
            
#            left_body.mode = RigidBody.MODE_STATIC
            left_body.set_mass(0.1)
            print("GRAB")
    
    
    hud.set_pos(translation, rotation_degrees)
