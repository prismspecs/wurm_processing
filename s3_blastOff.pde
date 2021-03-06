int doorOpen = 0;
int starCount = 120;
int blastOffTime = 10 * 1000;	// how long does this scene last?

float doorSpeed = 80;

void blastOff() {
	doorSpeed = width/(blastOffTime/1000)/1.25;
	pilot.beginDraw();
	pilot.background(0);

	// do we need to add stars?
	while (stars.size() < starCount) {
		stars.add(new Star());
	}

	// draw the stars
	for (Star s : stars) {
		s.display();
	}

	// continue opening doors if necessary
	if (doorOpen < width / 2) {
		// SHAKE!
		OscMessage m = new OscMessage("/pilot/shake");
		m.add(.1);
		oscP5.send(m, VDMX);

		doorOpen += doorSpeed * deltaTime;
		pilot.rectMode(CORNER);
		pilot.fill(255);
		pilot.noStroke();
		pilot.rect(-4, 0, width / 2 - doorOpen + 4, height);
		pilot.rect(width / 2 + doorOpen, 0, width, height);
	} else {
		OscMessage m = new OscMessage("/pilot/shake");
		m.add(0);
		oscP5.send(m, VDMX);
	}

	if (millis() > lastTime + blastOffTime) {
		scene++;
	}

	pilot.endDraw();
}