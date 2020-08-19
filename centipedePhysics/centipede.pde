class Centipede {
  //centipede is a series of segments with joints and springs
  Segment[] segments;

  RevoluteJoint[] joints;
  RevoluteJointDef rjd;

  DistanceJoint[] springs;
  DistanceJointDef djd;

  final int numJoints = numSegments - 1;

  Centipede() {
    segments = new Segment[numSegments]; //the actual array of segments
    joints = new RevoluteJoint[numJoints];//the joints themselves
    springs = new DistanceJoint[numJoints]; //the springs between segments

    //populate the array with segments. We technically only need to 
    //define one position but this allocating them in position works 
    //just fine
    Vec2  pos;
    for (int i = 0; i < numSegments; i++) {
      pos = new Vec2(i * 2 * segmentLength - numSegments * segmentLength, height - height/4);
      if (i == 0) {
        //if leftmost
        segments[i] = new Segment(pos, LEFT);
      } else if (i == numSegments-1) {
        //if rightmost
        segments[i] = new Segment(pos, RIGHT);
      } else {
        segments[i] = new Segment(pos, -1);
      }
    }

    //loop through and connect all segments;
    //this loop goes once less than # segments so i+1 in the arrays is fine
    Vec2 a, b;
    for (int i = 0; i < numJoints; i++) {

      //definitions for the current joint
      rjd = new RevoluteJointDef();
      rjd.bodyA =  segments[i].squareBody;
      rjd.bodyB =  segments[i+1].squareBody;

      //define and apply the joint anchors ie, where the two bodies get pinned together.
      //these are defined LOCALLY in each body's own reference frame
      a = new Vec2(box2d.scalarPixelsToWorld(segmentLength), box2d.scalarPixelsToWorld(0));
      b = new Vec2(box2d.scalarPixelsToWorld(-segmentLength), box2d.scalarPixelsToWorld(0));
      rjd.localAnchorA = a;
      rjd.localAnchorB = b;
      

      //now create the joints themselves:
      joints[i] = (RevoluteJoint) box2d.world.createJoint(rjd);

      //now the springs:

      //define the spring anchors ie, where the two bodies get pulled together from
      //and initialize with them. Distance joints are funny and might not actually be
      //doing what i think
      djd = new DistanceJointDef();
      Vec2 posA = box2d.getBodyPixelCoord(segments[i].squareBody); 
      a = box2d.coordPixelsToWorld(posA);
      Vec2 posB = box2d.getBodyPixelCoord(segments[i+1].squareBody);
      b = box2d.coordPixelsToWorld(posB);
      djd.initialize(segments[i].squareBody, segments[i+1].squareBody, a, b);

      //damping ratio parameters:
      djd.frequencyHz = 20;
      djd.dampingRatio = springDamping;

      springs[i] = (DistanceJoint) box2d.world.createJoint(djd);
    }
  }


  void show() {
    //iterate backwards from front
    for (int i = numSegments-1; i >= 0; i--) {
      segments[i].show(i);
    }
  }

  void toggle() {
    //iterate backwards from front
    for (int i = numSegments-1; i >= 0; i--) {
      segments[i].toggleMotor();
    }
  }
  

}
