extends Node

@export var mob_scene: PackedScene
@export var powerup_scene: PackedScene
var score: int = 0

func _ready():
	# Connexions possibles par code (sinon fais-le via l’éditeur) :
	$Player.hit.connect(game_over)
	# $StartTimer.timeout.connect(_on_start_timer_timeout)
	# $ScoreTimer.timeout.connect(_on_score_timer_timeout)
	# $MobTimer.timeout.connect(_on_mob_timer_timeout)

	# new_game()
	pass

func _on_mob_timer_timeout() -> void:
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instantiate()

	# Choose a random location on Path2D.
	var mob_spawn_location = $MobPath/MobSpawnLocation
	mob_spawn_location.progress_ratio = randf()

	# Set the mob's position to the random location.
	mob.position = mob_spawn_location.position

	# Set the mob's direction perpendicular to the path direction.
	var direction = mob_spawn_location.rotation + PI / 2

	# Add some randomness to the direction.
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction

	# Choose the velocity for the mob.
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)


func _on_score_timer_timeout() -> void:
	score += 1
	$HUD.update_score(score)


func _on_start_timer_timeout() -> void:
	$MobTimer.start()
	$ScoreTimer.start()

func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()
	$Music.stop()
	$DeathSound.play()
	
func new_game():
	score = 0
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")
	$Player.start($StartPosition.position)
	$StartTimer.start()
	get_tree().call_group("mobs", "queue_free")
	$Music.play()
	$PowerUpTimer.start() # <--- démarre le spawn de powerups



func _on_power_up_timer_timeout() -> void:
	var p: Node2D = powerup_scene.instantiate()
	# Spawn dans la zone visible
	var rect := get_viewport().get_visible_rect()
	var margin := 24.0
	var x := randf_range(rect.position.x + margin, rect.end.x - margin)
	var y := randf_range(rect.position.y + margin, rect.end.y - margin)
	p.global_position = Vector2(x, y)
	add_child(p)
