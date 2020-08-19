import shiffman.box2d.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.collision.shapes.Shape;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.*;

//parameters:
int numSegments = 6;
float wheelRadius = 50; 
float segmentLength = wheelRadius + 10;
float motorTorque = numSegments * 1000000;
int stepHeight = 200;
float springDamping = 1;

//our objects and the world they live in:
Centipede centipede; 
Step floor;
Step topStep;
Step[] stairs;

Box2DProcessing box2d;

float zoom = 1;

void setup() {
  //print("hello, world! it's a good day to be a centipede\n");
  size(1000, 700);

  int numSteps = (width/2) / stepHeight;

  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  box2d.setGravity(0, -98.1);
  //box2d.setGravity(0, -9.81);


  //instantiate the objects in our world:
  centipede = new Centipede();
  centipede.toggle();

  floor = new Step(-width/2, height, width, 1);
  topStep = new Step(width-10, height-stepHeight*numSteps, width, 1);

  stairs = new Step[numSteps];
  for (int i=0; i < numSteps; i++) {
    stairs[i] = new Step(width/2 + i * stepHeight, height, stepHeight, (i+1) * stepHeight);
  }
}

boolean isRunning = false;
void draw() {
  background(255);
  pushMatrix();
  scale(.65);
  translate(width/3, height/2);
  floor.show();
  topStep.show();
  for (Step s : stairs) {
    s.show();
  }
  centipede.show();
  popMatrix();

  displayStatus();

  if (isRunning) {
    box2d.step();
  }
}

void makeRandomParams() {
  numSegments = (int)random(3, 10);
  wheelRadius = random(15, 60);
  segmentLength = wheelRadius + 10;
  motorTorque = numSegments * 1000000;
  stepHeight = (int)random(15, 100);
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
      stepHeight+=5;
      setup();
      isRunning = false;
    } else if (keyCode == DOWN) {
      stepHeight -= 5;
      stepHeight = stepHeight <= 0 ? 1 : stepHeight;
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
    makeRandomParams();
    setup();
    isRunning = false;
  }
}
