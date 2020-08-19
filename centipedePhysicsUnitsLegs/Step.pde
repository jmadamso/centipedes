class Step {
  Body body;
  float stepWidth;
  float stepHeight;

  //we will define step position using the bottom left corner,
  //and use world coordinates (ie, up is positive Y)
  Step(float x, float y, float w, float h) {
    Vec2 pos = new Vec2(x + w/2, y + h/2); //position of center
    stepWidth = w;
    stepHeight = h;

    BodyDef bd = new BodyDef();
    bd.position.set(pos);
    bd.type = BodyType.STATIC;
    body = box2d.createBody(bd);

    //affix a square to the body as the step itself
    PolygonShape square = new PolygonShape();
    //float bW = box2d.scalarPixelsToWorld(w/2);
    //float bH = box2d.scalarPixelsToWorld(h/2);

    //SET AS BOX TAKES HALF THE WIDTH/HEIGHT,
    //and defines the shape to be centered at the body position
    square.setAsBox(w/2, h/2);

    FixtureDef fd = new FixtureDef();
    fd.shape = square;
    // Parameters that affect physics
    fd.density = 1;
    fd.friction = 1;
    fd.restitution = 0;
    body.createFixture(fd);
  }


  void show() {
    Vec2 pos = body.getPosition();
    //pos = box2d.coordWorldToPixels(pos.x,pos.y);
    //pos = box2d.getBodyPixelCoord(body);
    pos = pos.mul(pixelsPerMeter);
    pos.y *= -1;
    pos.y += height;
    noFill();
    stroke(0);
    strokeWeight(2);
    pushMatrix();
    rectMode(PConstants.CENTER);
    translate(pos.x, pos.y);
    rect(0, 0, stepWidth * pixelsPerMeter, stepHeight * pixelsPerMeter);
    popMatrix();
  }

  void printCenter() {
    Vec2 pos = body.getWorldCenter();
    println("center = (" + pos.x + ", " + pos.y + ")");
  }
}
