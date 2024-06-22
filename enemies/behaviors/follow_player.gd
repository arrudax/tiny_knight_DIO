extends Node

@export var speed: float = 1.0

var enemy: Enemy
var input_vector: Vector2
var sprite: AnimatedSprite2D



func _ready():
	enemy = get_parent()
	sprite = enemy.get_node("AnimatedSprite2D")


func _process(delta: float) -> void:
	# Girar sprite na vertical
	if input_vector.x > 0:
		# Desmarcar flip H sprite2D
		sprite.flip_h = false
	elif input_vector.x < 0:
		# Marcar flip H sprite2D
		sprite.flip_h = true


func _physics_process(delta: float) -> void:
	if GameManager.is_game_over:
		return 
	# Calcular a direção
	var player_position = GameManager.player_position
	var diff = player_position - enemy.position
	input_vector = diff.normalized()

	# Mover
	enemy.velocity = input_vector * speed * 100.0
	enemy.move_and_slide()

	
