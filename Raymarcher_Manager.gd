@tool
extends MeshInstance3D

var shader: ShaderMaterial
var shape_nodes: Array[Shape] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	
	var root = get_tree().edited_scene_root.child_entered_tree.connect(_on_new_node)
	
	shader = get_active_material(0)
	var all_nodes = get_tree().edited_scene_root.get_children(true)
	for node in all_nodes:
	
		if node is Shape:
			shape_nodes.append(node)
			
		

func _on_new_node(node: Node):
	if node is Shape:
		shape_nodes.append(node)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	var widths = []
	var heights = []
	var matrices = []
	var types = []
	var min_influcenes = []
	for shape in shape_nodes:
		widths.append(shape.width)
		min_influcenes.append(shape.min_influence)
		heights.append(shape.height)
		matrices.append(shape.matrix)
		types.append(int(shape.type))

	shader.set_shader_parameter("shapeCount", len(shape_nodes))
	shader.set_shader_parameter("widths", widths)
	shader.set_shader_parameter("heights", heights)
	shader.set_shader_parameter("minInfluences", min_influcenes)

	shader.set_shader_parameter("matrices", matrices)
	shader.set_shader_parameter("types", types)
		
