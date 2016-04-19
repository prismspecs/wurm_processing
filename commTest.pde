int whichDiff = 0;

void commTest() {
	pg.beginDraw();
	pg.background(0);
	pg.textFont(font, FONT_SIZE);
	pg.textAlign(CENTER);
	pg.fill(255, 0, 0);
	pg.text("BASE COMMAND IS TESTING COMMS", width / 2, height / 2 - FONT_SIZE);
	pg.text("GIVE A THUMBS UP", width / 2, height / 2);
	pg.text("WHEN THE CHANNEL SOUNDS CLEAN", width / 2, height / 2 + FONT_SIZE);
	pg.endDraw();
/*
	// draw difficulty picker
	pg.imageMode(CENTER);
	// use hyperdrive as selector
	//whichDiff = int(map(actual[0],0,range,0,2));
	whichDiff = constrain(whichDiff, 0, 2);
	pg.image(diffImg[whichDiff], width / 2, height / 1.4);

	pg.endDraw();

	switch (whichDiff) {
		case 0:
			startingLife = 10000;	// easy
			break;
		case 1:
			startingLife = 8000;	// medium
			break;
		case 2:
			startingLife = 5000;	// hard
			break;
	}
	*/
}