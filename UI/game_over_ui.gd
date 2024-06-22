class_name GameOverUI
extends CanvasLayer

@onready var time_label: Label = %TimeLabel
@onready var count_tabel: Label = %CountMonstersLabel

@export var restart_delay: float = 5.0

var restart_cooldown: float 
var monsters_defeated: int



func _ready() -> void:
	time_label.text = GameManager.time_elapsed_str
	count_tabel.text = str(GameManager.monsters_defeated_count)
	restart_cooldown = restart_delay
	
	
func _process(delta: float) -> void:
	restart_cooldown -= delta
	if restart_cooldown <= 0.0:
		restart_game()
		

func restart_game() -> void:
	GameManager.reset()
	get_tree().reload_current_scene()
	print('Restart game please!')
	pass
