@tool
extends MeshInstance3D

var shader: ShaderMaterial
var shape_nodes: Array[Shape] = []
var light_nodes: Array[Light3D] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	
	var root = get_tree().edited_scene_root
	root.child_entered_tree.connect(_on_new_node)
	root.child_exiting_tree.connect(_on_remove_node)
	shader = get_active_material(0)
	var all_nodes = get_tree().edited_scene_root.get_children(true)
	for node in all_nodes:
		if node is Shape:
			shape_nodes.append(node)
			
		if node is Light3D:
			light_nodes.append(node)
		

func _on_new_node(node: Node):
	if node is Shape:
		shape_nodes.append(node)
		
	if node is Light3D:
		light_nodes.append(node)
		
func _on_remove_node(node: Node):
	if node is Shape:
		var index = shape_nodes.find(node)
		shape_nodes.remove_at(index)
		
	if node is Light3D:
		var index = light_nodes.find(node)
		light_nodes.remove_at(index)
		
func _process(delta):

	var widths = []
	var heights = []
	var matrices = []
	var types = []
	var min_influcenes = []
	var colors = []
	
	for shape in shape_nodes:
		widths.append(shape.width)
		min_influcenes.append(shape.min_influence)
		heights.append(shape.height)
		colors.append(shape.color)
		matrices.append(shape.matrix)
		types.append(int(shape.type))


	shader.set_shader_parameter("shapeCount", len(shape_nodes))
	shader.set_shader_parameter("widths", widths)
	shader.set_shader_parameter("heights", heights)
	shader.set_shader_parameter("minInfluences", min_influcenes)
	shader.set_shader_parameter("colors", colors)

	shader.set_shader_parameter("matrices", matrices)
	shader.set_shader_parameter("types", types)
	print(len(light_nodes))
	shader.set_shader_parameter("lights", light_nodes.map(func(light): return light.position))
	shader.set_shader_parameter("lightsCount", len(light_nodes))
	
	
		
