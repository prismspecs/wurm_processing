void checkScene() {
// if the scene has changed, recent timer
  if (scene != lastScene) {
    lastScene = scene;
    lastTime = millis();
    // send scene change out over OSC
    if (OSC) {
      OscMessage m = new OscMessage("/pilot/scene");
      m.add(scene);
      oscP5.send(m, PETER);
    }


    // remove any old waves here...
    for(int i = waves.size() - 1; i >= 0; i--) {
      waves.remove(i);
    }
    // and particles
    for(int i = particles.size() - 1; i >= 0; i--) {
      particles.remove(i);
    }
    resetVDMX();  // reset VDMX every scene change

    // erase canvases
    pilot.beginDraw();
    pilot.background(0);
    pilot.endDraw();
    diagnostics.beginDraw();
    diagnostics.background(0);
    diagnostics.endDraw();

    // reset difficulty selection
    whichDiff = 0;

    // reset approaching warp var
    approachingEnd = false;

    // reset targets and life
    /*
    for (int i = 0; i < actual.length; i++) {
      target[i] = range / 2;
      actual[i] = range / 2;
    }
    */
    
    // actually bias the oxygen for sake of the event pattern
    target[1] -= 1;
    life = startingLife;
    eventInterval = 2000; // starting event interval at 2 seconds

    // if its the gearTest tutorial, start at arbitrary values
    if (scene == 1) {
      target[0] = 90;
      target[1] = 10;
      target[2] = 32;
      targetSwitches = "101";
      eventReady[0] = false;
      eventReady[1] = false;
      eventReady[2] = false;
      eventReady[3] = false;
    }

    if (scene == 3) {
      // blast off! start with closed door
      doorOpen = 0;
    }

    if (scene != 4) {
      // no strobe for anything but emergency scene
      strobe = false;
    }

    if (scene == 5) {
      // if we are entering wormhole
      strobe = false;
      //shakeStrength = 10; (outdated, using VDMX now)
      startedWormhole = millis();
      life = startingLife;
      lastEvent = millis();
      // events are ready
      eventReady[0] = true;
      eventReady[1] = true;
      eventReady[2] = true;
      eventReady[3] = true;
    }
  }
}

void resetVDMX() {
  OscMessage  m = new OscMessage("/pilot/data");
  m.add(0);//shake
  m.add(0);//junk
  m.add(0);//junk
  m.add(0);//junk
  m.add(0);//hyper
  m.add(0);//junk
  m.add(0);//oxygen
  m.add(0);//junk
  m.add(0);//modulation
  m.add(0);//switches target
  m.add(0);//switches actual
  m.add(0);//total diff
  m.add(0);//approaching ending
  oscP5.send(m, VDMX);
}