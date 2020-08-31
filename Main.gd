extends Control

export var skip_intro = false


func _ready():
    get_tree().get_root().connect("size_changed", self, "myfunc")
    
    if skip_intro:
        load_map()
    else:
        $VideoPlayer.connect("finished", self, "load_map")
        $VideoPlayer.play()
    
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func load_map():
    $VideoPlayer.queue_free()
    _set_audio_volume(-80)
    $ViewportContainer/Viewport/HUD.replace_by_instance()
    $ViewportContainer/Viewport/HUD.connect("av_enabled", self, "_on_HUD_av_enabled")
    $ViewportContainer/Viewport/HUD.connect("av_disabled", self, "_on_HUD_av_disabled")
    $ViewportContainer/Viewport/HUD.connect("hud_fade_in", self, "_on_HUD_fade_in")
    $ViewportContainer/Viewport/HUD.connect("hud_fade_out", self, "_on_HUD_fade_out")
    $ViewportContainer/Viewport/HUD.connect("close", self, "_on_HUD_close")
    $ViewportContainer/Viewport/MainMap.replace_by_instance()
    $ViewportContainer/Viewport/MainMap.connect("task_triggered", $ViewportContainer/Viewport/HUD, "trigger_task")


func _on_HUD_fade_in():
    $ViewportContainer/Viewport/MainMap/PlayerContainer/CanvasLayer/ViewportContainer/Viewport/Hud3D/AnimationPlayer.play("Fade")


func _on_HUD_fade_out():
    $ViewportContainer/Viewport/MainMap/PlayerContainer/CanvasLayer/ViewportContainer/Viewport/Hud3D/AnimationPlayer.play_backwards("Fade")


func _input(event):
    if Input.is_action_just_pressed("ui_cancel"):
        Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE else Input.MOUSE_MODE_VISIBLE)
        

func myfunc():
    $ViewportContainer.material.set_shader_param("screen_size", get_viewport_rect().size)


func _on_HUD_av_enabled():
    $AVTween.stop_all()
    $AVTween.interpolate_method(self, "_set_av_modulate", 1.0, 0.0, 1.0)
    $AVTween.start()
    
    $AudioTween.stop_all()
    $AudioTween.interpolate_method(self, "_set_audio_volume", -80.0, -10.0, 1.0)
    $AudioTween.start()


func _on_HUD_av_disabled():
    $AVTween.stop_all()
    $AVTween.interpolate_method(self, "_set_av_modulate", 0.0, 1.0, 2.0)
    $AVTween.start()
    
    $AudioTween.stop_all()
    $AudioTween.interpolate_method(self, "_set_audio_volume", -10.0, -80.0, 2.0)
    $AudioTween.start()
    
    _on_HUD_fade_out()


func _on_HUD_close():
    get_tree().quit()
    

func _set_av_modulate(value):
    $ViewportContainer/Viewport/ColorRect.self_modulate = Color(0.0, 0.0, 0.0, value)
 
    
func _set_audio_volume(value):
    AudioServer.set_bus_volume_db(0, value)


