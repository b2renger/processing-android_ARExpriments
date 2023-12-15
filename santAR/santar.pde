import processing.ar.*;

ARTracker tracker;
ArrayList<Santa> santas = new ArrayList<Santa>();

void setup() {
  fullScreen(AR);
  tracker = new ARTracker(this);
  tracker.start();
}

void draw() {
  lights();

  if (mousePressed) {
    // Create new anchor at the current touch point
    ARTrackable hit = tracker.get(mouseX, mouseY);
    if (hit != null) santas.add(new Santa(new ARAnchor(hit)));
  }

  for (Santa klaus : santas) {
    klaus.display();
  }

  drawTrackablePlanes();
}

class Santa {
  PShape s;
  ARAnchor a;
  float angle;
  Santa(ARAnchor anchor) {
    this.s= loadShape("santa.obj");
    this.s.scale(0.1);
    this.a = anchor;
    this.angle= random(TWO_PI);
  }

  void display() {
    if (a != null) {
      if (a.isTracking()) {
        a.attach();
        pointLight(57, 255, 180, 0, 0, 0.25);
        pushMatrix();
        translate(0,0,10);
        rotate(this.angle);
        shape(s);
        popMatrix();
        a.detach();
      }
    }
  }
}

void drawTrackablePlanes() {
  // Draw trackable planes
  for (int i = 0; i < tracker.count(); i++) {
    ARTrackable trackable = tracker.get(i);


    if (!trackable.isTracking()) return;

    pushMatrix();
    trackable.transform();
    if (mousePressed && trackable.isSelected(mouseX, mouseY)) {
      fill(255, 0, 0, 5);
    } else {
      fill(255, 5);
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
