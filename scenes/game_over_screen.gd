extends CanvasLayer
signal restart

func _on_restart_button_pressed():
	emit_signal("restart")


func _on_main_end_state(winner):
	match winner:
		0:
			$WinnerLabel.text = "The game is a draw"
		-1:
			$WinnerLabel.text = "Cross wins!"
		1:
			$WinnerLabel.text = "Circle wins!"
		
