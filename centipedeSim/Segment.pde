abstract class Segment {

  Body segmentBody;
  Body legBody;
  //Body weight; 

  RevoluteJoint axle;
  RevoluteJointDef rjd;

  FixtureDef fd;

  //segment consists of leg anchored to segment body
  //and is instantiated with an initial position
  Segment(Vec2 pos, boolean endpoint) {

    // Define and create the two bodies
    BodyDef bd = new BodyDef();
    bd.position.set(pos);
    bd.type = BodyType.DYNAMIC;

    segmentBody = box2d.createBody(bd);
    legBody = box2d.createBody(bd);

    //affix a rectangle shape to the segment body 
    //as the left/right connections and axle location
    fd = new FixtureDef();
    PolygonShape square = new PolygonShape();

    float w = endpoint ? segmentLength : 2*segmentLength;
    float h = 5e-3;

    //takes w/2, h/2 as parameters and centers the box there.
    square.setAsBox(w/2, h/2);

    fd.shape = square;
    fd.density = 15;
    fd.friction = 0;
    fd.restitution = 0;
    segmentBody.createFixture(fd);

    //now add an offset weight to allow gravity to help it stop curling backwards [IN PROGRESS]
    //Vec2 newPos = pos.add(new Vec2(0, 10e-3));
    //bd.position.set(newPos); 
    //weight = box2d.createBody(bd);

    //affix the weight to its position
    //fd = new FixtureDef();
    //fd.density = 100;
    //fd.friction = 0;
    //fd.restitution = 0;
    //weight.createFixture(fd);

    rjd = new RevoluteJointDef(); 
    rjd.initialize(segmentBody, legBody, segmentBody.getWorldCenter()); //pin these two bodies. anchor to center of rectangle
    rjd.motorSpeed = -PI *2;       // max motor velocity in rad/s; may be unreachable if torque too small
    rjd.maxMotorTorque = motorTorque/numSegments; 
    rjd.enableMotor = false; 
    axle = (RevoluteJoint) box2d.world.createJoint(rjd);
  }


  boolean isRunning = false;
  void toggleMotor() {
    isRunning = !isRunning;
    axle.enableMotor(isRunning);
  }

  float getMass() {
    return legBody.getMass() + segmentBody.getMass();
  }

  abstract void show(int i);
}


class WheelSegment extends Segment {

  WheelSegment(Vec2 pos, boolean endpoint) {
    super(pos, endpoint); 

    //affix a circle shape to the leg body
    CircleShape circle = new CircleShape();
    circle.m_radius = wheelRadius;
    fd = new FixtureDef();
    fd.shape = circle;
    fd.density = 24;
    fd.friction = 1;
    fd.restitution = 0;
    legBody.createFixture(fd);
  }

  void show(int i) {
    Vec2 pos = segmentBody.getPosition();

    //to get from world coordinates (meters) to proessing coords (pixels), we need to scale, flip Y, and
    //translate downwards since the Processing canvas has +y being downwards
    pos = pos.mul(pixelsPerMeter);
    pos.y *= -1;
    pos.y += height;

    // Get its angle of rotation
    float squareAngle = segmentBody.getAngle();
    float circleAngle = legBody.getAngle();

    pushMatrix();  //save the current canvas position before we change it to draw
    rectMode(PConstants.CENTER);
    translate(pos.x, pos.y);

    //rotate to the square angle and draw it:
    rotate(-squareAngle);
    fill(230);
    stroke(0);
    rect(0, 0, 2 * segmentLength * pixelsPerMeter, 5);
    rotate(squareAngle);

    //rotate to the wheel angle and draw it:
    rotate(-circleAngle);
    fill(255);
    //noFill();
    strokeWeight(2);
    ellipse(0, 0, 2 * wheelRadius * pixelsPerMeter, 2 * wheelRadius * pixelsPerMeter);
    ellipse(0, -wheelRadius * pixelsPerMeter + 10, 5, 5);
    rotate(circleAngle);

    //display segment number
    textSize(26);
    fill(0, 102, 153);    
    text(str(i), -10, 10);

    popMatrix();   //restore the canvas position after drawing
  }
}

class LegSegment extends Segment {

