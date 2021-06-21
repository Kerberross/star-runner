tool
extends Spatial

export var delay : float = 0.0 setget set_delay

func set_delay(value: float) -> void:
	delay = value
	$Arrow/Cube.get_active_material(0).set_shader_param("timeDelay", value)
