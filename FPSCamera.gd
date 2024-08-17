extends Camera3D




func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	var dir = Vector3.ZERO
	var _dir = Vector2.ZERO
	var velocity = 4.0

	if Input.is_action_pressed("up"):
		_dir.y = 1
	elif Input.is_action_pressed("down"):
		_dir.y = -1
		
	if Input.is_action_pressed("left"):
		_dir.x = -1
	elif Input.is_action_pressed("right"):
		_dir.x = 1
	
	dir += global_transform.basis.x * _dir.x
	dir += -global_transform.basis.z * _dir.y
		
	global_position += dir.normalized() * velocity * delta
	
func _input(event):
	if event is InputEventMouseMotion:
		rotation.y += deg_to_rad(-0.2 * event.relative.x)
		rotation.x += deg_to_rad(-0.2 * event.relative.y)
		
