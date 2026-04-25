extends CharacterBody2D

@export var speed := 300.0
@export var player_id := 1

func _physics_process(_delta):
	var direction := Vector2.ZERO

	if Input.is_action_pressed("p%d_left" % player_id):
		direction.x -= 1
	if Input.is_action_pressed("p%d_right" % player_id):
		direction.x += 1
	if Input.is_action_pressed("p%d_up" % player_id):
		direction.y -= 1
	if Input.is_action_pressed("p%d_down" % player_id):
		direction.y += 1

	velocity = direction.normalized() * speed
	move_and_slide()
# Replace with function body.
