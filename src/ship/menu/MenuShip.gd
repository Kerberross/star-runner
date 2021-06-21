extends AbstractShip


func _ready() -> void:
	set_physics_process(true)
	set_process(true)
	stop_trust_input = false


func get_truster_strength() -> float:
	return 1.0

