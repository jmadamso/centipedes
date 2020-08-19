import shiffman.box2d.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.collision.shapes.Shape;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.*;
import org.gicentre.utils.stat.*;

//ALL UNITS ARE IN TERMS OF kg, m, s

//parameters:
int numSegments = 6;
float wheelRadius = 100e-3; //mm 
float segmentLength = wheelRadius + 30e-3;
float motorTorque = numSegments * 1000000;
float stepHeight = 0.127; //5 inches to m
float stepWidth = 0.381; //15 inches to m
float springDamping = 1;

//our objects and the world they live in:
Centipede centipede; 
Step floor;
Step topStep;
Step[] stairs;
Box2DProcessing box2d;

//vars for pan, zoom, and drawing
float zoom = 1;
Vec2 offset = new Vec2(0, 0);
Vec2 poffset = new Vec2(0, 0);
Vec2 mouse;

//conversion from box2d meters to onscreen pixels
float pixelsPerMeter = 250;

//vectors and time to calculate acceleration with
float time= 0;
Vec2 lastVel = new Vec2(0, 0);
Vec2 thisVel = new Vec2(0, 0);
Vec2 accel;
float highestAccel_x, highestAccel_y;


//accleration chart and list of points for it. 
//Arraylist allows for easy scrolling
XYChart accelGraph;
PrintWriter outputWriter;

ArrayList<Float> t;
ArrayList<Float> accel_x;
ArrayList<Float> accel_y;

boolean isRunning = false;
void setup() {
  //print("hello, world! it's a good day to be a centipede\n");
  size(600, 600);

  outputWriter = createWriter("results.csv"); 

  int width_world = (int)(width / pixelsPerMeter);
  int numSteps = 30; //how many steps up to e2

  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  box2d.setGravity(0, -9.81);

  //instantiate the centipede, floor, and stairs in our world:
  centipede = new Centipede(width_world/2f - .1, wheelRadius + .06, BODY);
  centipede.toggle();

  floor = new Step(-4 * width_world + width_world/2, 0, 4 * width_world, .05);
  topStep = new Step(width_world/2 + numSteps * stepWidth, 0, width_world, numSteps * stepHeight);
  stairs = new Step[numSteps];
  for (int i=0; i < numSteps; i++) {
    stairs[i] = new Step(width_world/2 + i * stepWidth, 0, stepWidth, (i+1) * stepHeight);
  }

  //now get the graph ready:
  accelGraph = new XYChart(this);
  accelGraph.showXAxis(true); 
  accelGraph.showYAxis(true); 
  accelGraph.setPointColour(color(180, 50, 50, 100));
  accelGraph.setPointSize(2);
  accelGraph.setLineWidth(2);


  //init the arrays
  time = 0;
  t = new ArrayList<Float>();
  accel_x = new ArrayList<Float>();
  accel_y = new ArrayList<Float>();

  highestAccel_x = 0;
  highestAccel_y =0;
}


boolean toggle = false;
void draw() {
  background(255);

  pushMatrix();
  scale(zoom);
  translate(offset.x/zoom, offset.y/zoom);

  centipede.show();  
  floor.show();
  for (Step s : stairs) {
    s.show();
  }
  topStep.show();
  popMatrix();



  if (isRunning) {
    //step at 60hz, doing 20 iterations for velocity, 20 for position
    box2d.step(1/60f, 20, 20);
    time += (1f/60f);
    //println("t = " + time);

    //store the velocity to get acceleration with using dv/dt of segment 2
    thisVel = new Vec2(centipede.segments[2].legBody.getLinearVelocity());
    thisVel = thisVel.sub(lastVel); //dv
    accel = new Vec2(thisVel.mul(60)); // dv/dt
    if (abs(accel.x) > highestAccel_x) {
      highestAccel_x = abs(accel.x);
    }

    if (abs(accel.y) > highestAccel_y) {
      highestAccel_y = abs(accel.y);
    }

    lastVel = new Vec2(centipede.segments[2].legBody.getLinearVelocity());

    updateGraph();


    //println("accel x = "+ accel.x + " accel y = "+ accel.y);
    /*
    toggle = !toggle;
     if (toggle) {
     //save data at 30 fps independant of graphics drawing   
     outputWriter.println(time + "," + accel.x + ","+ accel.y); // Write the coordinate to the file
     }
     */
  }
  displayStatus();
  accelGraph.draw(width/2, 0, width/2, height/2);
}


void displayStatus() {
  String status = "a/z = zoom; left mouse = pan\n";
  status = status + "right click = RESET || U/D = stepHeight || L/R = numSegments\n";
  status = status + "NumSegments = " + numSegments;
  status = status + "\nsegment mass = " + centipede.segments[0].getMass() + " kg";
  status = status + "\ntime = " + nf(time, 1, 1);
  status = status + "\nhighest x accel = " + nf(highestAccel_x, 1, 1) + " m/s^2";
  status = status + "\nhighest y accel = " + nf(highestAccel_y, 1, 1) + " m/s^2";


  fill(0);
  textSize(16);
  text(status, 10, 15);
}

void mousePressed() {
  if (mouseButton == RIGHT) {
    isRunning = false;
    setup();
  } else if (mouseButton == CENTER) {
    isRunning = false;
    setup();
  } else {
    mouse = new Vec2(mouseX, mouseY);
    poffset.set(offset);
  }
}

void mouseDragged() {
  if (mouseButton == RIGHT) {
    isRunning = false;
    setup();
  } else if (mouseButton == CENTER) {
    isRunning = false;
    setup();
  } else {
    offset.x = mouseX - mouse.x + poffset.x;
    offset.y = mouseY - mouse.y + poffset.y;
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
    isRunning = !isRunning;
  } else if (key == 'a') {
    zoom += 0.1;
  } else if (key == 'z') {
    zoom -= 0.1;
  } else if (key == 'q') {
    outputWriter.flush();
    outputWriter.close();
    while (true);
  }
  zoom = constrain(zoom, 0, 100);
}

float[] t_arr;
float[] x_arr;
float[] y_arr;
void updateGraph() {

  t.add(time);
  accel_x.add(accel.x);
  accel_y.add(accel.y);

  //if we get more than this many steps (20 seconds), start removing the earlier ones
  //to make the graph scroll
  if (t.size() > 60 * 20) {
    //println("trying to remove " + accel_x.get(0)+ " with array size " + t.size());
    t.remove(t.get(0)); 
    accel_x.remove(accel_x.get(0)); 
    accel_y.remove(accel_y.get(0));
  }

  //now make an array becase linechart only accepts float[] but arraylists support push/pop.
  //feels clunky but i can't find a more direct method for changing Arraylist<Float> -> float[]
  t_arr = new float[t.size()];
  x_arr = new float[t.size()];
  y_arr = new float[t.size()];

  for (int i = 0; i < t.size(); i++) {
    t_arr[i] = t.get(i);
    x_arr[i] = accel_x.get(i);
    y_arr[i] = accel_y.get(i);
  }

  //finally, adjust the graph and update its data
  accelGraph.setMinY(-highestAccel_y);
  accelGraph.setMaxY(highestAccel_y);
  accelGraph.setMinX(t.get(0));
  accelGraph.setMaxX(t.get(t.size()-1));
  accelGraph.setData(t_arr, y_arr);
}
