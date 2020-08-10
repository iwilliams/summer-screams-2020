extends Spatial

var target_pos: Vector3
var instant = false
onready var thrust_vector = get_node("ThrustVector")

func set_player_transform(player_transform):
    pass


func set_player_rotation(player_rotation_degrees):
    $Pivot.rotation_degrees = player_rotation_degrees * Vector3(-1, 1, 1)
    pass


func set_player_velocity(velocity: Vector3, instant_in = false):
    target_pos = velocity.normalized()
    instant = instant_in


func set_player_basis(basis: Basis):
    $Pivot.global_transform = $Pivot.global_transform.looking_at(basis.z.normalized(), basis.y.normalized())
    pass


func rot_thrust_vector(rot_diff):
    var new_t = thrust_vector.transform
    if rot_diff.y != 0.0:
        new_t = new_t.rotated(Vector3(0, 1, 0), -rot_diff.y)

    if rot_diff.z != 0.0:
        new_t = new_t.rotated(Vector3(0, 0, 1), rot_diff.z)

    if rot_diff.x != 0.0:
        new_t = new_t.rotated(Vector3(1, 0, 0), -rot_diff.x)

    thrust_vector.transform = new_t


func _physics_process(delta):
    var current_pos = thrust_vector.transform.origin.normalized()
    if target_pos.length() > 0 && target_pos.is_normalized() && !current_pos.is_equal_approx(target_pos):
        if instant:
            thrust_vector.transform.origin = (target_pos) * 2 
            instant = false
        else:
            thrust_vector.transform.origin = current_pos.slerp(target_pos, .8*delta) * 2
