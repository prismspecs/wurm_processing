int emergencyTime = 5 * 1000;

void emergency() {
	pg.beginDraw();
	pg.background(0);

	// there are stars from last scene, animate those suckers
	for (Star s : stars) {
		s.display();
	}

	pg.endDraw();

	strobe = true;
	strobeTrans = 127;
	strobeColor = color(255, 0, 0);

	// advance scene...
	if (millis() > lastTime + emergencyTime) {
		scene++;
	}
}