class Particle {

  float x, y, z;

  float speed, size;

  float warp;  // what effect it has on the wave vertices

  Particle() {
    z = far;
    // spawn it near the center
    x = random(width*.3, width*.7);
    y = random(height*.3, height*.7);
    speed = random(10, waveSpeed);  //waveSpeed/2
    //speed = waveSpeed;
    //speed = waveSpeed/2;
    size = map(waveSpeed, minWaveSpeed, maxWaveSpeed, 60, 250);

    // how much this will effect the vertices
    if (random(1) > .5) {
      warp = .1;
    } else {
      warp = -.1;
    }
  }

  void update() {
    // move forward
    z += speed * deltaTime;

    // go thru each wave
    for (Wave wave : waves) {
      // if it's close enough...
      if (abs(wave.z - z) < size) {
        // go thru this wave's vertices
        for (int i = 0; i < pointCount; i++) {
          // if its close enough...
          if (dist(x, y, wave.x[i], wave.y[i]) < size) {
            // distort vertex
            wave.pointOffset[i] += warp;
            // change color
            //wave.c[i] += warp * 3;
          }
        }
      }
    }
  }

  void display() {
    pilot.pushMatrix();
    pilot.translate(x, y, z);
    pilot.noFill();
    pilot.sphereDetail(8);
    pilot.stroke(255, 0, 0, 50);
    pilot.sphere(size);
    pilot.popMatrix();
  }
}