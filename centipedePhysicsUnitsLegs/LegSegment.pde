class LegSegment {

  Body segmentBody;
  Body legBody;
  Body weight;

  RevoluteJoint axle;
  RevoluteJointDef rjd;

  LegSegment(Vec2 pos, int type, float angle) {
    // Define and create the two bodies
    BodyDef bd = new BodyDef();
    bd.position.set(pos);
    bd.type = BodyType.DYNAMIC;

    segmentBody = box2d.createBody(bd);
    legBody = box2d.createBody(bd);



    //now add the weight 
    //Vec2 newPos = pos.add(new Vec2(0, 10));
    //bd.position.set(box2d.coordPixelsToWorld(newPos)); 
    //weight = box2d.createBody(bd);

    //affix a leg to the legBody
    PolygonShape leg = new PolygonShape();
    float w = 5e-3;
    float h = 2 * wheelRadius;
    leg.setAsBox(w/2, h/2);

    FixtureDef fd = new FixtureDef();

    fd.shape = leg;
    fd.density = 150;
    fd.friction = 5;
    fd.restitution = 0;
    legBody.createFixture(fd);
    legBody.setTransform(legBody.getWorldCenter(), angle); //rotate it
    //legBody.setAngularVelocity(2 * PI);


    //affix a rectangle shape to the segment body 
    //as the left/right connections and axle location
    fd = new FixtureDef();
    PolygonShape seg = new PolygonShape();
    w = type * segmentLength ; 
    h = 1e-3;

    //SET AS BOX TAKES w/2, h/2 as parameters and places the center of the box there.
    seg.setAsBox(w/2, h/2);

    fd.shape = seg;
    fd.density = 150;
    fd.friction = 0;
    fd.restitution = 0;
    segmentBody.createFixture(fd);

    //affix the weight to its position
    //fd = new FixtureDef();
    //fd.density = 100;
    //    fd.friction = 0;
    //fd.restitution = 0;
    //weight.createFixture(fd);

    rjd = new RevoluteJointDef(); 
    rjd.initialize(segmentBody, legBody, segmentBody.getWorldCenter()); //pin these two bodies. anchor to center of rectangle
    rjd.motorSpeed = -PI *2;       // how fast?
    rjd.maxMotorTorque = motorTorque/numSegments; // how powerful?
    rjd.collideConnected = false;
    rjd.enableMotor = false; 
    axle = (RevoluteJoint) box2d.world.createJoint(rjd);
  }





  void show(int i) {
    // We look at each body and get its screen position
    Vec2 pos = segmentBody.getPosition();
    //pos = box2d.getBodyPixelCoord(squareBody);
    //pos = box2d.coordWorldToPixels(pos.x,pos.y);
    //pos = pos.mul(pixelsPerMeter);

    //pos = box2d.getBodyPixelCoord(squareBody);
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

  boolean isRunning = false;
  void toggleMotor() {
    isRunning = !isRunning;
    axle.enableMotor(isRunning);
  }

  void printCenter() {
    Vec2 pos = segmentBody.getWorldCenter();
    println("center = (" + pos.x + ", " + pos.y + ")");
  }

  float getMass() {
    return legBody.getMass() + segmentBody.getMass();
  }
}
