float vertSpacing;
float sliderW, sliderThick;
float beginX, endX;
int hudFontSize;
float hudTextBuffer;

float targetWidth, targetHeight;

int hudSwitchSize;
float hudSwitchSpacing;

color sliderColor, hudFontColor, hudTargetColor, hudActualColor, hudOffColor, hudSwitchFill;

void setupHUD() {
	// gather measurements for HUD
	vertSpacing = height / 5;	// spacing between rows
	sliderW = width * .5;	// width of rows
	sliderThick = 4;

	// where do rows begin and end on X?
	beginX = (width / 2) - (sliderW / 2);
	endX = (width / 2) + (sliderW / 2);

	// target stuff
	targetHeight = 20;
	targetWidth = sliderW * targetBuffer * 2;

	// switch stuff
	hudSwitchSize = 30;
	hudSwitchSpacing = sliderW / 2 - (hudSwitchSize * 1.75) ;

	// colors
	sliderColor = color(255);
	hudFontColor = color(255, 255, 0);
	hudOffColor = color(127);
	hudTargetColor = color(0, 255, 255);
	hudActualColor = color(255, 255, 0);
	hudSwitchFill = color(255);

	// font
	hudTextBuffer = font_small_size + 4;
}

void gearTest() {

	diagnostics.beginDraw();
	diagnostics.background(0);

	// draw pilot HUD

	// text
	diagnostics.textFont(font_small, font_small_size);
	diagnostics.fill(hudFontColor);
	diagnostics.textAlign(LEFT);
	diagnostics.text("HYPERDRIVE POWER", beginX, vertSpacing * 1 - hudTextBuffer);
	diagnostics.text("OXYGEN FLOW", beginX, vertSpacing * 2 - hudTextBuffer);
	diagnostics.text("GRAVITY MODULATION", beginX, vertSpacing * 3 - hudTextBuffer);
	diagnostics.text("PARTICLE SPLITTER", beginX, vertSpacing * 4 - hudTextBuffer);

	// straight lines across for hyperdrive,o2,modulation
	diagnostics.fill(sliderColor);
	diagnostics.strokeWeight(sliderThick);
	diagnostics.line(beginX, vertSpacing * 1, endX, vertSpacing * 1);
	diagnostics.line(beginX, vertSpacing * 2, endX, vertSpacing * 2);
	diagnostics.line(beginX, vertSpacing * 3, endX, vertSpacing * 3);

	// targets for hyp, oxy, mod
	diagnostics.noStroke();
	diagnostics.rectMode(CENTER);
	for (int i = 0; i < 3; i++) {
		// if pilot is close enough to correct value, color change
		if (abs((target[i] - actual[i])) / range < targetBuffer) {
			diagnostics.fill(hudTargetColor);
		} else {
			diagnostics.fill(hudOffColor);
		}
		diagnostics.rect(map(target[i], 0, range, beginX, endX), vertSpacing * (i + 1), targetWidth, targetHeight);
	}

	// actuals
	diagnostics.strokeWeight(sliderThick);
	diagnostics.stroke(hudActualColor);
	for (int i = 0; i < 3; i++) {
		float x = map(actual[i], 0, range, beginX, endX);
		diagnostics.line(x, vertSpacing * (i + 1) - targetHeight / 2, x, vertSpacing * (i + 1) + targetHeight / 2);
	}

	// switch boxes
	diagnostics.rectMode(CENTER);
	float y = vertSpacing * 4;
	for (int i = 0; i < 3; i++) {
		float x = beginX + (i * hudSwitchSpacing);

		diagnostics.stroke(hudFontColor);
		diagnostics.strokeWeight(sliderThick);
		diagnostics.noFill();
		diagnostics.rect(x + hudSwitchSize / 2, y, hudSwitchSize, hudSwitchSize);

		// draw actual
		if (actualSwitches.charAt(i) == '1' ) {
			diagnostics.fill(hudSwitchFill);
			diagnostics.noStroke();
			diagnostics.rect(x + hudSwitchSize / 2, y, hudSwitchSize / 2, hudSwitchSize / 2);
		}

		// draw positive/negative feedback for switch correctness
		diagnostics.textAlign(LEFT);
		if (actualSwitches.charAt(i) == targetSwitches.charAt(i)) {
			// yep
			diagnostics.fill(0, 255, 0);
			diagnostics.text("Ok", x + hudSwitchSize * 1.5, y + hudFontSize / 4);
		} else {
			diagnostics.fill(255, 0, 0);
			diagnostics.text("Error!", x + hudSwitchSize * 1.5, y + hudFontSize / 4);
		}
	}

	diagnostics.endDraw();

	// send affirmatives
	for (int i = 0; i < 4; i++) {
		if (!eventReady[i]) {
			// for any event/resource that ISNT ready, check it agin
			if (i == 3) {	// switches?
				if (targetSwitches.equals(actualSwitches)) {
					eventReady[i] = true;
					// play affirmative sound, etc.
					if (OSC) {
						OscMessage m = new OscMessage("/pilot/affirmative");
						m.add(i);
						oscP5.send(m, PETER);
						println("affirmative switch");
					}
				}
			} else {	// analogs?
				if (abs((target[i] - actual[i]) / range) < targetBuffer) {
					eventReady[i] = true;
					// play affirmative sound, etc.
					if (OSC) {
						OscMessage m = new OscMessage("/pilot/affirmative");
						m.add(i);
						oscP5.send(m, PETER);
						println("affirmative analog/ " + millis());
					}
				}
			}
		}
		// reset if pilot screws up controls
		if (eventReady[i]) {
			if (i == 3) {	// switches?
				if (!targetSwitches.equals(actualSwitches)) {
					eventReady[i] = false;
				}
			} else {		// analogs?
				if (abs((target[i] - actual[i]) / range) > targetBuffer) {
					eventReady[i] = false;
				}
			}
		}
	}

	if (OSC)
		sendAll();

	drawHP(false);
}

