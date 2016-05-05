int whichDiff = 0;

void commTest() {
	pilot.beginDraw();
	pilot.background(0);
	pilot.textFont(font_large, font_large_size);
	pilot.textAlign(CENTER);
	pilot.fill(255, 0, 0);
	pilot.text("BASE COMMAND IS TESTING COMMS", width / 2, height / 2 - font_large_size);
	pilot.text("GIVE A THUMBS UP", width / 2, height / 2);
	pilot.text("WHEN THE CHANNEL SOUNDS CLEAN", width / 2, height / 2 + font_large_size);
	pilot.endDraw();
}