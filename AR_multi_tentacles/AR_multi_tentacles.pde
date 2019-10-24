import processing.ar.*;

ARTracker tracker;
ArrayList <Tentacle> Tentacles;
boolean pPressed = false;

void setup() {
  fullScreen(AR);

  noStroke();
  Tentacles = new ArrayList<Tentacle>();
  tracker = new ARTracker(this);
  tracker.start();
}

void draw() {
  //lights();

  if (mousePressed) {
    ARTrackable hit = tracker.get(mouseX, mouseY);
    if (hit != null && pPressed == false) Tentacles.add(new Tentacle(hit));
    pPressed = true;
  } else {
    pPressed = false;
  }
  for (int i = 0; i < Tentacles.size(); i++) {
    Tentacle p = Tentacles.get(i);
    p.display();

    // if a group of tentacles is composed of more that 6 branches
    // don't add new ones
    if (p.niterations < 6) { 
      p.update();
    }
  }

  // Draw trackable planes
  for (int i = 0; i < tracker.count(); i++) {
    ARTrackable trackable = tracker.get(i);
    
   
    if (!trackable.isTracking()) return;

    pushMatrix();
    trackable.transform();
    if (mousePressed && trackable.isSelected(mouseX, mouseY)) {
      fill(255, 0, 0, 100);
    } else {
      fill(255, 100);
    }
    beginShape(QUADS);
    float lx = trackable.lengthX();
    float lz = trackable.lengthZ();
    vertex(-lx/2, 0, -lz/2);
    vertex(-lx/2, 0, +lz/2);
    vertex(+lx/2, 0, +lz/2);
    vertex(+lx/2, 0, -lz/2);
    endShape();
    popMatrix();
  }
}

class Tentacle {

  float angle = 0;
  ARAnchor anchor;


  PShape t;// hold all the shapes

  int niterations = 0; // track number of tentacles

  float startSize = 0.1;
  float s = startSize; // current size
  float h = 0; // current height

  // noise per axis => fix for each tentacle
  float xnoise = random(9999);
  float znoise = random(9999);
  float ynoise = random(9999);

  // offset for each sphere
  float xoff = 0;
  float yoff = 0;
  float zoff = 0;

  // noise moving factor
  float inc = 0;

  Tentacle(ARTrackable hit) {
    anchor = new ARAnchor(hit);

    t = createShape(GROUP);
  }

  void display() {
    if (anchor != null) {
      if (anchor.isTracking()) {
        anchor.attach();
        pointLight(57, 255, 180, 0, 0, 0.25); // add a point light above the shape
        fill(57, 255, 180);
        translate(0, 0, startSize);
        shape(t);
        anchor.detach();
      }
    }
  }

  void update() {
    // update noise offsets
    inc += 0.05;
    xoff += map(noise(xnoise, inc), 0, 1, -s, s);
    yoff += map(noise(ynoise, inc), 0, 1, 0, s);
    zoff += map(noise(znoise, inc), 0, 1, -s, s);

    // create a new shape move it to its position and add it to the group
    PShape sphere = createShape(SPHERE, s);
    sphere.translate(xoff, h+yoff, zoff);
    t.addChild(sphere);

    // decrease height and size
    h += s/2;
    s -= 0.005;

    // if size is too small re-init to start a new tentacle
    if (s< 0.005) {
      h = 0;
      s = startSize;
      xnoise = random(9999);
      znoise = random(9999);
      ynoise = random(9999);
      xoff = 0;
      yoff = 0;
      zoff = 0;
      // increment number of tentacles spawned
      niterations +=1;
    }
  }
}
