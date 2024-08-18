

extends MeshInstance3D

var time: float = 0.0
var power = 1.0
var duration = 10.0
@export
var mesh_instance: MeshInstance3D

var material: ShaderMaterial

# Called when the node enters the scene tree for the first time.
func _ready():
	material = mesh_instance.get_active_material(0)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	power = easeInOutQuad(clamp(time / duration, 0, 1)) * 30.0
	material.set_shader_parameter("power", power)
	
	if (time >= duration):
		get_tree().quit()

func easeInOutQuad(x: float) -> float: 
	return 2 * x * x if x < 0.5 else 1 - pow(-2 * x + 2, 2) / 2

