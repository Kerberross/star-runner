extends HitRigidBody

export var torque_random := 20.0
export var pv := 10.0 setget set_pv

export(Array, PackedScene) var parts

func _ready() -> void:
	self.add_torque(Vector3((randf() - 0.5) * torque_random, (randf() - 0.5) * torque_random, (randf() - 0.5) * torque_random))


func register_hit(damage: float) -> void:
	self.pv -= damage


func set_pv(value: float) -> void:
	if pv > 0 and value <= 0:
		for child in get_children():
			child.visible = false
		self.collision_layer = false
		if parts:
			for part in parts:
				var instance_part = part.instance()
				instance_part.global_transform = self.global_transform
				get_tree().root.add_child(instance_part)
	pv = value
