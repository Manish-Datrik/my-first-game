extends Node3D


@export var speed = 150.0
var player = null
var is_chasing = false
var velocity = null

func _physics_process(_delta):
	if is_chasing and player:
		# Move toward player
		var direction = position.direction_to(player.global_position)
		velocity = direction * speed
		
		# Optional: Flip sprite to face player
		$AnimatedSprite2D.flip_h = velocity.x < 0
	else:
		velocity = Vector2.ZERO
	move_toward(100,200,10000)
# Signal from Area2D (Vision Zone)
func _on_vision_body_entered(body):
	if body.is_in_group("player"): # Ensure your player is in this group
		player = body
		is_chasing = true

func _on_vision_body_exited(body):
	if body == player:
		player = null
		is_chasing = false
