class Segment {

  Body squareBody;
  Body circleBody;
  Body weight;

  RevoluteJoint axle;
  RevoluteJointDef rjd;


  Segment(Vec2 pos, int type) {
    // Define and create the two bodies
    BodyDef bd = new BodyDef();
    bd.position.set(box2d.coordPixelsToWorld(pos));

    bd.type = BodyType.DYNAMIC;

    squareBody = box2d.createBody(bd);
    circleBody = box2d.createBody(bd);

//now add the weight 
    //Vec2 newPos = pos.add(new Vec2(0, 10));
    //bd.position.set(box2d.coordPixelsToWorld(newPos)); 
    //weight = box2d.createBody(bd);

    // Make the body's shape a circle
    CircleShape circle = new CircleShape();
    circle.m_radius = box2d.scalarPixelsToWorld(wheelRadius);

    //affix a circle to the body as the wheel
    FixtureDef fd = new FixtureDef();
    fd.shape = circle;
    fd.density = 1;
    fd.friction = 1;
    fd.restitution = .5;
    circleBody.createFixture(fd);

    //affix a square to the body as the left/right connections
    fd = new FixtureDef();
    PolygonShape square = new PolygonShape();
    float w = box2d.scalarPixelsToWorld((2 * segmentLength)/2);
    float h = box2d.scalarPixelsToWorld(5/2);


    if (type == LEFT || type == RIGHT) {
      //we only need half the segment
      w = box2d.scalarPixelsToWorld((segmentLength)/2);
    } 
    //SET AS BOX TAKES w/2, h/2 as parameters and places the center of the box there. whyyyy
    square.setAsBox(w, h);


    fd.shape = square;
    // Parameters that affect physics
    fd.density = 1;
    fd.friction = 0;
    fd.restitution = 0;
    squareBody.createFixture(fd);

    //affix the weight to its position
    //fd = new FixtureDef();
    //fd.density = 100;
    //    fd.friction = 0;
    //fd.restitution = 0;
    //weight.createFixture(fd);

    rjd = new RevoluteJointDef();
    rjd.initialize(squareBody, circleBody, squareBody.getWorldCenter());
    rjd.motorSpeed = -PI * 2;       // how fast?
    rjd.maxMotorTorque = motorTorque/numSegments; // how powerful?
    rjd.enableMotor = false; 
    axle = (RevoluteJoint) box2d.world.createJoint(rjd);
  }
  
  



  void show(int i) {
    // We look at each body and get its screen position
    Vec2 pos = box2d.getBodyPixelCoord(squareBody);
    // Get its angle of rotation
    float squareAngle = squareBody.getAngle();
    float circleAngle = circleBody.getAngle();

    pushMatrix();
    rectMode(PConstants.CENTER);
    translate(pos.x, pos.y);

    //rotate to the square angle and draw it:
    rotate(-squareAngle);
    fill(230);
    stroke(0);
    rect(0, 0, 2 * segmentLength, 5);
    rotate(squareAngle);

    //rotate to the wheel angle and draw it:
    rotate(-circleAngle);
    fill(255);
    //noFill();
    strokeWeight(2);
    ellipse(0, 0, 2*wheelRadius, 2*wheelRadius);
    ellipse(0, -wheelRadius + 10, 5, 5);
    rotate(circleAngle);

    //display segment number
    textSize(26);
    fill(0, 102, 153);    
    text(str(i), -10, 10);

    popMatrix();
  }

  boolean isRunning = false;
  void toggleMotor() {
    isRunning = !isRunning;
    axle.enableMotor(isRunning);
  }
}
