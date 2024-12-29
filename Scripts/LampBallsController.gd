@tool
extends Node

@export
var bottom_node: Node3D

var shape_nodes: Array[Shape] = []

func _ready():
	var root = get_tree().edited_scene_root
	
	var all_nodes = get_tree().edited_scene_root.get_children(true)
	for node in all_nodes:
		if node is Shape and node.name != "Base":
			shape_nodes.append(node)
			node.velocity = Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
			
			

func _process(delta: float) -> void:
	var bottom_pos = bottom_node.position
	for shape in shape_nodes:
		var shape_pos = shape.position
		var to_bottom = (bottom_pos - shape_pos).normalized()
		
