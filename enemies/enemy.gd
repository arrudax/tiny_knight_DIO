class_name Enemy
extends Node2D

@export_category("Life")
@export var health: int = 10
@export var death_prefab: PackedScene
var demage_digit_prefab: PackedScene

@onready var demage_digit_marker = $DemageDigitMarker

@export_category("Drops")
@export var drop_chance: float = 0.1
@export var drop_items: Array[PackedScene]
@export var drop_chances: Array[float] 


func _ready() -> void:
	demage_digit_prefab = preload("res://misc/demage_digit.tscn")


func damage(amount: int) -> void:
	health -= amount
	
	# Piscar node (mostar que sofreu dano)
	modulate = Color.RED
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)

	#  Criar o Demage Digit
	var demage_digit = demage_digit_prefab.instantiate()
	demage_digit.value = amount
	if demage_digit_marker:
		demage_digit.global_position = demage_digit_marker.global_position
	else:
		demage_digit.global_position = global_position
	
	get_parent().add_child(demage_digit)
	
	if health <= 0:
		die()

func die() -> void:
	# Criando entidade da caveira
	if death_prefab:
		var death_object = death_prefab.instantiate()
		death_object.position = position
		get_parent().add_child(death_object)
		
	if randf() <= drop_chance:
		drop_item()
		
	# Incrementar contador
	GameManager.monsters_defeated_count += 1
	
	# Deletar node
	queue_free()

func drop_item() ->void:
	var drop = get_random_drop_item().instantiate()
	drop.position = position
	
	get_parent().add_child(drop)


func get_random_drop_item() -> PackedScene:
	# listas com 1 item 
	if drop_items.size() == 1:
		return drop_items[0]

	# Calcular chance maxima
	var max_chance: float = 0.0
	for drop_chance in drop_chances:
		max_chance += drop_chance
		
	var rand_value = randf() * max_chance
	
	var needle: float = 0.0
	for i in drop_items.size():
		var drop_item = drop_items[i]
		var drop_chance = drop_chances[i] if i < drop_chances.size() else 1
		if rand_value <= drop_chance + needle:
			return drop_item
		needle += drop_chance

	return drop_items[0]
