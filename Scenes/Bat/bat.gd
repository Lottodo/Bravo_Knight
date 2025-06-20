extends BaseEnemy

var direction: Vector2 = Vector2.RIGHT
var initial_pos: Vector2
var previous_state: ENEMY_STATES

func _ready(): 
	super._ready()
	current_state = ENEMY_STATES.PATROL
	initial_pos = global_position
	hp = 2

func _physics_process(delta: float) -> void:
	match current_state: 
		ENEMY_STATES.RETURNING:
			nav_agent.target_position = initial_pos
			direction = to_local(nav_agent.get_next_path_position()).normalized()
			if nav_agent.is_navigation_finished():
				direction = Vector2.RIGHT
				current_state = ENEMY_STATES.PATROL
		ENEMY_STATES.PATROL:
			if patrol_timer.is_stopped():
				patrol_timer.start()
		ENEMY_STATES.FOLLOWING_PLAYER:
			if not patrol_timer.is_stopped():
				patrol_timer.stop()
			nav_agent.target_position = player_ref.global_position
			direction = to_local(nav_agent.get_next_path_position()).normalized()
	
	velocity = direction * movement_speed * delta
	
	if velocity.x > 0:
		anim_sprite2d.flip_h = false 
	else:
		anim_sprite2d.flip_h = true
	
	move_and_slide()

func _on_patrol_timeout() -> void:
	direction *= -1
	
func _on_detection_area_entered(area: Area2D) -> void:
	current_state = ENEMY_STATES.FOLLOWING_PLAYER
	print("Current enemy state:  Following-", current_state)
	
func _on_detection_area_exited(area: Area2D) -> void:
	print("Current enemy state: Patrol-", current_state)
	
func _on_hit_box_area_entered(area: Area2D) -> void:
	hp-= player_ref.strength
	hitbox.monitoring = false
	if hp <= 0:
		current_state = ENEMY_STATES.DEATH
		anim_sprite2d.play("Death")
		velocity = Vector2.ZERO
		hitbox.monitorable = false
	else:
		previous_state = current_state
		current_state = ENEMY_STATES.HIT
		direction *= -1
		var tween = create_tween()
		invicible_timer.start()
		tween.tween_property(anim_sprite2d,"self_modulate", Color(1,0,0),0.25)
		tween.tween_property(anim_sprite2d,"self_modulate", Color(1,1,1),0.25)
		tween.tween_property(anim_sprite2d,"self_modulate", Color(1,0,0),0.25)
		tween.tween_property(anim_sprite2d,"self_modulate", Color(1,1,1),0.25)
	
func _on_invincible_timer_timeout() -> void:
	current_state = ENEMY_STATES.FOLLOWING_PLAYER
	hitbox.monitoring = true

func _on_animation_finished() -> void:
	if anim_sprite2d.animation == "Death":
		queue_free()