  LegSegment(Vec2 pos, boolean endpoint, float angle) {
    super(pos, endpoint);
    //affix a leg to the legBody
    PolygonShape leg = new PolygonShape();
    float w = 5e-3;
    float h = 2 * wheelRadius;
    leg.setAsBox(w/2, h/2);

    fd = new FixtureDef();

    fd.shape = leg;
    fd.density = 150;
    fd.friction = 5;
    fd.restitution = 0;
    legBody.createFixture(fd);
    legBody.setTransform(legBody.getWorldCenter(), angle); //rotate it
  }

  void show(int i) {
    // We look at each body and get its screen position
    Vec2 pos = segmentBody.getPosition();

    pos = pos.mul(pixelsPerMeter);
    pos.y *= -1;
    pos.y += height;
    // Get its angle of rotation
    float segmentAngle = segmentBody.getAngle();
    float legAngle = legBody.getAngle();

    pushMatrix();
    rectMode(PConstants.CENTER);
    translate(pos.x, pos.y);

    //rotate to the square angle and draw it:
    rotate(-segmentAngle);
    fill(230);
    stroke(0);
    rect(0, 0, 2 * segmentLength * pixelsPerMeter, 1e-3 * pixelsPerMeter);
    rotate(segmentAngle) ;

    //rotate to the leg angle and draw it:
    rotate(-legAngle);
    fill(255);
    //noFill();
    strokeWeight(2);
    rect(0, 0, 5e-3 * pixelsPerMeter, 2 * wheelRadius * pixelsPerMeter );
    rotate(legAngle);

    //display segment number
    //textSize(26);
    //fill(0, 102, 153);    
    //text(str(i), -10, 10);

    popMatrix();
  }
}

class BodySegment extends Segment {
  Body segBody;
  float bodyW = segmentLength/1.5;
  float bodyH = segmentLength/2; 

  BodySegment(Vec2 pos, boolean endpoint, float angle) {
    super(pos, endpoint);

    // Define the bulk of the body
    BodyDef bd = new BodyDef();
    bd.position.set(pos);
    bd.type = BodyType.DYNAMIC;
    segBody = box2d.createBody(bd);

    //affix a leg to the legBody
    PolygonShape leg = new PolygonShape();
    float w = 5e-3;
    float h = 2 * wheelRadius;
    leg.setAsBox(w/2, h/2);

    fd = new FixtureDef();
    fd.shape = leg;
    fd.density = 150;
    fd.friction = 5;
    fd.restitution = 0;
    legBody.createFixture(fd);
    legBody.setTransform(legBody.getWorldCenter(), angle); //rotate it

    //affix the bulk of the body 
    FixtureDef fd2 = new FixtureDef();
    PolygonShape b = new PolygonShape();
    b.setAsBox(bodyW/2, bodyH/2); //dont forget this takes width/2,height/2 as params
    fd2.shape = b;
    fd2.density = 1;
    fd2.friction = 5;
    fd2.restitution = 0;
    segBody.createFixture(fd2);

    //finally, weld the body to the spine
    WeldJointDef wjd = new WeldJointDef();
    wjd.bodyA = segmentBody;
    wjd.bodyB = segBody; //horrible names, i know and am sorry :(
    wjd.referenceAngle = 0;
    box2d.world.createJoint(wjd);
  }

  void show(int i) {
    // We look at each body and get its screen position
    Vec2 pos = segmentBody.getPosition();

    pos = pos.mul(pixelsPerMeter);
    pos.y *= -1;
    pos.y += height;
    // Get its angle of rotation
    float segmentAngle = segmentBody.getAngle();
    float legAngle = legBody.getAngle();
    float bodyAngle = segBody.getAngle();

    pushMatrix();
    rectMode(PConstants.CENTER);
    translate(pos.x, pos.y);

    //rotate to the angle and draw the spine:
    rotate(-segmentAngle);
    fill(230);
    stroke(0);
    rect(0, 0, 2 * segmentLength * pixelsPerMeter, 1e-3 * pixelsPerMeter);
    rotate(segmentAngle) ;

    //rotate to the body angle and draw it
    rotate(-bodyAngle) ;
    rect(0, 0, bodyW * pixelsPerMeter, bodyH * pixelsPerMeter);
    rotate(bodyAngle) ;

    //rotate to the leg angle and draw it:
    rotate(-legAngle);
    fill(255);
    //noFill();
    strokeWeight(2);
    rect(0, 0, 5e-3 * pixelsPerMeter, 2 * wheelRadius * pixelsPerMeter );
    rotate(legAngle);

    //display segment number
    //textSize(26);
    //fill(0, 102, 153);    
    //text(str(i), -10, 10);

    popMatrix();
  }
}
