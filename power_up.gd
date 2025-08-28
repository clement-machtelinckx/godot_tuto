extends Area2D
@export var lifetime_sec: float = 10.0

func _ready() -> void:
	# Détecte l'entrée d'une Area2D (le Player est une Area2D)
	area_entered.connect(_on_area_entered)
	# Auto-despawn après X sec (sans Timer node si tu veux)
	despawn_later()

func despawn_later() -> void:
	await get_tree().create_timer(lifetime_sec).timeout
	if is_inside_tree():
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		# Le player a la méthode burst() qu'on a ajoutée à l'étape 2
		area.burst()
		queue_free()
