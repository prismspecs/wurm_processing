float asteroidTrans = 120;  // global transparency modifier for asteroids

color[] colors = {
  color(0),
  color(255),
  color(79, 250, 247),
  color(168, 165, 212),
  color(177, 125, 186),
  color(149, 48, 57),
  color(246, 87, 153),
  color(100, 72, 130)
};

class Asteroid {
  PVector pos;

  color cFill, cStroke;

  float r = 0;  // rotation
  float rotateSpeed = .05;

  float sw = 2; //strokeWeight

  float ld = 5; // line distance

  float p;  // phase
  float pRate = .3;  // phase rate
  float pAdjust;  // use this number to add to s [or any other value)

  // boost speed as game goes on
  float speed = 10 + map(timeInWormhole, 0, wormholeDuration, 0, 20);
  float s = 1;  // starting size
  float growthRate = .5; // growth per frame

  int type = 0; // type of asteroid

  // properties
  // phase pulsates size of asteroid
  // corona gives it a circular outline
  // death color makes it change space bg color on impact w screen

  // behaviors
  boolean ROTATE, PHASE;

  Asteroid(int type) {
    this.type = type;

    pos = new PVector(random(width), random(height), far);

    // randomize its initial rotation
    r = random(TWO_PI);

    switch (type) {
    case 0: // WHITE STAR STREAKS
      sw = 2;
      break;
    case 1: // BLACK ROTATING CUBES W WHITE OUTLINE
      sw = 1;
      cFill = color(0);
      cStroke = color(255);
      ROTATE = true;
      growthRate = .3;
      s = .02;
      break;
    case 2: // PULSING COLOR CIRCLES
      sw = 0;
      pRate = .2;
      s = .4;
      growthRate = .3;
      cFill = colors[int(random(colors.length))]; // draw random color
      PHASE = true;
      break;
    case 3: // COLORFUL CORKSCREW LINE
      ld = 20;
      sw = 2.5;
      PHASE = true;
      break;
    case 4: // ROTATING TRIANGLES
      cFill = color(255);
      rotateSpeed = .1;
      ROTATE = true;
      PHASE = true;
      break;
    case 5: // CYCLONE
      s = 1;
      sw = 1;
      growthRate = .01;
      rotateSpeed = .1;
      ROTATE = true;
      PHASE = true;
      break;
    case 6: // BIRTH COLOR
      // dont choose black
      int rando = int(random(colors.length - 1)) + 1;
      bgColor = color(colors[rando], 24);
      speed = 10000;
      break;
    case 7: // BUTTERFLY
      cFill = colors[int(random(colors.length))];
      growthRate = .1;
      ROTATE = true;
      PHASE = true;
      break;
    case 8:
      PHASE = true;
      growthRate = .25;
      break;
    }
  }

  void update() {
    // all asteroid types move towards you (and grow)
    pos.z += speed * 90 * deltaTime;
    s += growthRate;

    // rotating asteroids
    if (ROTATE) {
      r += rotateSpeed;
    }
    // phasing asteroids
    if (PHASE) {
      p += pRate; // inc phase
      pAdjust += sin(p) * .5;
    }
  }

