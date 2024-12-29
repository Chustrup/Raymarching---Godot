@tool
class_name Shape extends Node3D

enum ShapeType {
	Sphere,
	Cube,
	Mandelbulb,
	CappedCone
}

enum OperationType {
	Union,
	Intersection,
	Difference
}

@export
var type: ShapeType = ShapeType.Sphere

@export
var operation: OperationType = OperationType.Union

@export_range(0.001, 3.0)
var min_influence: float

@export 
var color: Color = Color.WHITE

@export
var order: int = 0



var width: float:
	get:
		return transform.basis.get_scale().x

var height: float:
	get:
		return transform.basis.get_scale().y
		
var depth: float:
	get:
		return transform.basis.get_scale().z
			
var matrix: Transform3D: 
	get:
		return _get_matrix()

func _ready():
	pass
	

func _process(delta):
	var matrix = _get_matrix()
	

func _get_matrix() -> Transform3D:
	var _transform = transform.affine_inverse()
	_transform = _transform.scaled(Vector3(1.0, 1.0, 1.0) / _transform.basis.get_scale())
	
	return _transform
	
