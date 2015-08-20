import controlP5.*;

float widthMM = 1000; // left to right (in mm)
float depthMM = 1000; // front to back (in mm)
float heightMM = 800; // top to bottom (in mm)

float scaleMM = -1000.0; // default size to scale down to
float worldRotationX = 0.0;
float worldRotationY = 0.0;

PVector[] motorPositions = new PVector[4];
float[] motorLengths = new float[4];
PVector actorPosition = new PVector();

ControlP5 cp5;

void setup() {
  size(1024, 768, P3D);
  smooth(8);

  motorPositions[0] = new PVector(-widthMM/2, -heightMM/2, -depthMM/2);
  motorPositions[1] = new PVector(widthMM/2, -heightMM/2, -depthMM/2);
  motorPositions[2] = new PVector(widthMM/2, -heightMM/2, depthMM/2);
  motorPositions[3] = new PVector(-widthMM/2, -heightMM/2, depthMM/2);

  // start in center of floor
  actorPosition.set(0, heightMM/2, 0);

  cp5 = new ControlP5(this);
  cp5.addSlider("scaleMM").
    setRange(-1500, 1500).
    setValue(scaleMM).
    setSize(150, 20);
}

void update() {
  for (int i = 0; i < 4; i++) {
    motorLengths[i] = ceil( actorPosition.dist(motorPositions[i]) );
  }
}

void draw() {
  update();

  background(0);

  pushMatrix();
  translate(width/2, height/2, scaleMM);
  rotateX(worldRotationX);
  rotateY(worldRotationY);

  //draw frame
  noFill();
  stroke(255);
  box(widthMM, heightMM, depthMM);

  // draw floor
  for (int i = 0; i < 10; i++) {
    line(-widthMM/2, heightMM/2, map(i, 0, 10, depthMM/2, -depthMM/2), 
      widthMM/2, heightMM/2, map(i, 0, 10, depthMM/2, -depthMM/2));
    line(map(i, 0, 10, -widthMM/2, widthMM/2), heightMM/2, -depthMM/2, 
      map(i, 0, 10, -widthMM/2, widthMM/2), heightMM/2, depthMM/2);
  }

  // draw cables
  for (int i = 0; i < 4; i++) {
    line(motorPositions[i].x, motorPositions[i].y, motorPositions[i].z, 
      actorPosition.x, actorPosition.y, actorPosition.z);
  }

  noStroke();

  // draw actor
  pushMatrix();
  fill(255);
  translate(actorPosition.x, actorPosition.y, actorPosition.z);
  sphere(10);
  popMatrix();

  // draw motor A
  pushMatrix();
  fill(255, 0, 0);
  translate(motorPositions[0].x, motorPositions[0].y, motorPositions[0].z);
  sphere(10);
  popMatrix();

  // draw motor B
  pushMatrix();
  fill(255, 255, 0);
  translate(motorPositions[1].x, motorPositions[1].y, motorPositions[1].z);
  sphere(10);
  popMatrix();

  // draw motor C
  pushMatrix();
  fill(255, 0, 255);
  translate(motorPositions[2].x, motorPositions[2].y, motorPositions[2].z);
  sphere(10);
  popMatrix();

  // draw motor D
  pushMatrix();
  fill(255, 255, 255);
  translate(motorPositions[3].x, motorPositions[3].y, motorPositions[3].z);
  sphere(10);
  popMatrix();

  //== end world translate and zoom ==//
  popMatrix();

  // output the current lengths
  text("A = "+motorLengths[0]+"\nB = "+motorLengths[1]+"\nC = "+motorLengths[2]+"\nD = "+motorLengths[3], 20, height-100);
}


void mouseDragged() {
  if (mouseButton == RIGHT) {
    // add x/y to the rotation
    worldRotationX -= (mouseY-pmouseY) * 0.01;
    worldRotationY += (mouseX-pmouseX) * 0.01;
  } else {
    // take the y as the actor y position
    actorPosition.y += mouseY-pmouseY;

    // take the x ans the depth or width (dpends on orientation)
    float angle = worldRotationY % TWO_PI;
    float absAngle = abs(angle);
    if (absAngle > PI*0.25 && absAngle < PI*0.75) {
      // right side
      if (worldRotationY > 0) {
        actorPosition.z += mouseX-pmouseX;
      } else {
        actorPosition.z -= mouseX-pmouseX;
      }
    } else if (absAngle > PI*1.25 && absAngle<PI*1.75) {
      // left side
      if (worldRotationY > 0) {
        actorPosition.z -= mouseX-pmouseX;
      } else {
        actorPosition.z += mouseX-pmouseX;
      }
    } else if (absAngle > PI*0.75 && absAngle < PI*1.25) {
      // back
      actorPosition.x -= mouseX-pmouseX;
    } else {
      actorPosition.x += mouseX-pmouseX;
    }

    // constrain just in case
    actorPosition.x = constrain(actorPosition.x, -widthMM/2, widthMM/2);
    actorPosition.y = constrain(actorPosition.y, -heightMM/2, heightMM/2);
    actorPosition.z = constrain(actorPosition.z, -depthMM/2, depthMM/2);
  }
}