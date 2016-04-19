// ctl alt F

/* to do list:
*/

import codeanticode.syphon.*;
import oscP5.*;
import netP5.*;

// final bools
final static boolean OSC = true;
final static boolean SYPHON = true;
boolean diagnostic = false;  // diagnostics on for debug

SyphonServer syphon1, syphon2;

OscP5 oscP5;
NetAddress PETER, BASE, VDMX;
String PETER_IP = "169.254.128.132";
String BASE_IP = "169.254.208.46";
String VDMX_IP = "127.0.0.1"; // (localhost)
// me 169.254.4.180

// 0: waiting 1: Suit Up 2: Gear Test 3: Blast Off 4: Emergency 5: Wormhole! 6: End
int scene = 0;

// general graphics and such
PFont font, fontGUI;
color textColor = color(255, 255, 0);
float near; // camera bounds
float far;
final static int FONT_SIZE = 80;

// universal stuff
long lastTime = 0;  // last time millis was queried
int lastScene = 0;  // to detect scene changes
int maxAsteroids = 2000;  // max number of 'stroids on screen

// arraylists :D :D :D
ArrayList<Asteroid> asteroids = new ArrayList<Asteroid>();
ArrayList<Star> stars = new ArrayList<Star>();
ArrayList<Asteroid> streaks = new ArrayList<Asteroid>();
ArrayList<Crack> cracks = new ArrayList<Crack>();

PGraphics pg, pgD; // graphics contexts [pgD = diagnostics]
final static int SPACE_W = 1280;
final static int SPACE_H = 720;
final static int GUI_W = 1280;
final static int GUI_H = 720;

// images
PImage[] diffImg = new PImage[3]; // difficulty selection

// animatin timers
long currTime, prevTime;
float deltaTime;


// THIS IS NEW
void settings() {
  size(1280, 720, P3D);
  PJOGL.profile=1;
}

void setup() {
  // set up size so that there is extra space below for the gui to render
  frameRate(30);

  // THESE ARE CHANGED
  pg = createGraphics(width, height, P3D);
  pgD = createGraphics(GUI_W, GUI_H, P3D);

  // init object lists
  asteroids = new ArrayList();
  streaks = new ArrayList();
  stars = new ArrayList();
  oscStack = new ArrayList();

  // general
  font = loadFont("font100.vlw");
  fontGUI = loadFont("font40.vlw");

  // 3d setup
  float fov = PI / 3.0;
  float cameraZ = (height / 2.0) / tan(fov / 2.0);
  near = 1;
  far = -1000;
  perspective(fov, float(width) / float(height), near, far);

  // set up graphics context
  pg.beginDraw();
  pg.imageMode(CENTER);
  pg.background(0);
  pg.textFont(font, 40);
  pg.endDraw();

  image(pg, 0, 0);

  // Create syhpon server to send frames out
  if (SYPHON) {
    syphon1 = new SyphonServer(this, "Wormhole - graphics");
    syphon2 = new SyphonServer(this, "Wormhole - diagnostics");
  }

  // OSC setup
  oscP5 = new OscP5(this, 8000);
  PETER = new NetAddress(PETER_IP, 9000);
  BASE = new NetAddress(BASE_IP, 7000);
  VDMX = new NetAddress(VDMX_IP, 1234);

  resetVDMX();
  setupHUD(); // setup HUD display once at start

  // load in images
  //PImage[] diffImg = new PImage[3];
  diffImg[0] = loadImage("difficulty_0.jpg");
  diffImg[1] = loadImage("difficulty_1.jpg");
  diffImg[2] = loadImage("difficulty_2.jpg");

  // Initialise the timer
  currTime = prevTime = millis();
}

void draw() {

  // update timers
  currTime = millis();
  // calculate the elapsed time in seconds
  deltaTime = (currTime - prevTime) / 1000.0;
  // remember current time for the next frame
  prevTime = currTime;

  checkScene(); // check for scene change to issue scene specific commands

  switch (scene) {
  case 0: // WAITING FOR PLAYER
    waiting();
    break;
  case 1: // PILOT GEAR TEST
    gearTest();
    break;
  case 2: // HOUSTON COMM TEST
    commTest();
    break;
  case 3: // BLAST OFF
    blastOff();
    break;
  case 4: // EMERGENCY
    emergency();
    break;
  case 5: // WORMHOLE
    wormhole();
    break;
  case 6: // VICTORY
    victory();
    break;
  case 7: // DEFEAT
    defeat();
    break;
  case 8: // SELF-DESTRUCT
    selfDestruct();
    break;
  }

  // lastly, render visual fx .. is this still used?
  if (strobe) {
    pg.beginDraw();
    doStrobe();
    pg.endDraw();
  }

  // render game to screen (or syphon)
  if (!SYPHON) {
    noStroke();
    image(pg, 0, 0);
  } else {
    syphon1.sendImage(pg);
    syphon2.sendImage(pgD);
  }
}

void doText(String t, color c) {
  pg.textAlign(CENTER);
  pg.textFont(font, FONT_SIZE);
  pg.fill(c);
  pg.text(t, width / 2, height / 2);
}

void eraseDiag() {
  // erase diagnostic
  pgD.beginDraw();
  pgD.fill(0);
  pgD.noStroke();
  pgD.rect(0, height, width, height);
  pgD.endDraw();
}