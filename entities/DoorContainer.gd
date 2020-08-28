extends Spatial

export(NodePath) var anchor_node_path


func _enter_tree():
    $Door.anchor_node = get_node(anchor_node_path)
