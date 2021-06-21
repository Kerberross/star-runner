extends AbstractShip
class_name IAShip

export var max_speed : float = 17
onready var circuit_path: Path
onready var debug := $debug
onready var debug2 := $debug2
onready var debug3 := $debug3

var current_point :int= 0
var checkpoint_point :int= 0
var near_checkpoint :bool= false


func get_mouse() -> Vector3:
	var space_state := get_world().direct_space_state
	var mouse_position := get_viewport().get_mouse_position()
	var ray_origin := get_viewport().get_camera().project_ray_origin(mouse_position)
	var ray_end := ray_origin + get_viewport().get_camera().project_ray_normal(mouse_position) * 2000
	var target := space_state.intersect_ray(ray_origin, ray_end)
	if not target.empty():
		return target.position
	return Vector3.ZERO


func _ready() -> void:
	if OS.has_feature("editor"):
		debug.global_transform.origin = Vector3.ZERO
		debug.set_as_toplevel(true)
		debug.visible = true
		debug2.global_transform.origin = Vector3.ZERO
		debug2.set_as_toplevel(true)
		debug2.visible = true
		debug3.global_transform.origin = Vector3.ZERO
		debug3.set_as_toplevel(true)
		debug3.visible = true

func get_next_point() -> Vector3:
	var next_point :Vector3= circuit_path.curve.get_point_position(current_point)
	if next_point.distance_to(self.global_transform.origin) < 10.0:
		current_point += 1
		if current_point >= circuit_path.curve.get_point_count():
			current_point = 0

	if near_checkpoint or next_checkpoint.global_transform.origin.distance_to(self.global_transform.origin) < 15:
		near_checkpoint = true
		next_point = next_checkpoint.global_transform.origin
	return next_point

func get_target_velocity_angle(next_point: Vector3) -> float:
	var lv = linear_velocity # get_mouse() - self.global_transform.origin
	var target: Vector3
	var local_np := next_point - self.global_transform.origin
	# use Vector2 since Vector3.angle_to alwayse return a positive number
	return Vector2(lv.x, lv.z).angle_to(Vector2(local_np.x, local_np.z)) *1.3

func get_target() -> Vector3:
	var next_point := get_next_point()
	var lv := linear_velocity
	var target: Vector3
	var angle = get_target_velocity_angle(next_point)
	if not lv:
		target = next_point
	elif abs(angle) > PI/2:
		target = lv.rotated(Vector3.UP, PI)
	else:
		target = lv.rotated(Vector3.UP, -(angle)*2)
	target = target  + self.global_transform.origin

	if OS.has_feature("editor"):
		draw_line(debug, self.global_transform.origin, target)
		draw_line(debug2, self.global_transform.origin, lv + self.global_transform.origin)
		draw_line(debug3, self.global_transform.origin, next_point)
	return target


func get_truster_strength() -> float:
	var angle_velocity := abs(rad2deg(get_target_velocity_angle(get_next_point())) / 30)
	var t =  min(1, max(angle_velocity, max_speed - linear_velocity.length()))
	return t


func get_boost() -> bool:
	if rad2deg(get_target().angle_to(linear_velocity)) > 100:
		return true
	return false

func set_next_checkpoint(value) -> void:
	.set_next_checkpoint(value)
	checkpoint_point = current_point
	near_checkpoint = false


func respawn() -> void:
	.respawn()
	current_point = checkpoint_point
	near_checkpoint = false


func draw_line(im: ImmediateGeometry, start: Vector3, end: Vector3):
	im.clear()
	im.begin(Mesh.PRIMITIVE_POINTS, null)
	im.add_vertex(start)
	im.add_vertex(end)
	im.end()
	im.begin(Mesh.PRIMITIVE_LINE_STRIP, null)
	im.add_vertex(start)
	im.add_vertex(end)
	im.end()
