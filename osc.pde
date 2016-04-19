// need a buffer of OSC messages so we dont get concurrent mod error
ArrayList<OscMessage> oscStack = new ArrayList<OscMessage>();

volatile boolean isBusy = false;

/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {

	// add osc message to a stack so we can deal w them synchronously later
	if (!isBusy && scene == 5 ) {
		if (theOscMessage.addrPattern().equals("/peter/rhythm") || theOscMessage.addrPattern().equals("/peter/melody")) {
			oscStack.add(theOscMessage);
		}
	}

	// taking in values from monica based on arduino
	if (theOscMessage.addrPattern().equals("/base")) {
		for (int i = 0; i < actual.length; i++) {
			float percentage = theOscMessage.get(i).floatValue();
			actual[i] = percentage;
		}
		// the last one is a string of three digits
		actualSwitches = theOscMessage.get(3).stringValue();

		// the last one is self destruct...
		int selfDestructButton = theOscMessage.get(4).intValue();
	}

	// for scenes 0-3, houston controls scene change
	if (theOscMessage.addrPattern().equals("/base/scene")) {
		int newScene = theOscMessage.get(0).intValue();
		if (newScene < 4)
			scene = newScene;
		if (newScene == 8)
			scene = newScene;
	}
}

void sendAll() {

	// 0: shake 0-1
	// 1: current time in wormhole
	// 2: life 0-1
	// 3: target hyper 4: actual hyper
	// 4: target oxyge 5: actual oxygen
	// 5: target mod   6: actual mod
	// 7: target switches 8: actual switches

	OscMessage m = new OscMessage("/pilot/data");
	m.add(map(lifeDist, 0, range * 3, 0, 1));	// shake 0-1, float
	m.add(int(currTime / 1000)); 			// current in wormhole (secs), int
	m.add(life / startingLife);	// life 0-1
	// send all targets and actuals 0-100, float
	// ordered: hyperdrive, oxygen, modulation
	for (int i = 0; i < target.length; i++) {
		m.add(target[i] / range);
		m.add(actual[i] / range);
	}
	m.add(targetSwitches);	// String
	m.add(actualSwitches);	// String
	m.add(map(lifeDist, 0, 315, 0, 1));	// difference between all targets and actuals
	m.add((approachingEnd) ? 1 : 0);	// 1 or zero true/false
	// to everyone, because why not
	oscP5.send(m, PETER);
	oscP5.send(m, BASE);
	if (scene == 5)
		oscP5.send(m, VDMX);
}