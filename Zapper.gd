extends Area2D

func _on_Zapper_area_entered(area):
	area.zapped()

func _on_Zapper_body_entered(body):
	body.zapped()
