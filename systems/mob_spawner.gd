class_name MobSpawner
extends Node2D

@export var creatures: Array[PackedScene] 

@onready var path_follow2D: PathFollow2D = %PathFollow2D

var mobs_per_minute: float = 60.0
var cooldown: float = 0.0


func _process(delta: float) -> void:
	if GameManager.is_game_over:
		return 
	# Temporizador
	cooldown -= delta
	
	if cooldown > 0:
		return
	
	# Frequencia: Monstros p/ minuto
	var interval = 60.0 / mobs_per_minute
	cooldown = interval
	
	# Check de um ponto valido
	var pointer = get_point()
	var world_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()

	parameters.position = pointer
	parameters.collision_mask = 0b1001
	
	var results: Array = world_state.intersect_point(parameters, 1)
	# Perguntar ao jogo se tem alguma colisão 
	if not results.is_empty():
		return 

	var index = randi_range(0, creatures.size() - 1)
	var creature_scene = creatures[index]
	var creature = creature_scene.instantiate()
	var point = get_point()
	creature.global_position = point

	get_parent().add_child(creature)



func get_point() -> Vector2:
	path_follow2D.progress_ratio = randf()
	
	return path_follow2D.global_position
