// think of it as 3 sliders, with target values and then actual values
// the goal is to get the actual to the target by adjusting sensors etc.
float range = 100;	// 0 - 9 range
float[] target = {range / 2, range / 2, range / 2};	// where value should be
float[] actual = {range / 2, range / 2, range / 2};	// where value is
// now we also have flip switches
String targetSwitches = "000";
String actualSwitches = "000";
int switchWeight = 5;	// how much damage does one off digit do?

float startingLife = 9000;	// varies by difficulty - 9000 is good
float life = startingLife;	// player hit points
float lifeDist = 0;	// for peter, what is diff between targets and actuals?
long lastLifeCheck;	// last millis when life was checked
int lifeCheckInterval = 1000;	// every second

int wormholeDuration = 150 * 1000;	// 2.5 minutes
long timeInWormhole;
boolean approachingEnd = false;

long startedWormhole = 0;	// when did we start wormhole?
float eventInterval = 2 * 1000;	// starting event interval
long lastEvent;	// when was the last 'error event'?
int lastEventType = 0;	// which system failed?

long lastOscSend = 0;	// only send out OSC messages every second

color bgColor = color(0);	// to fuck w bg color

float targetBuffer = .075;	// how close target and actual needs to be
// also keep track of how long the stuff has been correct
boolean[] targetMonitor = {false, false, false, false};
long[] targetMonitorTime = {0, 0, 0, 0};
int targetTimeThreshold = 1000;	// 1 second to lock in values
boolean[] affirm = {false, false, false, false};
long[] affirmTimer = {0, 0, 0, 0};
int affirmDuration = 1000;

