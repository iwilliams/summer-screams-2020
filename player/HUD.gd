extends Control


signal av_enabled
signal av_disabled
signal hud_fade_in
signal hud_fade_out
signal close


onready var fps_label = find_node("FpsLabel")
onready var time_label = find_node("TimeLabel")
onready var pos_label = find_node("PosLabel")
onready var center = find_node("Center")
onready var forward_label = find_node("ForwardLabel")

func _process(delta):
  set_fps()
  set_time()

  
func set_fps():
  fps_label.text = "%02dhz" % Engine.get_frames_per_second()

  
func set_time():
  var time_dict = OS.get_time()
  var hour = time_dict.hour
  var minute = time_dict.minute
  var seconds = time_dict.second
  time_label.text = "%02d:%02d:%02d" % [hour, minute, seconds]


func set_player_transform(transform: Transform, rotation_degrees):
    var foo := Vector3(transform.basis.z.x, 0, transform.basis.z.z)
    foo = foo.normalized()
#    forward_label.text = str(Vector3.FORWARD.dot(foo))
#    forward_label.text = str(rotation_degrees.z)
    var deg = ((Vector3.FORWARD.dot(foo) + 1)/2)*180
    if foo.x < 0:
        deg = 180 + (180 - deg)
    forward_label.text = "%d" % deg


func set_pos(translation: Vector3, rotation: Vector3):
  pos_label.text = "%d %d %d" % [translation.x, translation.y, translation.z]


func trigger_task(task_no):
    if task_no == 1:
        $AnimationPlayer.play("Task1")
    elif task_no == 2:
        $AnimationPlayer.play("Task2")
    elif task_no == 3:
        $AnimationPlayer.play("Task3")
    elif task_no == 4:
        $AnimationPlayer.play("Task4")
        
