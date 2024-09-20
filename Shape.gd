@tool
class_name Shape extends Node3D

enum ShapeType {
	Sphere,
	Cube,
	Cylinder
}

@export
var type: ShapeType = ShapeType.Sphere

@export_range(0.001, 1.0)
var min_influence: float

@export 
var color: Color = Color.WHITE

var width: float:
	get:
		return transform.basis.get_scale().x

var height: float:
	get:
		return transform.basis.get_scale().y
			
var matrix: Transform3D: 
	get:
		return _get_matrix()

func _ready():
	pass
	

func _process(delta):
	var matrix = _get_matrix()
	

func _get_matrix() -> Transform3D:
	var _transform = transform.affine_inverse()
	#_transform = _transform.scaled(Vector3(1.0, 1.0, 1.0) / _transform.basis.get_scale())
	
	return _transform
	
