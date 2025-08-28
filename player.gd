extends Area2D

signal hit

@export var speed = 400 # How fast the player will move (pixels/sec).
@export var bullet_scene: PackedScene
@export var fire_rate: float = 8.0  # balles par seconde
var _can_shoot := true
var screen_size # Size of the game window.

func _ready():
	screen_size = get_viewport_rect().size
	# cooldown basé sur fire_rate
	$ShootCooldown.wait_time = 1.0 / fire_rate
	$ShootCooldown.timeout.connect(func():_can_shoot = true)

func _process(delta):
	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()

	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	
	if velocity.x < 0:
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false
		
	# Tir
	if Input.is_action_just_pressed("shoot"):
		_try_shoot()


func _on_body_entered(_body):
	hide() # Player disappears after being hit.
	hit.emit()
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false


func _try_shoot() -> void:
	if not _can_shoot:
		return
	_can_shoot = false
	$ShootCooldown.start()

	var bullet := bullet_scene.instantiate()
	# Direction = vers la souris (simple et fun)
	var dir := (get_global_mouse_position() - global_position)
	if dir == Vector2.ZERO:
		dir = Vector2.RIGHT  # fallback
	
	
	var from := global_position
	bullet.start(from, dir)
	get_tree().current_scene.add_child(bullet)
