class Segment {

  Body segBody;
  Body legBody;
  //Body weight; 

  RevoluteJoint axle;
  RevoluteJointDef rjd;

  //segment consists of leg (wheel) anchored to segment body
  //and is instantiated with an initial position
  Segment(Vec2 pos) {
    
    // Define and create the two bodies
    BodyDef bd = new BodyDef();
    bd.position.set(pos);
    bd.type = BodyType.DYNAMIC;

    segBody = box2d.createBody(bd);
    legBody = box2d.createBody(bd);

    //affix a circle shape to the wheel body
    CircleShape circle = new CircleShape();
    circle.m_radius = wheelRadius;
    FixtureDef fd = new FixtureDef();
    fd.shape = circle;
    fd.density = 3;
    fd.friction = 10;
    fd.restitution = 0;
    legBody.createFixture(fd);


    //affix a rectangle shape to the segment body 
    //as the left/right connections and axle location
    fd = new FixtureDef();
    PolygonShape square = new PolygonShape();
    float w = segmentLength; //dont let the rectangle overlap or stick out
    float h = 5e-3;

    //SET AS BOX takes w/2, h/2 as parameters and centers the box there.
    square.setAsBox(w/2, h/2);

    fd.shape = square;
    fd.density = 1;
    fd.friction = 0;
    fd.restitution = 0;
    segBody.createFixture(fd);

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
    rjd.initialize(segBody, legBody, segBody.getWorldCenter()); //pin these two bodies. anchor to center of rectangle
    rjd.motorSpeed = -PI *2;       // max motor velocity in rad/s; may be unreachable if torque too small
    rjd.maxMotorTorque = motorTorque/numSegments; 
    rjd.enableMotor = false; 
    
    axle = (RevoluteJoint) box2d.world.createJoint(rjd);
  }

  void show(int i) {
    Vec2 pos = segBody.getPosition();

    //to get from world coordinates (meters) to proessing coords (pixels), we need to scale, flip Y, and
    //translate downwards since the Processing canvas has +y being downwards
    pos = pos.mul(pixelsPerMeter);
    pos.y *= -1;
    pos.y += height;
    
    // Get its angle of rotation
    float squareAngle = segBody.getAngle();
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

  boolean isRunning = false;
  void toggleMotor() {
    isRunning = !isRunning;
    axle.enableMotor(isRunning);
  }

  void printCenter() {
    Vec2 pos = segBody.getWorldCenter();
    println("center = (" + pos.x + ", " + pos.y + ")");
  }


}