  void display() {

    switch (type) {
    case 0: // WHITE STAR STREAK
      pg.pushMatrix();
      pg.translate(pos.x, pos.y, pos.z);
      pg.stroke(255);
      pg.strokeWeight(sw);
      pg.line(0, 0, 0, 0, 0, -10);
      pg.popMatrix();
      break;
    case 1: // BLACK ROTATING CUBES W WHITE OUTLINE
      pg.pushMatrix();
      pg.translate(pos.x, pos.y, pos.z);
      pg.rotateY(r);
      pg.rotateZ(r * 2);
      pg.rotateX(r * 3);
      pg.fill(cFill, asteroidTrans);
      pg.strokeWeight(sw);
      pg.stroke(cStroke);
      pg.box(s + pAdjust);
      pg.popMatrix();
      break;
    case 2: // PULSING COLOR CIRCLES
      pg.pushMatrix();
      pg.translate(pos.x, pos.y, pos.z);
      pg.strokeWeight(sw);
      pg.stroke(cStroke);
      pg.fill(cFill, asteroidTrans);
      pg.ellipse(0, 0, s + (pAdjust * 1.5), s + (pAdjust * 1.5));
      pg.popMatrix();
      break;
    case 3: // COLORFUL CORKSCREW LINE
      pg.pushMatrix();
      pg.translate(pos.x, pos.y, pos.z);
      pg.stroke(cStroke);
      pg.strokeWeight(sw);

      int segments = 8;

      PVector[] linePV = new PVector[segments];
      cStroke = color(10, 10, 10);
      pg.stroke(cStroke);
      linePV[0] = new PVector(0, 0, 0);
      for (int i = 1; i < segments; i++) {
        float x = cos( p + (segments / TWO_PI * i)) * ld * (i * .1);
        float y = sin( p + (segments / TWO_PI * i)) * ld * (i * .1);
        float z = linePV[i - 1].z - ld;

        linePV[i] = new PVector(x, y, z);

        cStroke = color(10, 20, map(sin(p), -1, 1, 0, 140));
        pg.stroke(cStroke, 100);
        pg.line(linePV[i - 1].x, linePV[i - 1].y, linePV[i - 1].z, x, y, z);
      }

      pg.popMatrix();
      break;
    case 4: // ROTATING TRIANGLES
      pg.pushMatrix();
      pg.translate(pos.x, pos.y, pos.z);
      pg.rotateZ(r);
      pg.rotateX(3 * PI / 2);
      pg.noStroke();
      float triangleRed = map(sin(p), -1, 1, 0, 255);
      float triangleGreen = map(cos(p), -1, 1, 0, 255);
      float triangleBlue = map(tan(p), -1, 1, 0, 255);
      cFill = color(triangleRed, triangleGreen, triangleBlue);
      pg.fill(cFill);
      pg.triangle(0, -16, 12, 16, -12, 16);
      pg.popMatrix();
      break;
    case 5: // CYCLONE
      float cycloneRed = map(sin(p), -1, 1, 0, 255);
      float cycloneGreen = map(cos(p), -1, 1, 0, 255);
      cFill = color(cycloneRed, cycloneGreen, 127);

      pg.stroke(cFill);
      pg.strokeWeight(sw + pAdjust * 2);

      pg.pushMatrix();
      pg.translate(pos.x + cos(p) * s * 2, pos.y + sin(p) * s * 2, pos.z);
      pg.rotateX(r);
      pg.point(0, 0);
      pg.popMatrix();

      pg.pushMatrix();
      pg.translate(pos.x + cos(p * -1) * s * 2, pos.y + sin(p * -1) * s * 2, pos.z - 10);
      pg.rotateX(r);
      pg.point(0, 0);
      pg.popMatrix();

      pg.pushMatrix();
      pg.translate(pos.x + sin(p * -1) * s * 2, pos.y + cos(p * -1) * s * 2, pos.z - 20);
      pg.rotateX(r);
      pg.point(0, 0);
      pg.popMatrix();

      pg.pushMatrix();
      pg.translate(pos.x + sin(p) * s * 2, pos.y + cos(p) * s * 2, pos.z - 30);
      pg.rotateX(r);
      pg.point(0, 0);
      pg.popMatrix();
      break;
    case 6: // BIRTH COLOR
      // n/a
      break;
    case 7: // BUTTERFLY
      pg.pushMatrix();
      pg.fill(cFill);
      pg.noStroke();
      pg.translate(pos.x, pos.y, pos.z);
      pg.rotateZ(r);
      pg.beginShape(TRIANGLES);
      pg.vertex(0, 0, 0);
      pg.vertex(0, 0, -s);
      pg.fill(cFill);
      pg.vertex(s, 0 + sin(p) * s / 2, -s);
      pg.fill(0);
      pg.vertex(0, 0, 0);
      pg.vertex(0, 0, -s);
      pg.fill(cFill);
      pg.vertex(-s, 0 + sin(p) * s / 2, -s);
      pg.endShape();
      pg.popMatrix();
      break;
    case 8:
      pg.sphereDetail(7);
      pg.pushMatrix();
      pg.noFill();
      pg.translate(pos.x, pos.y, pos.z);
      pg.rotateZ(r);pg.rotateY(r/2);pg.rotateZ(r/3);
      pg.sphere(s + pAdjust*8);
      pg.popMatrix();
      break;
    }
  }

  boolean dead() {
    // if object gets totally offscreen...
    if (pos.z > 1000) {
      return true;  // destroy object
    } else {
      return false;
    }
  }
}