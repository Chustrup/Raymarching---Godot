extends Camera3D

var time: float
@export
var distance_from_center: float = 2.0

@export
var velocity: float = 1.0
# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	
	position = Vector3(cos(time * velocity) * distance_from_center, 0, sin(time * velocity) * distance_from_center)
	look_at(Vector3(0,0,0))
	
