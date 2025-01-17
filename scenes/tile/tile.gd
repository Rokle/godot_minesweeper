extends TextureButton

class_name Tile

signal toggle_flag()
signal reveal()

#region ======================== PUBLIC METHODS ================================

func set_texture(texture: Texture):
	self.texture_normal = texture

#endregion

#region ======================== INPUT METHODS =================================

func _on_button_down() -> void:
	if Input.is_action_just_pressed("left_click"):
		_handle_left_click()
		return
	
	if Input.is_action_just_pressed("right_click"):
		_handle_right_click()
		return

func _handle_left_click() -> void:
	reveal.emit()

func _handle_right_click() -> void:
	toggle_flag.emit()

#endregion
