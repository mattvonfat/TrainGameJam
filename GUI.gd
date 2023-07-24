extends CanvasLayer

func set_player(ref):
	ref.connect("health_update", self, "update_player_health")
	$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/TextureProgress.max_value = ref.MAX_HEALTH
	$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/TextureProgress.value = ref.MAX_HEALTH

func hide_player():
	$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/TextureProgress.hide()
	$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/Label.hide()

func set_companion(ref):
	ref.connect("health_update", self, "update_companion_health")
	$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/TextureProgress2.max_value = ref.max_health
	$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/TextureProgress2.value = ref.max_health

func update_player_health(new_health):
	$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/TextureProgress.value = new_health

func update_companion_health(new_health):
	$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/TextureProgress2.value = new_health
