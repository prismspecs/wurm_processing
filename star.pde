class Star {
	PVector pos;
	float s;	// size
	float p;	// phase
	float pSpeed;	// phase speed
	float shift;	// size shift
	color c;	// color

	Star() {
		pos = new PVector(random(-width / 3, width + width / 3), random(-height / 3, height + height / 3), -100);

		p = random(PI);	// start at random phase in sin wave

		c = color(random(200, 255), random(200, 255), random(200, 255));

		s = 1;

		pSpeed = random(.005, .02);
	}

	void display() {
		p += pSpeed;	// increase phase
		shift = sin(p) * 4;	// pulsate star

		// draw star
		pg.pushMatrix();
		pg.translate(pos.x, pos.y, pos.z);

		// corona
		pg.noFill();
		pg.stroke(c);
		pg.strokeWeight(1);
		pg.ellipse(0, 0, s + shift * 2, s + shift * 2);

		pg.fill(c);
		pg.ellipse(0, 0, s + shift, s + shift);
		
		pg.popMatrix();
	}
}