tool
extends RichTextEffect
class_name RichTextType

var bbcode := "type"


func _process_custom_fx(char_fx: CharFXTransform):
    var delay = char_fx.env.get("delay", 0.0)
    var duration = char_fx.env.get("duration", 1.0)
    var size = char_fx.env.get("size")
    
    var step_size = duration/size
    char_fx.visible = !(delay + (step_size * char_fx.relative_index) >= char_fx.elapsed_time)
            
    return true
