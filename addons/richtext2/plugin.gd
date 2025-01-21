@tool
extends EditorPlugin

func _enter_tree() -> void:
	var fh := FontHelper.new()
	var fonts := {}
	fh._scan_for_fonts(fonts, "res://", true)
	ProjectSettings.set("richer_text_label/fonts", fonts)
	ProjectSettings.add_property_info({ "name": "richer_text_label/fonts", "type": TYPE_DICTIONARY })
	
	if not ProjectSettings.has_setting("richer_text_label/colors"):
		ProjectSettings.set("richer_text_label/colors", {})
		ProjectSettings.add_property_info({ "name": "richer_text_label/colors", "type": TYPE_DICTIONARY })

func _exit_tree() -> void:
	pass
