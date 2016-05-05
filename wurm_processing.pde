// ctl alt F

/* to do list:
*/

// ------ libs ------
import codeanticode.syphon.*;
import processing.video.*;
import oscP5.*;
import netP5.*;

// ------ options ------
final static boolean OSC = false;
final static boolean SYPHON = true;
boolean diagnostic = false;  // diagnostics on for debug


// ------ OSC ------
OscP5 oscP5;
NetAddress PETER, VDMX;
String PETER_IP = "169.254.128.132";
String VDMX_IP = "127.0.0.1"; // (localhost)


// universal stuff
long lastTime = 0;  // last time millis was queried
int lastScene = 0;  // to detect scene changes
// 0: waiting 1: Suit Up 2: Gear Test 3: Blast Off 4: Emergency 5: Wormhole! 6: End
int scene = 0;
// animatin timers
long currTime, prevTime;
float deltaTime;
float near = 1000; // camera Z bounds
float far = -1400;


// ------ objects/arrays ------
ArrayList<Star> stars = new ArrayList<Star>();
Houston houston;  // :)
ArrayList<Wave> waves = new ArrayList<Wave>();
ArrayList<Particle> particles = new ArrayList<Particle>();


// ------ graphics ------
PGraphics pilot, diagnostics;
SyphonServer syphon_pilot, syphon_diagnostics;
// final sizes for each -- need to re-enter in settings() manually
final static int PILOT_W = 1280;
final static int PILOT_H = 720;
final static int DIAGNOSTICS_W = 1280;
final static int DIAGNOSTICS_H = 720;
final static int HOUSTON_W = 1024;
final static int HOUSTON_H = 768;
// font
PFont font_large, font_small;
color textColor = color(255, 255, 0);
float font_large_size, font_small_size;


void settings() {
  size(PILOT_W, PILOT_H, P3D);
  PJOGL.profile=1;  // syphon friendly ^^
}

void setup() {

  frameRate(30);

  // graphics contexts (houston's is inside its object)
  pilot = createGraphics(PILOT_W, PILOT_H, P3D);
  diagnostics = createGraphics(DIAGNOSTICS_W, DIAGNOSTICS_H, P3D);

  // init object/lists
  stars = new ArrayList();
  oscStack = new ArrayList();

  // houston
  houston = new Houston(this);

  // set up fonts
  font_large = loadFont("font100.vlw");
  font_small = loadFont("font40.vlw");
  font_large_size = PILOT_W * .07;
  font_small_size = PILOT_W * .035;

  // 3d camera setup
  float fov = PI / 3.0;
  float cameraZ = (PILOT_H / 2.0) / tan(fov / 2.0);
  perspective(fov, float(PILOT_W) / float(PILOT_H), near, far);

  // set up graphics context
  pilot.beginDraw();
  pilot.imageMode(CENTER);
  pilot.background(0);
  pilot.textFont(font_small, 40);
  pilot.endDraw();

  // Create syhpon server to send frames out
  if (SYPHON) {
    syphon_pilot = new SyphonServer(this, "wurm_pilot");
    syphon_diagnostics = new SyphonServer(this, "wurm_diagnostics");
  }

  // OSC setup
  oscP5 = new OscP5(this, 8000);
  PETER = new NetAddress(PETER_IP, 9000);
  VDMX = new NetAddress(VDMX_IP, 1234);

  resetVDMX();
  setupHUD(); // setup HUD display once at start

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
    pilot.beginDraw();
    doStrobe();
    pilot.endDraw();
  }

  // houston
  houston.update();
  houston.display();

  // render game to screen (or syphon)
  if (!SYPHON) {
    noStroke();
    image(pilot, 0, 0);
  } else {
    syphon_pilot.sendImage(pilot);
    syphon_diagnostics.sendImage(diagnostics);
  }
}

void doText(String t, color c) {
  pilot.textAlign(CENTER);
  pilot.textFont(font_large, font_large_size);
  pilot.fill(c);
  pilot.text(t, width / 2, height / 2);
}

void eraseDiag() {
  // erase diagnostic
  diagnostics.beginDraw();
  diagnostics.fill(0);
  diagnostics.noStroke();
  diagnostics.rect(0, height, width, height);
  diagnostics.endDraw();
}