void wormhole() {

	// this seems to get used a lot, so...
	timeInWormhole = millis() - startedWormhole;

	// go through OSC message stack
	isBusy = true;
	synchronized (oscStack) {
		for (OscMessage o : oscStack) {
			unPackOsc(o);	// in osc.pde for organization
		}
		for (int i = oscStack.size() - 1; i >= 0; i--) {
			oscStack.remove(i);
		}
	}
	isBusy = false;

	// add streaks
	for (int i = 0; i < 2; i++) {
		streaks.add(new Asteroid(0));
	}

	// remove old streaks
	for (int i = streaks.size() - 1; i >= 0; i--) {
		Asteroid a = streaks.get(i);
		if (a.dead()) {
			streaks.remove(i);
		}
	}

	// destroy any asteroids that are offscreen
	synchronized (asteroids) {
		for (int i = asteroids.size() - 1; i >= 0; i--) {
			Asteroid a = asteroids.get(i);
			if (a.dead()) {
				asteroids.remove(i);
			}
		}
	}

	// remove old stars from previous scene gradually
	if (timeInWormhole > 1000 && stars.size() > 0) {
		if (random(1) > .7) {
			int rando = int(random(stars.size()));
			stars.remove(rando);
		}
	}

	// vars for end of wormhole
	float timeInWormholeSq = pow(timeInWormhole, 2);
	float durSq = pow(wormholeDuration, 2);

	pg.beginDraw();

	pg.background(bgColor);

	// render stars
	for (Star s : stars) {
		s.display();
	}

	// render streaks
	for (Asteroid a : streaks) {
		a.update();
		a.display();
	}

	if (wormholeDuration - timeInWormhole > wormholeDuration * .3) {
		pg.noFill();
	} else {
		// last 30% of wormhole time, bright white light!
		pg.fill(map(timeInWormholeSq, durSq * .7, durSq, 0, 22));
	}

	pg.strokeWeight(map(timeInWormholeSq, 0, durSq, .5, 30));
	pg.stroke(100, 100, 255, 90);
	pg.pushMatrix();
	pg.translate(width / 2, height / 2, far);

	float temp = map(timeInWormholeSq, 0, durSq, 0, 3200);
	pg.ellipse(0, 0, temp, temp);
	pg.popMatrix();

	// update, display asteroids
	//synchronized (asteroids) {
	for (Asteroid a : asteroids) {
		a.update();
		a.display();
	}
	//}

	pg.endDraw();

	// and if we're REALLY CLOSE to the end
	if (wormholeDuration - timeInWormhole < wormholeDuration * .05) {
		approachingEnd = true;
	}

	// reset background color for next time
	bgColor = color(0);

	if (diagnostic) {
		// draw sliders (diagnostic)
		gearTest();
	} else {
		eraseDiag();
		drawHP(true);
	}

	// check if the resources are properly set, as in
	// if oxygen was randomly messed with, and the pilot corrected it
	// set this resource/event to READY
	for (int i = 0; i < 4; i++) {
		if (!eventReady[i]) {
			// for any event/resource that ISNT ready, check it again
			if (i == 3) {	// switches?
				if (targetSwitches.equals(actualSwitches)) {
					// its in the zone, but needs to stay there for a bit
					if (!targetMonitor[i]) {
						targetMonitor[i] = true;
						targetMonitorTime[i] = millis();
					} else {
						// target already monitored, check time
						if (millis() - targetMonitorTime[i] > targetTimeThreshold) {
							eventReady[i] = true;
							// set up vars to display affirmative for a duration
							affirm[i] = true;
							affirmTimer[i] = millis();
							if (OSC) {
								OscMessage m = new OscMessage("/pilot/affirmative");
								m.add(i);
								oscP5.send(m, PETER);
								oscP5.send(m, BASE);
							}
						}
					}
				}
			} else {	// analogs?
				if (abs((target[i] - actual[i]) / range) < targetBuffer) {
					// its in the zone, but needs to stay there for a bit
					if (!targetMonitor[i]) {
						targetMonitor[i] = true;
						targetMonitorTime[i] = millis();
					} else {
						// target already monitored, check time
						if (millis() - targetMonitorTime[i] > targetTimeThreshold) {
							// its been there long enough, proceed
							eventReady[i] = true;

							// set up vars to display affirmative for a duration
							affirm[i] = true;
							affirmTimer[i] = millis();

							// play affirmative sound, etc.
							if (OSC) {
								OscMessage m = new OscMessage("/pilot/affirmative");
								m.add(i);
								oscP5.send(m, PETER);
								oscP5.send(m, BASE);
							}
						}
					}


				}
			}
			// give a second buffer between fixing a problem and it
			// potentially popping up again
			lastCheck[i] = millis();
		}
	}

	// !!! dont forget what this is ;p not for error handling
	doEvents();	// error events (resource changes, etc. THE MEAT!)


	//  +++ +++ +++ CHANGING LIFE +++ +++ +++

	if (millis() - lastLifeCheck >= lifeCheckInterval) {
		// reset timer
		lastLifeCheck = millis();

		// cycle and deduct
		lifeDist = 0;
		// the analog stuff
		for (int i = 0; i < target.length; i++) {
			if (abs((target[i] - actual[i]) / range) > targetBuffer) {
				lifeDist += abs(target[i] - actual[i]);
			}
		}
		// the switches
		int switchDist = 0;
		for (int i = 0; i < 3; i++) {
			switchDist += abs(actualSwitches.charAt(i) - targetSwitches.charAt(i));
		}
		lifeDist += (switchDist * switchWeight);
		life -= lifeDist;
	}

	// victory conditions
	if (timeInWormhole > wormholeDuration) {
		if (life > 0) {
			// you fuckin won!
			scene = 6;
		}
	}
	if (life < 0) {
		// you fuckin lost!
		scene = 7;
	}

	// send out necessary OSC data every X ms
	if (millis() - lastOscSend > 50 && OSC) {
		lastOscSend = millis();	// reset timer
		sendAll();	// broadcast all values
	}
}

void unPackOsc(OscMessage o) {

	int i = o.get(0).intValue();

	// rhythm and melody come in 0-3 so add 4 if its melody
	if (o.addrPattern().equals("/peter/melody")) i += 4;

	if (asteroids.size() < maxAsteroids) {
		synchronized (asteroids) {
			asteroids.add(new Asteroid(i + 1));
		}
	}
}