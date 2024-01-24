class_name CursorManager extends Node

@export var speaker : AudioStreamPlayer2D
@export var cursor_point : CompressedTexture2D
@export var cursor_hover : CompressedTexture2D
@export var cursor_invalid : CompressedTexture2D
var cursor_visible = false

func _ready():
	SetCursor(false, false)

func SetCursor(isVisible : bool, playSound : bool):
	if (playSound):
		speaker.play()
	if (isVisible):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		cursor_visible = true
	if (!isVisible):
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		cursor_visible = false

func SetCursorImage(alias : String):
	match(alias):
		"point": Input.set_custom_mouse_cursor(cursor_point, 0, Vector2(12, 0))
		"hover": Input.set_custom_mouse_cursor(cursor_hover, 0, Vector2(9, 0))
		"invalid": Input.set_custom_mouse_cursor(cursor_invalid, 0, Vector2(12, 0))
	pass
