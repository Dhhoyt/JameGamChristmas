extends StaticBody

var playing = false

func play():
	$AudioStreamPlayer3D.play()
	playing = true
	
func stop():
	$AudioStreamPlayer3D.stop()
	playing = false

func remind_krampus(krampus):
	if playing:
		krampus.noise(self.global_transform.origin, 100000, 2)
