class Step {
  Vec2 pos;
  Body body;
  float stepWidth;
  float stepHeight;

  Step(float x, float y, float w, float h) {
    pos = new Vec2(x + w/2, y - h/2);
    stepWidth = w;
    stepHeight = h;

    BodyDef bd = new BodyDef();
    bd.position.set(box2d.coordPixelsToWorld(pos));
    bd.type = BodyType.STATIC;
    body = box2d.createBody(bd);
    
    //affix a square to the body as the step itself
    PolygonShape square = new PolygonShape();
    float bW = box2d.scalarPixelsToWorld(w/2);
    float bH = box2d.scalarPixelsToWorld(h/2);
    
    //SET AS BOX TAKES HALF THE WIDTH/HEIGHT:
    square.setAsBox(bW, bH);
    
    FixtureDef fd = new FixtureDef();
    fd.shape = square;
    // Parameters that affect physics
    fd.density = 1;
    fd.friction = 1;
    fd.restitution = 0;
    body.createFixture(fd);
  }


  void show() {
    
    Vec2 pos = box2d.getBodyPixelCoord(body);
    
    noFill();
    stroke(0);
    strokeWeight(2);
    pushMatrix();
    rectMode(PConstants.CENTER);
    translate(pos.x, pos.y);
    rect(0, 0, stepWidth, stepHeight);
    popMatrix();
  }
}
