extends CharacterBody2D

@export var gravity: float
@export var max_bounces: int

@onready var _area: Area2D = $Area2D
@onready var _sprite: Sprite2D = $Sprite2D
@onready var _anim: AnimationPlayer = $AnimationPlayer

var _bounces: int = 0


func _ready():
	_sprite.frame = randi() % 4
	_anim.play("roll")

func _physics_process(delta: float) -> void:
	if abs(velocity.x) <= 0.1:
		_sprite.flip_h = false
		_anim.speed_scale = 1.0
	else:
		_sprite.flip_h = sign(velocity.x) < 0.0
		_anim.speed_scale = sign(velocity.x)
	
	# Move
	var old_velocity := velocity
	velocity.y += gravity * delta
	move_and_slide()
	
	# We need to keep track of the velocity before move_and_slide() because
	# on a collision, the component that should get bounced will be zero.
	
	# Bounce
	var bounced := false
	if is_on_floor() or is_on_ceiling():
		bounced = true
		velocity.y = -old_velocity.y
	if is_on_wall():
		bounced = true
		velocity.x = -old_velocity.x
	
	# Explode through bouncing
	if bounced:
		_bounces += 1
		if _bounces == max_bounces:
			_explode(null)
	
	# Explode through contact
	for body in _area.get_overlapping_bodies():
		if (
			body != self
			and not is_queued_for_deletion()
		):
			if (
				(body is Player and _bounces >= 1)
				or not body is Player
			):
				_explode(null)


func _explode(_explosion: Explosion) -> void:
	Globals.spawn_explosion_at(position)
	queue_free()
