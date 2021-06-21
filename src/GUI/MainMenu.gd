extends Spatial


onready var play_button = $MainMenu/VBoxContainer/Button


func _ready() -> void:
	play_button.connect("pressed", self, "play_pressed")


func play_pressed() -> void:
	get_tree().change_scene("res://src/main.tscn")
