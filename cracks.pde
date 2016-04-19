int cOff = 1;	// offset for layering crack shadows
float lastCrackX = SPACE_W/2;
float lastCrackY = SPACE_H/2;
int crackLen = 50;	// maximum crack length

class Crack {
	float x1, x2, y1, y2;

	Crack() {
		x1 = lastCrackX;
		y1 = lastCrackY;
		x2 = lastCrackX += random(-crackLen, crackLen);
		y2 = lastCrackY += random(-crackLen, crackLen);

		lastCrackX = x2;
		lastCrackY = y2;

	}

	void display() {
		pgD.strokeWeight(2);
		pgD.stroke(255);
		pgD.line(x1, y1, x2, y2);
	}
}