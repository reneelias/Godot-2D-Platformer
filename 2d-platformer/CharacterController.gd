extends CharacterBody2D

var gravityScale := 9.81
var moveSpeed := 5.0

func _physics_process(delta):
    velocity += Vector2(0, gravityScale)

    if Input.is_key_pressed(KEY_A):
        velocity -= Vector2(moveSpeed, 0)
    if Input.is_key_pressed(KEY_D):
        velocity += Vector2(moveSpeed, 0)
        
    move_and_slide()