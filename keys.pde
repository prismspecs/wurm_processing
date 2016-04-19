void keyReleased() {

  if (parseInt(key) > 47 && parseInt(key) < 57) {
    scene = key - 48;
    println("scene " + scene);
  }

  // FX / OPTIONS
  if (key == 'd') {
    diagnostic = !diagnostic;
    eraseDiag();
  }

  int addCount = 10;

  // ADD STUFF
  if (scene == 5) {
    if (key == 'q') {
      //println("adding asteroid");
      for (int i = 0; i < addCount; i++) {
        asteroids.add(new Asteroid(0));
      }
    }
    if (key == 'w' ) {
      for (int i = 0; i < addCount; i++) {
        asteroids.add(new Asteroid(1));
      }
    }
    if (key == 'e' ) {
      for (int i = 0; i < addCount; i++) {
        asteroids.add(new Asteroid(2)); // line monster
      }
    }
    if (key == 'r' ) {
      for (int i = 0; i < addCount; i++) {
        asteroids.add(new Asteroid(3)); // triangle
      }
    }
    if (key == 't' ) {
      for (int i = 0; i < addCount; i++) {
        asteroids.add(new Asteroid(4)); // streak
      }
    }
    if (key == 'y' ) {
      for (int i = 0; i < addCount; i++) {
        asteroids.add(new Asteroid(5)); // corkscrew thing
      }
    }
    if (key == 'u' ) {
      for (int i = 0; i < addCount; i++) {
        asteroids.add(new Asteroid(6));
      }
    }
    if (key == 'i' ) {
      for (int i = 0; i < addCount; i++) {
        asteroids.add(new Asteroid(7));
      }
    }
  }
}

void keyPressed() {
  // diagnostic keys for changing oxygen, etc. values
  if (key == '[') {
    actual[0] -= 5;
    actual[0] = constrain(actual[0], 0, range);
  }
  if (key == ']') {
    actual[0] += 5;
    actual[0] = constrain(actual[0], 0, range);
  }

  if (key == ';') {
    actual[1] -= 5;
    actual[1] = constrain(actual[1], 0, range);
  }
  if (parseInt(key) == 39) {
    actual[1] += 5;
    actual[1] = constrain(actual[1], 0, range);
  }

  if (key == ',') {
    actual[2] -= 5;
    actual[2] = constrain(actual[2], 0, range);
  }
  if (key == '.') {
    actual[2] += 5;
    actual[2] = constrain(actual[2], 0, range);
  }

// switches
  if (key == 'z') {
    if (actualSwitches.charAt(0) == '0') {
      actualSwitches = "1" + actualSwitches.charAt(1) + actualSwitches.charAt(2);
    } else {
      actualSwitches = "0" + actualSwitches.charAt(1) + actualSwitches.charAt(2);
    }
  }
  if (key == 'x') {
    if (actualSwitches.charAt(1) == '0') {
      actualSwitches = actualSwitches.charAt(0) + "1" + actualSwitches.charAt(2);
    } else {
      actualSwitches = actualSwitches.charAt(0) + "0" + actualSwitches.charAt(2);
    }
  }
  if (key == 'c') {
    if (actualSwitches.charAt(2) == '0') {
      actualSwitches = "" + actualSwitches.charAt(0) + actualSwitches.charAt(1) + "1";
    } else {
      actualSwitches = "" + actualSwitches.charAt(0) + actualSwitches.charAt(1) + "0";
    }
  }

  // add crack ... ?
  if (key == 'v') {
    cracks.add(new Crack());
  }

  // DIFFICULTY OPTIONs
  if (key == CODED) {
    if (keyCode == DOWN) {
      whichDiff++;
    }
    if (keyCode == UP) {
      whichDiff--;
    }
  }
}