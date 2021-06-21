tool
extends CPUParticles
class_name Truster

export var truster_strength : float = 10.0 setget set_truster_strength
var boosted := false setget set_boosted

func set_truster_strength(value: float) -> void:
	truster_strength = value
	set_particules_setting()

func set_boosted(value: bool) -> void:
	boosted = value
	set_particules_setting()


func set_particules_setting():
	if truster_strength == 0:
		self.emitting = false
	else:
		self.emitting = true
		self.lifetime = 0.05 * truster_strength

	if boosted:
		self.spread = 20.0
	else:
		self.spread = 1.0
