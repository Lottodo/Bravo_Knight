extends CharacterBody2D

class_name BaseEnemy

enum ENEMY_STATES {PATROL = 1, FOLLOWING_PLAYER, RETURNING, HIT, DEATH}

@export var hp: int  = 10
@export var damage: int = 1
@export var movement_speed: int = 1000.0

@onready var anim_sprite2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea
@onready var hitbox: Area2D = $HitBox
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var patrol_timer: Timer = $PatrolTimer
@onready var player_ref: Player
@onready var invicible_timer : Timer = $InvincibleTimer

var current_state: ENEMY_STATES = ENEMY_STATES.PATROL:
	get:
		return current_state
	set(new_state): 
		if current_state != new_state:
			current_state = new_state

func _ready(): 
	player_ref = get_tree().get_nodes_in_group("player")[0]
