class_name Player
extends CharacterBody2D


@export_category("Movement")
@export var speed: float = 3.0

@export_category("Weapon")
@export var sword_damage: int = 2

@export_category("Magic")
@export var ritual_damage: int = 1
@export var ritual_interval: float = 30.0
@export var ritual_scene: PackedScene

@export_category("Life")
@export var health: int = 100
@export var max_health: int = 100
@export var death_prefab: PackedScene


@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sword_area: Area2D = $SwordArea
@onready var hitbox_area: Area2D = $HitboxArea
@onready var health_progress_bar: ProgressBar = $HealthProgressBar


var input_vector:Vector2 = Vector2(0, 0)
var is_runnig: bool = false
var was_running: bool = false
var is_attacking: bool = false
var attack_cooldown: float = 0.0
var hitbox_cooldown: float = 0.0
var ritual_cooldown: float = 0.0

signal meat_collected(value: int)

func _ready() -> void:
	GameManager.player = self
	meat_collected.connect(func(value: int): GameManager.meat_count += 1)


func _process(delta: float) -> void:
	GameManager.player_position = position
	read_input()

	# Atualiza o cooldown do atack
	update_attack_cooldown(delta)
	# Attack
	if Input.is_action_just_released("attack"):
		attack()
	
	# Processar animação e rotação do sprite
	play_run_idle_animation()
	if not is_attacking:
		rotation_sprite()
	
	# Processar dano sofrido
	update_hitbox_detection(delta)
	
	# Ritual
	update_ritual(delta)
	
	# Atualizar health_progress_bar
	health_progress_bar.max_value = max_health
	health_progress_bar.value = health


func update_attack_cooldown(delta: float) -> void:
	# Atualizar o temporizador do attack
	if is_attacking:
		attack_cooldown -= delta
		if attack_cooldown <= 0.0:
			is_attacking = false
			is_runnig = false
			animation_player.play("idle")


func update_ritual(delta: float) -> void:
	ritual_cooldown -= delta
	
	if ritual_cooldown > 0.0:
		return

	ritual_cooldown = ritual_interval
	
	var ritual = ritual_scene.instantiate()
	ritual.demage_amount = ritual_damage
	add_child(ritual)


func play_run_idle_animation() -> void:
	# Tocar a animação
	if not is_attacking:
		if was_running != is_runnig:
			if is_runnig:
				animation_player.play("run")
			else:
				animation_player.play("idle")


func rotation_sprite() -> void:
	# Girar sprite na vertical
	if input_vector.x > 0:
		# Desmarcar flip H sprite2D
		sprite.flip_h = false
	elif input_vector.x < 0:
		# Marcar flip H sprite2D
		sprite.flip_h = true


func read_input() -> void:
	# Obter o input vector
	input_vector = Input.get_vector("move_left", "move_right", "move_up" , "move_down")
	
		# Apagar deadzone do input vector
	var deadzone = 0.15
	if abs(input_vector.x) < deadzone:
		input_vector.x = 0.0
		
	if abs(input_vector.y) < deadzone:
		input_vector.y = 0.0

	# Atualizar animação
	was_running = is_runnig
	is_runnig = not input_vector.is_zero_approx()


func _physics_process(delta: float) -> void:

	# Modificar a velocidade
	var target_velocity = input_vector * speed * 100.0
	if is_attacking:
		target_velocity *= .25
	velocity = lerp(velocity, target_velocity, .05)
	move_and_slide()


func attack() -> void:
	# Não sobrepor animação e attack
	if is_attacking:
		return 
		
	# Attack side 1
	# Attack side 2
	animation_player.play("attack_side_1")
	
	# Configurar temporizador
	attack_cooldown = 0.6
	
	# Marcar atack
	is_attacking = true


func deal_damage_to_enemies() -> void:
	var bodies = sword_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body

			var direction_to_enemy = (enemy.position - position).normalized()
			var attack_direction: Vector2
			if sprite.flip_h:
				attack_direction = Vector2.LEFT
			else:
				attack_direction = Vector2.RIGHT

			var dot_product = direction_to_enemy.dot(attack_direction)
			if dot_product >= 0.5:
				enemy.damage(sword_damage)


func update_hitbox_detection(delta) -> void:
	# Temporizador
	hitbox_cooldown -= delta
	
	if hitbox_cooldown > 0: 
		return 

	#frequencia (2x vez por segundo)
	hitbox_cooldown = 0.5

	# Detectar inimigos
	var bodies = hitbox_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			var damage_amount = 1
			damage(damage_amount)


func damage(amount: int) -> void:
	if health <= 0:
		return
	health -= amount
	
	# Piscar node (mostar que sofreu dano)
	modulate = Color.RED
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	
	if health <= 0:
		die()


func die() -> void:
	GameManager.end_game()
	
	# Criando entidade
	if death_prefab:
		var death_object = death_prefab.instantiate()
		death_object.position = position
		get_parent().add_child(death_object)
	
	print('Player morreu')
	queue_free()


func heal(amount: int) -> int:
	health += amount
	if health > max_health:
		health = max_health
	print('Player curado: ', health)
	return health


