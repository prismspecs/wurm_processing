// think of it as 3 sliders, with target values and then actual values
// the goal is to get the actual to the target by adjusting sensors etc.
float range = 100;	//
float[] target = {range / 2, range / 2, range / 2};	// where value should be
float[] actual = {range / 2, range / 2, range / 2};	// where value is
// now we also have flip switches
String targetSwitches = "010";
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


// ------ wave properties ------
int waveCount = 0;
int pointCount = 28; // 32
float whDiameter = 120;
float phaseOffset, newPhaseOffset;
float ringRate = 80;  //ms birthrate  was 20
int minRingRate = 20;  //20
int maxRingRate = 80; //120
float waveSpeed = 800;
float minWaveSpeed = 100;
float maxWaveSpeed = 1200;
int maxWaves = 800;
float rotateMult = .0025; // how fast shit spins
long lastRing;


void wormhole() {

	// ------ timer ------
	timeInWormhole = millis() - startedWormhole;


	// ------ OSC ------
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


	// ------ WORMHOLE! -----

	// spawn new ring of points every so often
	if (currTime - lastRing > ringRate && waves.size() < maxWaves) {
		lastRing = currTime;

		waves.add(new Wave(far));
		waveCount++;

		//whDiameter = 120 + noise(waveCount) * 60;

		//whDiameter = random(80, 140);

		// set offset
		if (phaseOffset == 0) {
			phaseOffset = TWO_PI / pointCount / 2;
		} else {
			phaseOffset = 0;
		}
	}

	// remove any waves that have gone offscreen
	for (int i = waves.size() - 1; i >= 0; i--) {
		Wave w = waves.get(i);
		if (w.z > near) {
			waves.remove(i);
		}
	}

	// spawn new particles (testing)
	for (int i = 0; i < 1; i++) {
		//particles.add(new Particle(int(random(3))));
		if(random(1) > .7)
		particles.add(new Particle(2));
	}

	// remove any stray particles
	for (int i = particles.size() - 1; i >= 0; i--) {
		Particle p = particles.get(i);
		if (p.z > near) {
			particles.remove(i);
		}
	}

	// update partciles
	for (Particle p : particles) {
		p.update();
		//p.display();
	}

	// update and display
	for (Wave wave : waves) {
		wave.update();
		//wave.display();	// just for diagnostic
	}


	pilot.beginDraw();
	pilot.background(bgColor);


	// ------ draw triangles ------

	pilot.noStroke();
	//colorMode(HSB, 255);
	// draw triangles
	for (int iw = 0; iw < waves.size(); iw++) {
		if (iw + 1 < waves.size()) {
			Wave w1 = waves.get(iw);
			Wave w2 = waves.get(iw + 1);

			for (int i = 0; i < pointCount; i++) {
				float op = map(w1.z, far, near, 0, 255);
				pilot.pushMatrix();
				//pilot.stroke(255, op / 7);

				pilot.beginShape(TRIANGLES);
				//pilot.fill(w1.c[i], op);
				pilot.fill(w1.col[i], op);
				pilot.vertex(w1.x[i], w1.y[i], w1.z);
				//pilot.fill(w2.c[i], op);
				pilot.fill(w2.col[i], op);
				pilot.vertex(w2.x[i], w2.y[i], w2.z);

				int ii = i;
				if (!w1.turned) {
					ii = (i + 1) % pointCount;
				} else {
					// get around negative modulo problem...
					ii = (i - 1) % pointCount;
					if (i == 0) ii = pointCount - 1;
				}
				//pilot.fill(w2.c[ii], op);
				pilot.vertex(w2.x[ii], w2.y[ii], w2.z);
				pilot.endShape();

				// draw inverse (sorta) triangle to fill in gap
				pilot.beginShape(TRIANGLES);
				//pilot.fill(w1.c[i], op);
				pilot.vertex(w1.x[i], w1.y[i], w1.z);
				//pilot.fill(w1.c[(i+1) % pointCount], op);
				pilot.vertex(w1.x[(i + 1) % pointCount], w1.y[(i + 1) % pointCount], w1.z);

				ii = i;
				if (!w1.turned) {
					ii = (i + 1) % pointCount;
				} else {
				}
				//pilot.fill(w2.c[ii], op);
				pilot.vertex(w2.x[ii], w2.y[ii], w2.z);

				pilot.endShape();
				pilot.popMatrix();
			}
		}
	}

	// draw particles
	for (Particle p : particles) {
		p.display();
	}

	// ------ light at the end of the tunnel ------
	// float timeInWormholeSq = pow(timeInWormhole, 2);
	// float durSq = pow(wormholeDuration, 2);

	// if (wormholeDuration - timeInWormhole > wormholeDuration * .3) {
	// 	pilot.noFill();
	// } else {
	// 	// last 30% of wormhole time, bright white light!
	// 	pilot.fill(map(timeInWormholeSq, durSq * .7, durSq, 0, 22));
	// }

	// pilot.strokeWeight(map(timeInWormholeSq, 0, durSq, .5, 30));
	// pilot.stroke(100, 100, 255, 90);
	// pilot.pushMatrix();
	// pilot.translate(width / 2, height / 2, far);

	// float temp = map(timeInWormholeSq, 0, durSq, 0, 3200);
	// pilot.ellipse(0, 0, temp, temp);
	// pilot.popMatrix();



	pilot.endDraw();

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

	// if (asteroids.size() < maxAsteroids) {
	// 	synchronized (asteroids) {
	// 		asteroids.add(new Asteroid(i + 1));
	// 	}
	// }
}