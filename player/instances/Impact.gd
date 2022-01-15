extends Position3D

onready var light_energy = $OmniLight.light_energy
onready var particles_material = $Particles1.get_material_override()
onready var impact_material = $Impact.get_material_override()

func _ready():
	$Tween.interpolate_property($Impact, "scale", Vector3(0, 0, 0), Vector3(1, 1, 1), 0.15, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.interpolate_property($Impact, "scale", Vector3(1, 1, 1), Vector3(0, 0, 0), 0.15, Tween.TRANS_SINE, Tween.EASE_OUT, 0.15)
	$Tween.interpolate_property(impact_material, "albedo_color", Color(0, 1, 1, 0), Color(0, 1, 1, 1), 0.15, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.interpolate_property(impact_material, "albedo_color", Color(0, 1, 1, 1), Color(0, 1, 1, 0), 0.15, Tween.TRANS_SINE, Tween.EASE_OUT, 0.15)
	
	$Tween.interpolate_property($OmniLight, "translation:z", 0, 1.5, 1, Tween.TRANS_SINE, Tween.EASE_OUT)
	
	$Tween.interpolate_property($OmniLight, "light_energy", 0, light_energy, 0.15, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.interpolate_property($OmniLight, "light_energy", light_energy, 0, 0.15, Tween.TRANS_SINE, Tween.EASE_OUT, 0.15)
	
	$Tween.interpolate_property($OmniLight, "light_indirect_energy", 0, light_energy, 0.15, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.interpolate_property($OmniLight, "light_indirect_energy", light_energy, 0, 0.15, Tween.TRANS_SINE, Tween.EASE_OUT, 0.15)
	
	$Tween.interpolate_property($OmniLight, "omni_range", 0, 2, 0.15, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.interpolate_property($OmniLight, "omni_range", 2, 0, 0.15, Tween.TRANS_SINE, Tween.EASE_OUT, 0.15)
	
	$Tween.interpolate_property(particles_material, "albedo_color", Color(0, 1, 1, 1), Color(0, 1, 1, 0), 1, Tween.TRANS_SINE, Tween.EASE_OUT)
	
	$Tween.start()

func _on_Tween_tween_all_completed():
	queue_free()
