class Houston {
	//
	SyphonServer syphon;
	PGraphics pg;
	float screenPadding;
	float cellW, cellH;

	// ------ font/text ------
	String topText = "STATUS";
	PFont font_small, font_large;
	float font_large_size, font_small_size;
	float statsAreaX, statsAreaY;
	float statsAreaW, statsAreaH;

	// ------ camera ------
	Capture cam;
	float camW, camH;
	float camRatio = 1.33;	// width / height for camera

	// ------ sliders ------
	// 0: hyperdrive
	// 1: oxygen
	// 2: modulation
	float[] slider = {0, 0, 0};
	color[] sliderColors = {color(255, 0, 255), color(255, 255, 0), color(0, 255, 255)};
	String[] sliderText = {"HYPERDRIVE", "OXYGEN", "MODULATION"};
	float sliderAreaW, sliderAreaH, sliderAreaX, sliderAreaY;
	float sliderH;	// individual slider height
	float sliderPadding;
	float notchH;

	// ------ splitters ------
	float splitterAreaW, splitterAreaH, splitterPadding;
	float splitterAreaX, splitterAreaY;
	// splitters (switches) use "targetSwitches" and "actualSwitches"

	// ------ patcher ------
	float patcherAreaW, patcherAreaH, patcherPadding;
	float patcherAreaX, patcherAreaY;
	float patcherLeftX, patcherRightX;
	int patcherLeftTarget = 0;
	int patcherLeftTouched = 0;
	int patcherRightTarget = 0;
	int patcherRightTouched = 0;
	int[] patcherIntervals = {25, 40, 59, 67, 80, 93, 104, 118, 128, 139, 144, 999};	// last one is junk to protect against nullpointer
	int currInterval = 0;
	float patcherDiameter;
	float patcherSpacing;
	int lastPatcherOSCmessage = 1;	// last thing sent to peter re: patch bay


	Houston(PApplet pApp) {

		// create grid to work by
		int columns = 16;
		cellW = HOUSTON_W / columns;
		cellH = cellW;
		int rows = int(HOUSTON_H / cellH);

		// text
		font_large = loadFont("font100.vlw");
		font_small = loadFont("font40.vlw");
		font_large_size = HOUSTON_W * .07;
		font_small_size = HOUSTON_W * .035;

		// graphics
		syphon = new SyphonServer(pApp, "wurm_houston");
		pg = createGraphics(HOUSTON_W, HOUSTON_H, P3D);
		pg.beginDraw();
		pg.imageMode(CORNER);
		pg.textFont(font_large, font_large_size);
		pg.endDraw();

		// positioning
		//screenPadding = HOUSTON_W * .01;
		// stats
		statsAreaX = cellW * 4;
		statsAreaY = cellH * .5;
		statsAreaW = cellW * 8;
		statsAreaH = cellH * 1;
		// sliders
		sliderAreaW = cellW * 14;
		sliderAreaH = cellH * 3;
		sliderAreaX = cellW * 1;
		sliderAreaY = cellH * 8;
		sliderH = cellH / 2;
		//sliderPadding = sliderH / 2;
		notchH = sliderH * 1.2;
		// splitters
		splitterAreaX = cellW * 1;
		splitterAreaY = cellH * 2;
		splitterAreaW = cellW * 3;
		splitterAreaH = cellH * 5;
		// patcher
		patcherAreaX = cellW * 12;
		patcherAreaY = cellH * 2;
		patcherAreaW = cellW * 3;
		patcherAreaH = cellH * 5;
		patcherDiameter = cellW / 2;
		patcherSpacing = (patcherAreaH / 4) + (patcherDiameter / 4);

		// webcam
		String[] cameras = Capture.list();
		println(cameras);
		cam = new Capture(pApp, cameras[0]);
		cam.start();

		// resized to...
		camH = HOUSTON_H / 2;
		camW = camH * camRatio;
	}

	void update() {
		if (cam.available() == true) {
			cam.read();
		}

		// ------ patch bay ------
		// ERROR EVENT on patcher means select a new pair
		if (currTime > patcherIntervals[currInterval] * 1000) {
			currInterval++;
			// pick a left patcher to activate
			patcherLeftTarget = int(random(4));
			patcherRightTarget = int(random(4));
		}


		// send OSC accordingly
		int currentPatcherState;

		if (targetSwitches.equals(actualSwitches)) {
			currentPatcherState = 1;

		} else {
			currentPatcherState = 0;

		}

		// only send OSC if we need to
		if (currentPatcherState != lastPatcherOSCmessage && OSC) {
			OscMessage myScene = new OscMessage("/base/patcher");
			myScene.add(currentPatcherState);
			oscP5.send(myScene, PETER);
		}
	}

