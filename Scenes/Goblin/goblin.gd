extends BaseEnemy

var direction: Vector2 = Vector2.RIGHT
var initial_pos: Vector2
var previous_state: ENEMY_STATES
var gravity = 20000.0
var player_space = 150
@onready var anim_sprited2d = $AnimatedSprite2D

func _ready(): 
	super._ready()
	current_state = ENEMY_STATES.PATROL
	initial_pos = global_position
	hp = 5
	movement_speed = 5000

func _physics_process(delta: float) -> void:
	velocity = direction * movement_speed * delta
	
	match current_state:
		ENEMY_STATES.PATROL:
			movement_speed = 5000
			anim_sprite2d.play("idle") #play the idle animation
			if patrol_timer.is_stopped():
				patrol_timer.start()
		ENEMY_STATES.FOLLOWING_PLAYER: #Attack
			anim_sprite2d.play("attack") #play the attack animation
			if not patrol_timer.is_stopped():
				patrol_timer.stop()
			nav_agent.target_position = player_ref.global_position
			direction = to_local(nav_agent.get_next_path_position()).normalized()
			var to_player = player_ref.global_position - global_position
			var distance = to_player.length()
			if distance > 250:
				pass
			elif distance < 220:
				velocity *= -3
			else:
				velocity.x = 0
		ENEMY_STATES.HIT:
			print("Goblin golpeado")
		ENEMY_STATES.DEATH:
			hitbox.monitorable = false
			print("Goblin muerto")
	
	if velocity.x > 0:
		anim_sprite2d.flip_h = false 
	else:
		anim_sprite2d.flip_h = true
	apply_gravity(delta)
	move_and_slide()

func _on_player_area_entered(area: Area2D) -> void:
	current_state = ENEMY_STATES.FOLLOWING_PLAYER

func _on_patrol_timer_timeout() -> void: #this make
	direction *= -1

func _on_detection_area_exited(area: Area2D) -> void:
	current_state = ENEMY_STATES.PATROL

func _on_hit_box_sword_entered(area: Area2D) -> void:
	hp -= player_ref.strength
	call_deferred("make_invencible")
	if hp <= 0:
		current_state = ENEMY_STATES.DEATH
		anim_sprite2d.play("death")
		velocity = Vector2.ZERO
	else:
		print("hola")
		previous_state = current_state
		current_state = ENEMY_STATES.HIT
		direction *= -1
		var tween = create_tween()
		invicible_timer.start()
		tween.tween_property(anim_sprite2d,"self_modulate", Color(1,0,0),0.25)
		tween.tween_property(anim_sprite2d,"self_modulate", Color(1,1,1),0.25)
		tween.tween_property(anim_sprite2d,"self_modulate", Color(1,0,0),0.25)
		tween.tween_property(anim_sprite2d,"self_modulate", Color(1,1,1),0.25)
		current_state = previous_state

func _on_animated_sprite_2d_animation_finished() -> void:
	if anim_sprite2d.animation == "death":
		queue_free()

func apply_gravity(delta): 
	velocity.y += gravity * delta


func _on_invincible_timer_timeout() -> void:
	hitbox.monitoring = true

func make_invencible():
	hitbox.monitoring = false
