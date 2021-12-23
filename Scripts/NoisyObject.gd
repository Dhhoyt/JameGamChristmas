extends StaticBody

var playing = false

func remind_krampus(krampus):
	if playing:
		krampus.noise(self.global_transform.origin, 100000, 2)
