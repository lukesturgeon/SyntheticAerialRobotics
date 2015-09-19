class Target3d extends PVector {

  PVector  velocity;
  PVector  acceleration;

  float    maxSpeed;
  float    damping;
  float    mass;
  

  float    minAttractDistanceCM;
  float    maxAttractDistanceCM;
  float    minRepelDistanceCM;
  float    maxRepelDistanceCM;

  float    screenX, screenY;
  float    _prevX, _prevY, _prevZ;

  Target3d(float _x, float _y, float _z) {
    super(_x, _y, _z);
    acceleration = new PVector();
    velocity = new PVector();

    maxSpeed = 1;
    damping = 0.95;
    mass = 10.0;
    wandertheta = 0.0;

    maxAttractDistanceCM = 5.0;
    maxAttractDistanceCM = 200.0;
    minRepelDistanceCM = 5.0;
    maxRepelDistanceCM = 200.0;
  }

  /*PVector attract(PVector target) {
    PVector force = PVector.sub(this, target);
    float distance = force.mag();
    distance = constrain(distance, minAttractDistanceCM, maxAttractDistanceCM); //limit the distance to avoid error (5cm-1m)
    force.normalize();
    float strength = (mass * mass) / (distance * distance);
    force.mult(strength);
    return force;
  }

  PVector repel(PVector target) {
    PVector force = PVector.sub(this, target);
    float distance = force.mag();
    distance = constrain(distance, minRepelDistanceCM, maxRepelDistanceCM); //limit the distance to avoid error (5cm-1m)
    force.normalize();
    float strength = (-1 * mass * mass) / (distance * distance);
    force.mult(strength);
    return force;
  }*/

  void seek(PVector target, float maxForce) {
    PVector desired = PVector.sub(target, this);
    desired.normalize();
    desired.mult(maxSpeed);
    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxForce);
    applyForce(steer);
  }

  void arrive(PVector target, float maxForce, float distance) {
    PVector desired = PVector.sub(target, this);
    float d = desired.mag();
    desired.normalize();
    if (d < distance) {
      // we are close so slow down
      float m = map(d, 0, distance, 0, maxSpeed);
      desired.mult(m);
    } else {
      // move at max speed
      desired.mult(maxSpeed);
    }    
    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxForce);
    applyForce(steer);
  }
  
  /*PVector arrive(PVector target, float distance, float force) {
    PVector desired = PVector.sub(this, target);
    float d = desired.mag();
    desired.normalize();
    if (d < distance) {
      // we are close so slow down
      float m = map(d, 0, distance, 0, maxSpeed);
      desired.mult(m);
    } else {
      // move at max speed
      desired.mult(maxSpeed);
    }    
    PVector steer = PVector.sub(desired, velocity);
    steer.limit(force);
    return steer;
  }*/

  PVector spring(PVector target, float springLength, float springStrength) {
    PVector force = PVector.sub(target, this);
    float distance = force.mag();
    float stretch = distance - springLength;
    force.normalize();
    force.mult(-springStrength * stretch);
    return force;
  }

  void stayInsideBox(Box3d box) {
    // x axis = width
    if (x-box.leftMargin < 0) {
      PVector desired = new PVector(maxSpeed, velocity.y, velocity.z);
      PVector steer = PVector.sub(desired, velocity);
      //steer.limit(maxForce);
      applyForce(steer);
    } else if (box.rightMargin-x < 0) {
      PVector desired = new PVector(-maxSpeed, velocity.y, velocity.z);
      PVector steer = PVector.sub(desired, velocity);
      //steer.limit(maxForce*2);
      applyForce(steer);
    } 

    // y axis = height
    else if (box.bottomMargin-y < 0) {
      PVector desired = new PVector(velocity.x, maxSpeed, velocity.z);
      PVector steer = PVector.sub(velocity, desired);
      //steer.limit(maxForce);
      applyForce(steer);
    } else if (y-box.topMargin < 0) {
      PVector desired = new PVector(velocity.x, -maxSpeed, velocity.z);
      PVector steer = PVector.sub(velocity, desired);
      //steer.limit(maxForce);
      applyForce(steer);
    }

    // z axis = depth
    else if (z-box.backMargin < 0) {
      PVector desired = new PVector(velocity.x, velocity.y, maxSpeed);
      PVector steer = PVector.sub(desired, velocity);
      //steer.limit(maxForce);
      applyForce(steer);
    } else if (box.frontMargin-z < 0) {
      PVector desired = new PVector(velocity.x, velocity.y, -maxSpeed);
      PVector steer = PVector.sub(desired, velocity);
      //steer.limit(maxForce);
      applyForce(steer);
    }
  }

  void applyForce(PVector force) {
    PVector f = PVector.div(force, mass);// f = m * a (newtons second law)
    acceleration.add(f);
  }

  void update() {
    velocity.add(acceleration);
    velocity.mult(damping);
    velocity.limit(maxSpeed);
    this.add(velocity);
    acceleration.mult(0);
  }

  boolean hasChanged() {
    if (this.x != _prevX || this.y != _prevY || this.z != _prevZ) {
      _prevX = this.x;
      _prevY = this.y;
      _prevZ = this.z;
      return true;
    } else {
      return false;
    }
  }

  void calculate2d() {
    screenX = screenX(this.x, this.y, this.z);
    screenY = screenY(this.x, this.y, this.z);
  }

  Target3d get() {
    return new Target3d(this.x, this.y, this.z);
  }
}