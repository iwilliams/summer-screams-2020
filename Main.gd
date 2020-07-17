extends Control


func _ready():
    get_tree().get_root().connect("size_changed", self, "myfunc")
    Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


func myfunc():
    $ColorRect.material.set_shader_param("screen_size", get_viewport_rect().size)
