extends RigidBody
class_name HitRigidBody

export var damage_velocity_multiply := 10.0


func _ready() -> void:
	pass
	# connect("body_entered", self, "on_body_entered")

func _integrate_forces(state : PhysicsDirectBodyState)->void:
	var collision_force = Vector3.ZERO
	for i in range(state.get_contact_count()):
		collision_force += state.get_contact_impulse(i) * state.get_contact_local_normal(i)
	if collision_force:
		register_hit(collision_force.length() * damage_velocity_multiply)


func register_hit(damage: float) -> void:
	pass


func on_body_entered(body: Node) -> void:
	var velocity = self.linear_velocity.length() - body.linear_velocity.length()
	if velocity > 1:
		register_hit(velocity * damage_velocity_multiply)
