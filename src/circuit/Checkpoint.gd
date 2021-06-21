extends Spatial
class_name Checkpoint


onready var spawner := $Spawner
onready var area := $Area
onready var next_checkpoint: Checkpoint


func _ready() -> void:
	area.connect("body_entered", self, "on_body_entered")


func respawn_ship(ship: AbstractShip) -> void:
	ship.global_transform.origin = spawner.global_transform.origin
	ship.reset()

func on_body_entered(body: Node):
	if body is AbstractShip and body.next_checkpoint == self:
		body.last_checkpoint = self
		body.next_checkpoint = next_checkpoint
