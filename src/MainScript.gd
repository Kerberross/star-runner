extends Spatial


export(Array, NodePath) var checkpoints_path
export(Array, NodePath) var ships_path
export var player_path: NodePath
export var camera_path: NodePath
export var path: NodePath
export var lap_max: int
export var waiting_second := 5
export var activate_zoom := 3

onready var player := get_node(player_path)
onready var camera := get_node(camera_path)
onready var gui := $Gui
onready var gui_health := $Gui/Health
onready var gui_shield := $Gui/Shield
onready var gui_boost := $Gui/Boost
onready var gui_lap := $Gui/PlayerLap/Lap
onready var gui_max_lap := $Gui/PlayerLap/MaxLap
onready var gui_leaderboard := $Gui/LeaderBoard
onready var gui_winner := $Gui/EndResult/Winner
onready var gui_loser := $Gui/EndResult/Loser
onready var gui_button := $Gui/EndResult/Buttons
onready var gui_restart_button := $Gui/EndResult/Buttons/Restart
onready var gui_menu_button := $Gui/EndResult/Buttons/Menu
onready var gui_counter := $Gui/EndResult/Counter
onready var gui_second := $Gui/EndResult/Counter/Second
onready var gui_milli_second := $Gui/EndResult/Counter/Milli/Control/MilliSecond

var leaderboardTemplate = preload("res://src/GUI/LeaderBoardShip.tscn")
var leaderboardByPlayer = {}
var ships = []
var start := OS.get_ticks_msec()
var started := false


func _ready() -> void:
	start = OS.get_ticks_msec()
	player.connect("armor_changed", self, "_on_armor_changed")
	player.connect("shield_changed", self, "_on_shield_changed")
	player.connect("boost_changed", self, "_on_boost_changed")
	gui_restart_button.connect("pressed", self, "_on_restart_pressed")
	gui_menu_button.connect("pressed", self, "_on_menu_pressed")
	gui_max_lap.text = str(lap_max)

	var checkpoints = []
	for checkpoint_path in checkpoints_path:
		checkpoints.append(get_node(checkpoint_path))

	for checkpoint_index in checkpoints.size():
		var next_index = checkpoint_index + 1
		if next_index >= checkpoints.size():
			next_index = 0
		checkpoints[checkpoint_index].next_checkpoint = checkpoints[next_index]

	var circuit = get_node(path)
	for ship_path in ships_path:
		var ship = get_node(ship_path)
		ships.append(ship)
		ship.next_checkpoint = checkpoints[0]
		ship.last_checkpoint = checkpoints[checkpoints.size()-1]
		if ship is IAShip:
			ship.circuit_path = circuit
		var l = leaderboardTemplate.instance()
		l.get_node("Name").text = ship.ship_name
		l.get_node("MaxLap").text = str(lap_max)
		gui_leaderboard.add_child(l)
		leaderboardByPlayer[ship] = l
		ship.connect("lap_changed", self, "_on_lap_changed")


func _on_armor_changed(value: float) -> void:
	gui_health.value = (self.player.armor_pv / self.player.armor_pv_max) * 100


func _on_shield_changed(value: float) -> void:
	gui_shield.value = (self.player.shield_pv / self.player.shield_pv_max) * 100

func _on_boost_changed(value: float) -> void:
	gui_boost.value = (self.player.boost / self.player.boost_max) * 100

func _on_restart_pressed() -> void:
	get_tree().change_scene("res://src/main.tscn")

func _on_menu_pressed() -> void:
	get_tree().change_scene("res://src/GUI/MainMenu.tscn")

func _on_lap_changed(sender: AbstractShip, value: float) -> void:
	if sender == player:
		gui_lap.text = str(value)
		if value == lap_max:
			var ship_finished = 0
			for ship in ships:
				if ship.lap >= lap_max:
					ship_finished += 1
			gui_button.visible = true
			if ship_finished == 1:  # since 1 have already finished
				gui_winner.visible = true
			else:
				gui_loser.get_node("place").text = str(ship_finished)
				gui_loser.visible = true

	var l = leaderboardByPlayer[sender]
	l.get_node("CurrentLap").text = str(value)

	var place = 0
	for ship in ships:
		if ship.lap >= value:
			place += 1
	gui_leaderboard.move_child(l, place)

func _process(delta: float) -> void:
	if not started:
		var current := OS.get_ticks_msec()
		var second_passed = float(current - start)/1000
		gui_second.text = str(waiting_second - int(second_passed))
		gui_milli_second.text = str(99 - int((second_passed - int(second_passed))*100))
		if current - start > 1000 * waiting_second:
			started = true
			gui_counter.visible = false
			for ship in ships:
				ship.stop_trust_input = false
		if second_passed > activate_zoom:
			camera.active = true
