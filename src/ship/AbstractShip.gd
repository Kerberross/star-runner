extends HitRigidBody
class_name AbstractShip

export var ship_name := ""
export var stop_trust_input := true
export var acceleration_forward := 10.0
export var acceleration_stop := 15.0
export var rotation_speed := 15.0
export var shield_pv_max := 100.0
export var shield_reload_rate := 10.0
export var armor_pv_max := 100.0
export var boost_max := 100.0
export var boost_multiplier := 4
export var last_checkpoint_path :NodePath

var shield_pv := shield_pv_max setget set_shield_pv
var armor_pv := armor_pv_max setget set_armor_pv
var boost := boost_max setget set_boost
var shield_reloading := false
var is_dead := false
var lap := 0 setget set_lap

onready var rotated_nodes := $rotated_nodes
onready var back_trusters := $rotated_nodes/back_truster
onready var shield := $CollisionShape/Shield # TODO shder shared between ships!!!
onready var ship := $rotated_nodes/ship
onready var flame := $Flame
onready var animations := $AnimationPlayer
onready var shield_timer := $ShieldTimer
onready var respawn_timer := $RespawnTimer
onready var last_checkpoint := get_node(last_checkpoint_path)
onready var next_checkpoint := get_node(last_checkpoint_path) setget set_next_checkpoint

signal shield_changed(value)
signal armor_changed(value)
signal boost_changed(value)
signal lap_changed(sender, value)


func _ready() -> void:
	shield_timer.connect("timeout", self, "on_shield_ready")
	respawn_timer.connect("timeout", self, "respawn")


func get_target() -> Vector3:
	return Vector3.ZERO


func get_truster_strength() -> float:
	return 0.0


func get_boost() -> bool:
	return false


func set_next_checkpoint(value) -> void:
	next_checkpoint = value


func set_lap(value: int) -> void:
	lap = value
	emit_signal("lap_changed", self, lap)

func _process(delta: float) -> void:
	if is_dead:
		return
	if shield_reloading:
		self.shield_pv += shield_reload_rate * delta
	if not get_boost() and boost < boost_max:
		self.boost += delta * 10


func _physics_process(delta: float) -> void:
	if is_dead:
		return
	var target := get_target()
	if target:
		var target_angle_y := lerp_angle(self.rotated_nodes.rotation.y, self.rotated_nodes.global_transform.looking_at(target, Vector3.UP).basis.get_euler().y, delta * self.rotation_speed)
		self.rotated_nodes.rotation.y = target_angle_y
	var move_force = Vector3.ZERO
	var truster_strength = get_truster_strength()
	if truster_strength and not stop_trust_input:
		move_force = Vector3.FORWARD.rotated(Vector3.UP, self.rotated_nodes.rotation.y) * truster_strength * self.acceleration_forward
		var boosted = false
		if get_boost() and boost > 0:
			move_force *= boost_multiplier
			self.boost -= delta * 100
			boosted = true
		self.add_central_force(move_force)
		self.back_trusters.truster_strength = truster_strength * 100.0
		self.back_trusters.boosted = boosted
	else:
		self.back_trusters.truster_strength = 0.0


func _integrate_forces(state: PhysicsDirectBodyState):
	if is_dead:
		return
	._integrate_forces(state)
	if Input.is_action_pressed("stop"):
		state.apply_central_impulse(-linear_velocity / self.acceleration_stop)


func set_shield_pv(value: float) -> void:
	if shield_pv > value:
		shield_reloading = false
		self.shield_timer.stop()
	shield_pv = value
	emit_signal("shield_changed", shield_pv)
	if shield_pv < 0:
		shield_pv = 0
	if shield_pv >= shield_pv_max:
		shield_pv = shield_pv_max
		shield_reloading = false
	elif shield_pv < shield_pv_max and self.shield_timer.is_stopped() and not shield_reloading:
		self.shield_timer.start()
	self.shield.get_surface_material(0).set_shader_param("shield_strength", self.shield_pv / self.shield_pv_max)


func set_armor_pv(value: float) -> void:
	armor_pv = value
	if armor_pv / armor_pv_max > 0.5:
		self.flame.emitting = false
	else:
		self.flame.emitting = true
	emit_signal("armor_changed", armor_pv)
	if armor_pv < 0:
		death()


func set_boost(value: float) -> void:
	boost = value
	if boost < 0:
		boost = 0
	emit_signal("boost_changed", boost)


func death() -> void:
	is_dead = true
	self.animations.play("death")
	respawn_timer.start()
	self.back_trusters.truster_strength = 0.0
	self.collision_layer = 0
	# inactivate physics
	set_use_custom_integrator(true)
	set_physics_process(false)
	set_process(false)


func register_hit(damage: float) -> void:
	if shield_pv > 0:
		var shield = self.shield_pv - damage
		if shield < 0:
			shield = 0
		self.shield_pv = shield
	else:
		self.armor_pv = self.armor_pv - damage


func on_shield_ready() -> void:
	shield_reloading = true


func respawn() -> void:
	last_checkpoint.respawn_ship(self)


func reset() -> void:
	# reactivate physics
	set_use_custom_integrator(false)
	set_physics_process(true)
	set_process(true)
	self.shield.visible = true
	self.ship.visible = true
	self.is_dead = false
	self.armor_pv = armor_pv_max
	self.shield_pv = shield_pv_max
	self.boost = boost_max
	self.linear_velocity = Vector3.ZERO
	self.collision_layer = 1
