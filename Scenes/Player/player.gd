extends CharacterBody2D

class_name Player

@onready var anim_sprite2d = $AnimatedSprite2D
@onready var floor_detector = $FloorDetector
@onready var attack_area: Area2D = $AttackHitbox
@onready var attack_collision: CollisionShape2D = $%CollisionHitbox
@onready var invincible_timer = $InvincibleTimer

enum PLAYER_STATE {IDLE, RUN, ATTACK, JUMP, HIT, FALL, DEATH}

@export var movement_speed = 1500.0
@export var jump_speed = 15000.0
@export var gravity = 300.0
var current_state : PLAYER_STATE = PLAYER_STATE.IDLE
var is_grounded = false
var is_attacking = false
var direction: Vector2 
var hit_speed: float = 100.0

var strength : int = 1 

func _ready():
	attack_area.visible = false
	attack_area.monitorable = false
	attack_area.monitoring = false

func _physics_process(delta: float) -> void:
	get_input(delta)
	if(not is_attacking):
		if(current_state != PLAYER_STATE.HIT):
			calculate_state()
		else: 
			velocity = direction * hit_speed * delta
	check_is_on_ground()
	apply_gravity(delta)
	move_and_slide()

func check_is_on_ground():
	if floor_detector.is_colliding():
		is_grounded = true
	else:
		is_grounded = false

func apply_gravity(delta): 
	velocity.y += gravity * delta

func calculate_state():
	if(is_grounded):
		if abs(velocity.x) > 0:
			set_state(PLAYER_STATE.RUN)
		else: 
			set_state(PLAYER_STATE.IDLE)
	else: 
		if velocity.y > 0: 
			set_state(PLAYER_STATE.FALL)
		else:
			set_state(PLAYER_STATE.JUMP)

func set_state(new_state: PLAYER_STATE):
	if(new_state != current_state):
		current_state = new_state
		match current_state:
			PLAYER_STATE.RUN:
				print("Running")
				anim_sprite2d.play("Run")
			PLAYER_STATE.IDLE: 
				print("Idle")
				anim_sprite2d.play("Idle")
			PLAYER_STATE.FALL:
				anim_sprite2d.play("Fall")
			PLAYER_STATE.JUMP:
				anim_sprite2d.play("Jump")
			PLAYER_STATE.ATTACK:
				anim_sprite2d.play("Attack")
			PLAYER_STATE.HIT:
				anim_sprite2d.play("Hit")

func flip_player():
	anim_sprite2d.flip_h = not anim_sprite2d.flip_h
	attack_collision.position.x *= -1

func get_input(delta): 
	if current_state == PLAYER_STATE.HIT:
		return
	if(Input.is_action_pressed("move_left")):
		velocity.x = -movement_speed * delta
		if not anim_sprite2d.flip_h:
			flip_player()
	elif(Input.is_action_pressed("move_right")):
		velocity.x = movement_speed * delta
		if anim_sprite2d.flip_h:
			flip_player()
	else:
		velocity.x = 0 
	
	if(Input.is_action_just_pressed("jump") and is_grounded):
		velocity.y = -jump_speed * delta
		
	if(Input.is_action_just_pressed("attack")and not is_attacking):
		attack()

func attack():
	is_attacking = true
	set_state(PLAYER_STATE.ATTACK)
	attack_area.monitorable = true
	attack_area.monitoring = true 
	attack_area.visible = true 
		
func _on_animated_sprite_2d_animation_finished() -> void:
	if(anim_sprite2d.animation == "Attack"):
		reset_states()

func _on_hit_box_area_entered(area: Area2D) -> void:
	direction = area.get_parent().velocity
	set_state(PLAYER_STATE.HIT)
	invincible_timer.start()
	var tween = create_tween()
	tween.tween_property(anim_sprite2d,"self_modulate", Color(1,1,1,0),0.25)
	tween.tween_property(anim_sprite2d,"self_modulate", Color(1,1,1,1),0.25)
	tween.tween_property(anim_sprite2d,"self_modulate", Color(1,1,1,0),0.25)
	tween.tween_property(anim_sprite2d,"self_modulate", Color(1,1,1,1),0.25)
	tween.tween_property(anim_sprite2d,"self_modulate", Color(1,1,1,0),0.25)
	tween.tween_property(anim_sprite2d,"self_modulate", Color(1,1,1,1),0.25)

func reset_states():
	set_state(PLAYER_STATE.IDLE)
	is_attacking = false 
	attack_area.visible = false
	attack_area.monitorable = false
	attack_area.monitoring = false 

func _on_invincible_timer_timeout() -> void:
	reset_states()