	void display() {
		// show pilot image
		pg.beginDraw();
		pg.background(127);
		//pg.image(cam, 0, HOUSTON_H - camH, camW, camH);
		pg.image(cam, 0, 0, HOUSTON_W, HOUSTON_H);

		// show pilot stats
		// pg.fill(255, 200);
		// pg.rect(statsAreaX, statsAreaY, statsAreaW, statsAreaH);
		pg.textFont(font_large, font_large_size);
		pg.textAlign(CENTER, CENTER);
		pg.fill(255);
		pg.pushMatrix();
		pg.translate(statsAreaX + (statsAreaW / 2), statsAreaY + (statsAreaH / 2), 0);
		String lifeText = "" + int(life / startingLife * 100);
		String timeText = "" + int(wormholeDuration - timeInWormhole) / 1000;
		pg.text("LIFE " + lifeText + "%  " + "ETA " + timeText + "s", 0, 0);
		pg.popMatrix();

		// splitters
		// pg.fill(255, 200);
		// pg.rect(splitterAreaX, splitterAreaY, splitterAreaW, splitterAreaH);
		pg.ellipseMode(CENTER);
		pg.pushMatrix();
		pg.translate(splitterAreaX, splitterAreaY, 0);
		pg.noStroke();
		pg.textAlign(CORNER, CENTER);
		pg.textFont(font_small, font_small_size);
		for (int i = 0; i < 3; i++) {
			pg.fill(255, 127);
			// splitter switch
			pg.ellipse(cellW / 2, i * cellH * 2 + (cellH / 2), cellW - 8, cellH - 8);

			// text for error/okay feedback
			String feedbackText;
			if (targetSwitches.charAt(i) == actualSwitches.charAt(i)) {
				pg.fill(0, 255, 0);
				feedbackText = "GOOD!";
			} else {
				pg.fill(255, 0, 0);
				feedbackText = "ERROR!";
			}

			pg.text(feedbackText, cellW, i * cellH * 2 + (cellH / 2));

			// IF ACTIVE...
			if (actualSwitches.charAt(i) == '1') {
				pg.fill(255, 0, 0);
				pg.ellipse(cellW / 2, i * cellH * 2 + (cellH / 2), cellW / 2, cellH / 2);
			} else {
				pg.noFill();
			}
		}
		pg.popMatrix();

		// ------ patch bay ------

		pg.pushMatrix();
		// pg.fill(255, 200);
		// pg.rect(patcherAreaX, patcherAreaY, patcherAreaW, patcherAreaH);
		pg.translate(patcherAreaX + cellW / 2, patcherAreaY + cellH / 2, 0);

		// store target positions when the time is right
		PVector leftTargetPos = new PVector(0, 0);
		PVector rightTargetPos = new PVector(0, 0);

		for (int i = 0; i < 4; i++) {
			// left side
			pg.fill(255, 127);
			pg.ellipse(0, i * patcherSpacing, patcherDiameter, patcherDiameter);

			// display which patcher is being touched/was touched last
			if (i == patcherLeftTouched) {
				pg.fill(255, 0, 0);
			} else {
				// patcher is OFF
				pg.fill(0);
			}
			// inner circle
			pg.ellipse(0, i * patcherSpacing, patcherDiameter / 2, patcherDiameter / 2);

			// right side
			pg.fill(255, 127);
			pg.ellipse(cellW * 2, i * patcherSpacing, patcherDiameter, patcherDiameter);

			// display which patcher is being touched/was touched last
			if (i == patcherRightTouched) {
				// patcher is ON
				pg.fill(255, 0, 0);
			} else {
				// patcher is OFF
				pg.fill(0);
			}
			pg.ellipse(cellW * 2, i * patcherSpacing, patcherDiameter / 2, patcherDiameter / 2);

			// so where are the target positions?
			if (patcherLeftTarget == i) {
				leftTargetPos.x = 0;
				leftTargetPos.y = i * patcherSpacing;
			}
			if (patcherRightTarget == i) {
				rightTargetPos.x = cellW * 2;
				rightTargetPos.y = i * patcherSpacing;
			}
		}
		// draw what connections SHOULD be made by player (targets)
		pg.stroke(255, 255, 0);
		pg.strokeWeight(4);
		pg.line(leftTargetPos.x, leftTargetPos.y, rightTargetPos.x, rightTargetPos.y);
		pg.popMatrix();


		// ------ sliders h/o/m ------
		// pg.fill(255, 200);
		// pg.rect(sliderAreaX, sliderAreaY, sliderAreaW, sliderAreaH);
		pg.pushMatrix();
		pg.translate(sliderAreaX, sliderAreaY, 0);

		pg.noStroke();
		pg.textFont(font_small, font_small_size);
		pg.textAlign(CORNER, TOP);
		for (int i = 0; i < 3; i++) {
			pg.fill(sliderColors[i]);
			// text
			pg.text(sliderText[i], 0, i * sliderH * 2 + 4);

			// background slider shows where pilot has set values
			float actualX = actual[i] / range;
			pg.rect(0, i * sliderH * 2 + sliderH, sliderAreaW * actualX , sliderH);

			// notch shows where target values are
			float targetX = target[i] / range  * sliderAreaW;
			float xRange = sliderAreaW * .075 * 2;

			if (abs((target[i] - actual[i]) / range) < targetBuffer) {
				// good
				pg.fill(255, 127);
			} else {
				// bad
				pg.fill(255, 0, 0);
			}

			pg.rect(targetX - (xRange / 2), i * sliderH * 2 + sliderH - (notchH - sliderH) / 2, xRange, notchH);
		}
		pg.popMatrix();

		pg.endDraw();

		syphon.sendImage(pg);

	}
}

