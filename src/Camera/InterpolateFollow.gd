extends Spatial
class_name InterpolateFollow

export var target_path: NodePath
export var speed: float
export var active: bool

var target: Spatial


func _ready() -> void:
	target = get_node(target_path)


func _process(_delta: float) -> void:
	if active:
		self.global_transform.origin = lerp(self.global_transform.origin, target.global_transform.origin, speed)
