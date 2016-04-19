int endgameTime = 25 * 1000;	// how long does this scene last?

void victory() {

	if (millis() > lastTime + endgameTime) {
		scene = 0;
	}

	pg.beginDraw();
	pg.background(0, 255);
	doText("YOU SURVIVED THE WORMHOLE\nAND MADE IT TO\nTHE OTHER SIDE", textColor);
	pg.endDraw();
}

void defeat() {

	if (millis() > lastTime + endgameTime) {
		scene = 0;
	}

	pg.beginDraw();
	pg.background(0, 255);
	doText("YOUR WURM WAS DESTROYED\n(AND SO WERE YOU)", textColor);
	pg.endDraw();
}

// ka-boom
void selfDestruct() {
	if (millis() > lastTime + endgameTime) {
		scene = 0;
	}

	pg.beginDraw();
	pg.background(0, 255);
	doText("YOU BLEW YOURSELF UP\nFOR SOME REASON", textColor);
	pg.endDraw();
}