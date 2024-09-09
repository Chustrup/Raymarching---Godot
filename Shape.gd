@tool
extends Node3D

@export 
var width: float

@export 
var height: float

@export
var meshInstance: MeshInstance3D
var material: ShaderMaterial

func _ready():
	material = meshInstance.get_active_material(0)
	

func _process(delta):
	var matrix = transform.affine_inverse()
	meshInstance.get_active_material(0).set_shader_parameter("matrix", matrix)

func get_matrix() -> Transform3D:
	var b = basis
	b = b.scaled(Vector3(1.0, 1.0, 1.0) / b.get_scale())
	var t = Transform3D(b, transform.origin)
	
	return t
	
