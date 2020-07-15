extends Control



func _ready():
  get_tree().get_root().connect("size_changed", self, "myfunc")

func myfunc():
  $ColorRect.material.set_shader_param("screen_size", get_viewport_rect().size)
