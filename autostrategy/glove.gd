extends Sprite2D

func _ready() -> void:
	visible = false

func pat() -> void:
	position = Vector2(0, -30)
	visible = true
	var target = Vector2(0,-5)
	var tween = create_tween()
	tween.tween_property(self, "position", target, 0.4).set_trans(Tween.TRANS_SINE)
	await tween.finished
	visible = false
