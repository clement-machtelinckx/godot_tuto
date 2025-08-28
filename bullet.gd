extends Area2D

@export var speed: float = 700.0
@export var orientation_offset_deg: float = 0.0
var velocity: Vector2 = Vector2.ZERO

func _ready() -> void:
	# Nettoyer la balle si elle sort de l'écran
	$VisibleOnScreenNotifier2D.screen_exited.connect(queue_free)
	# Détection de collision avec les corps (mobs = RigidBody2D)
	body_entered.connect(_on_body_entered)

func start(from: Vector2, dir: Vector2) -> void:
	global_position = from
	velocity = dir.normalized() * speed
	rotation = velocity.angle() + deg_to_rad(orientation_offset_deg)

func _process(delta: float) -> void:
	position += velocity * delta

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("mobs"):
		body.queue_free()   # tue le mob
		queue_free()        # détruit la balle
