static final int WHEELS = 0;
static final int LEGS = 1;
static final int BODY = 2;

class Centipede {
  //centipede is a series of segments with joints and springs
  Segment[] segments;

  RevoluteJoint[] joints;
  RevoluteJointDef rjd;

  DistanceJoint[] springs;
  DistanceJointDef djd;

  Vec2 pos;
  final int numJoints = numSegments - 1;

  Centipede(float x, float y, int type) {
    joints = new RevoluteJoint[numJoints];//the joints themselves
    springs = new DistanceJoint[numJoints]; //the springs between segments


    //populate the array with segments. We technically only need to 
    //define one position but this allocating them in position works 
    //just fine
    switch(type) {
    case WHEELS:
    default:
      segments = new WheelSegment[numSegments]; 
      for (int i = 0; i < numSegments; i++) {
        pos = new Vec2(x - i * 2 * segmentLength, y);
        if (i == 0 || i == numSegments-1) {
          segments[i] = new WheelSegment(pos, true);
        } else {
          segments[i] = new WheelSegment(pos, false);
        }
      }
      break;

    case LEGS:
      segments = new LegSegment[numSegments]; 
      for (int i = 0; i < numSegments; i++) {
        pos = new Vec2(x - i * 2 * segmentLength, y);
        if (i == 0 || i == numSegments-1) {
          segments[i] = new LegSegment(pos, true, i * 2 * PI/(numSegments));
        } else {
          segments[i] = new LegSegment(pos, false, i * 2 * PI/(numSegments));
        }
      }
      break;

    case BODY:
      segments = new BodySegment[numSegments]; 
      for (int i = 0; i < numSegments; i++) {
        pos = new Vec2(x - i * 2 * segmentLength, y);
        if (i == 0 || i == numSegments-1) {
          segments[i] = new BodySegment(pos, true, i * 2 * PI/(numSegments));
        } else {
          segments[i] = new BodySegment(pos, false, i * 2 * PI/(numSegments));
        }
      }
      break;
    }

    //loop through and connect all segments;
    //this loop goes once less than # segments so i+1 in the arrays is fine
    Vec2 a, b;
    for (int i = 0; i < numJoints; i++) {

      //definitions for the current joint
      rjd = new RevoluteJointDef();
      rjd.bodyA =  segments[i].segmentBody;
      rjd.bodyB =  segments[i+1].segmentBody;

      //define and apply the joint anchors ie, where the two bodies get pinned together.
      //these are defined LOCALLY in each body's own reference frame
      a = new Vec2(segmentLength, 0); //body1 right side
      b = new Vec2(-segmentLength, 0); //body2 left side
      rjd.localAnchorA = a;
      rjd.localAnchorB = b;
      rjd.collideConnected = false;


      //now create the joints themselves:
      joints[i] = (RevoluteJoint) box2d.world.createJoint(rjd);

      //now the springs:

      //define the spring anchors ie, where the two bodies get pulled together from
      //and initialize with them. Distance joints are funny and might not actually be
      //doing what i think
      djd = new DistanceJointDef();
      Vec2 posA = segments[i].segmentBody.getWorldCenter(); 
      Vec2 posB = segments[i+1].segmentBody.getWorldCenter(); 

      djd.initialize(segments[i].segmentBody, segments[i+1].segmentBody, posA, posB);

      //damping ratio parameters:
      djd.frequencyHz = 30;
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
    for (int i = numSegments-1; i >= 0; i--) {
      segments[i].toggleMotor();
    }
  }
}