void drawHP(boolean doErase) {
	diagnostics.beginDraw();

	diagnostics.strokeWeight(sliderThick);
	
	if (doErase)
		diagnostics.background(0);
	diagnostics.textFont(font_small, font_small_size);
	diagnostics.textAlign(CENTER);
	diagnostics.fill(255, 0, 0);
	// nfs(life / startingLife * 100, 1, 2) draws two decimals
	diagnostics.text("HULL STRENGTH: " + int(life / startingLife * 100) + "%", width / 2 + 2, height - 50 + 2);
	diagnostics.fill(255);
	diagnostics.text("HULL STRENGTH: " + int(life / startingLife * 100) + "%", width / 2, height - 50);

	// draw timeline thing
	if (scene == 5) {
		diagnostics.stroke(180);
		diagnostics.line(100, 50, width - 100, 50);
		float shipX = map(timeInWormhole, 0, wormholeDuration, 100, width - 100);
		diagnostics.stroke(255, 255, 0);
		diagnostics.line(shipX, 40, shipX, 60);
	}

	// write affirmative messages to screen here
	diagnostics.textFont(font_small, font_small_size);
	diagnostics.textAlign(CENTER);
	diagnostics.rectMode(CENTER);
	diagnostics.stroke(255);
	if (affirm[0] && millis() - affirmTimer[0] < affirmDuration) {
		// hyperdrive good
		diagnostics.fill(0);
		diagnostics.rect(width / 2, height / 5 - hudFontSize / 2, width / 2, hudFontSize * 2);
		diagnostics.fill(255, 255, 0);
		diagnostics.text("HYPERDRIVE - OK!", width / 2, height / 5);
	}
	if (affirm[1] && millis() - affirmTimer[1] < affirmDuration) {
		// oxygen good
		diagnostics.fill(0);
		diagnostics.rect(width / 2, height / 5 * 2 - hudFontSize / 2, width / 2, hudFontSize * 2);
		diagnostics.fill(255, 255, 0);
		diagnostics.text("OXYGEN - OK!", width / 2, height / 5 * 2);
	}
	if (affirm[2] && millis() - affirmTimer[2] < affirmDuration) {
		// modulation good
		diagnostics.fill(0);
		diagnostics.rect(width / 2, height / 5 * 3 - hudFontSize / 2, width / 2, hudFontSize * 2);
		diagnostics.fill(255, 255, 0);
		diagnostics.text("MODULATION - OK!", width / 2, height / 5 * 3);
	}
	if (affirm[3] && millis() - affirmTimer[3] < affirmDuration) {
		// particle good
		diagnostics.fill(0);
		diagnostics.rect(width / 2, height / 5 * 4 - hudFontSize / 2, width / 2, hudFontSize * 2);
		diagnostics.fill(255, 255, 0);
		diagnostics.text("P. SPLITTER - OK!", width / 2, height / 5 * 4);
	}
	diagnostics.endDraw();
}