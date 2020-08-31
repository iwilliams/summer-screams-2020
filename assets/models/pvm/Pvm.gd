extends StaticBody

export var has_power = false


# Called when the node enters the scene tree for the first time.
func _ready():
    if has_power:
        turn_on()

func turn_on():
    has_power = true
    var mat = $pvm.get_surface_material(1).duplicate()
    (mat as ShaderMaterial).set_shader_param("uv_offset", Vector2(.5, 0))
    $pvm.set_surface_material(1, mat)
