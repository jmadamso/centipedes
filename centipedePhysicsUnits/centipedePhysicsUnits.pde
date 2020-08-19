import shiffman.box2d.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.collision.shapes.Shape;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.*;

//ALL UNITS ARE IN TERMS OF kg, m, s

//parameters:
int numSegments = 1;
float wheelRadius = 76e-3; //mm 
float segmentLength = wheelRadius + 30e-3;
float motorTorque = numSegments * 1000000;
float stepHeight = 50e-3;
float springDamping = 1;

//our objects and the world they live in:
Centipede centipede; 
Step floor;
Step topStep;
Step[] stairs;

Box2DProcessing box2d;

float zoom = 1;
float pixelsPerMeter = 250;

void setup() {
  //print("hello, world! it's a good day to be a centipede\n");
  size(500, 350);

  int width_world = (int)(width / pixelsPerMeter);
  int height_world =  (int)(height / pixelsPerMeter);
  int numSteps = (int)(floor((width_world/2) / stepHeight));
  numSteps = 20;
  //println(numSteps);


  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  //box2d.setGravity(0, -98.1);
  box2d.setGravity(0, -9.81);


  //instantiate the objects in our world:
  centipede = new Centipede(width_world/4f, wheelRadius + 1e-3 + .05);
  centipede.toggle();

  floor = new Step(-width_world/2, 0, width_world, .05);
  topStep = new Step(width_world-10, 0, width_world, height_world);

  //centipede.segments[numSegments-1].printCenter();

  stairs = new Step[numSteps];
  for (int i=0; i < numSteps; i++) {
    stairs[i] = new Step(width_world/2 + i * stepHeight, 0, stepHeight, (i+1) * stepHeight);
  }
}

boolean isRunning = false;
boolean isSaving = false;
void draw() {
  background(255);
  pushMatrix();
  //scale(.5);
  translate(0, 0);
  floor.show();
  topStep.show();
  for (Step s : stairs) {
    s.show();
  }
  centipede.show();  
  //centipede.segments[numSegments-1].printCenter();

  popMatrix();

  displayStatus();

  if (isRunning) {
    //box2d.step();
    box2d.step(1/60f, 100, 100);
    if (isSaving) {
     saveFrame("test/img####.jpg") ;
    }
  }
}

void makeRandomParams() {
  numSegments = (int)random(3, 11);
  wheelRadius = random(25e-3, 100e-3);
  segmentLength = wheelRadius + 30e-3;
  motorTorque = numSegments * 1000000;
  stepHeight = random(15e-3, 100e-3);
  springDamping = random(.75, 1);
}

void displayStatus() {
  String status = "left click = START/STOP || wheel click = RANDOM || ";
  status = status + "right click = RESET || U/D = stepHeight || L/R = numSegments\n";
  status = status + "NumSegments = ";
  status = status + numSegments + "\nWheelRadius = ";
  status = status + wheelRadius + "\nStepHeight= " + stepHeight + "\nSpring damping = " + springDamping;

  fill(0);
  textSize(16);
  text(status, 10, 15);
}

void mousePressed() {
  if (mouseButton == RIGHT) {
    isRunning = false;
    setup();
  } else if (mouseButton == CENTER) {
    makeRandomParams();
    isRunning = false;
    setup();
  } else {
    isRunning = !isRunning;
  }
}

void mouseDragged() {
  if (mouseButton == RIGHT) {
    isRunning = false;
    setup();
  } else if (mouseButton == CENTER) {
    makeRandomParams();
    isRunning = false;
    setup();
  } else {
    isRunning = !isRunning;
  }
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      stepHeight+=.05;
      setup();
      isRunning = false;
    } else if (keyCode == DOWN) {
      stepHeight -= .05;
      stepHeight = stepHeight <= 0 ? .05 : stepHeight;
      setup();
      isRunning = false;
    } else if (keyCode == LEFT) {
      numSegments--;
      numSegments = numSegments <= 0 ? 1 : numSegments;
      setup();
      isRunning = false;
    } else if (keyCode == RIGHT) {
      numSegments++;
      setup();
      isRunning = false;
    } else if (keyCode == ENTER) {
      isRunning = !isRunning;
    }
  } else if (key == ' ') {

    isSaving = !isSaving;
  }
}
