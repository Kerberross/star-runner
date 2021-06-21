tool
extends Spatial


export var truster_strength := 100.0 setget set_truster_strength
export var max_truster_strength := 10.0 setget set_max_truster_strength
var boosted := false setget set_boosted

func set_truster_strength(value: float) -> void:
	if truster_strength != value:
		truster_strength = value
		set_child_truster_strength()

func set_max_truster_strength(value: float) -> void:
	max_truster_strength = value
	set_child_truster_strength()

func set_boosted(value: bool) -> void:
	boosted = value
	set_child_truster_strength()

func set_child_truster_strength():
	for child in get_children():
		if child is Truster:
			child.truster_strength = (truster_strength / 100) * max_truster_strength
			child.boosted = self.boosted
