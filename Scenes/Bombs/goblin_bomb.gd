extends RigidBody2D

@onready var anim_sprite2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $HitBox

func _ready():
	hitbox.scale = Vector2.ZERO

func _on_timer_timeout() -> void:
	rotation = 0
	linear_velocity = Vector2.ZERO
	physics_material_override.friction = 0
	hitbox.scale = Vector2.ONE
	await get_tree().process_frame
	anim_sprite2d.play("bomb_attack")

func _on_animated_sprite_2d_animation_finished() -> void:
	if (anim_sprite2d.animation == "bomb_attack"):
		queue_free()
