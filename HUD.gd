extends Control

onready var fps_label = find_node("FpsLabel")
onready var time_label = find_node("TimeLabel")
onready var pos_label = find_node("PosLabel")
onready var center = find_node("Center")

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


func set_pos(translation: Vector3, rotation: Vector3):
  center.rect_rotation = rotation.z
  pos_label.text = "%d %d %d" % [translation.x, translation.y, translation.z]
