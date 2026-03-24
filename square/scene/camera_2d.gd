extends Camera2D


func _process(delta: float) -> void:
	var stren := Input.get_vector("left", "right", "up", "down")
	position += stren * 300 * delta

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("out") and Input.is_action_just_pressed("out"):
		zoom -= Vector2(0.05, 0.05)
	elif event.is_action("in") and Input.is_action_just_pressed("in"):
		zoom += Vector2(0.05, 0.05)
