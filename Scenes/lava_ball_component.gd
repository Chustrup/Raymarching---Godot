@tool
extends Node


var shape: Shape
var velocity: Vector3


@export
var amplitude: Vector3 = Vector3.ZERO

@export
var frequency: Vector3 = Vector3.ZERO

@export
var offset: Vector3 = Vector3.ZERO

@export
var time_offset: float = 0.0

@export
var scale = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	shape = get_parent()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var time = Time.get_ticks_msec() + time_offset * 1000
	
	shape.position = offset + amplitude * (Vector3(sin(time * frequency.x / 1000), sin(time * frequency.y / 1000), sin(time * frequency.z / 1000)))
	shape.scale.x = scale
