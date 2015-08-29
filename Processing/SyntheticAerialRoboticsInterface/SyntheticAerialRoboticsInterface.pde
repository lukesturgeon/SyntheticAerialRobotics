import controlP5.*; //<>//

float     widthCM = 1500; // left to right (in cm)
float     depthCM = 1500; // front to back (in cm)
float     heightCM = 800; // top to bottom (in cm)

float     scaleCM = -1200.0; // default size to scale down to
float     worldRotationX = 0.0;
float     worldRotationY = 0.0;

PVector[] motorPositions;
float[]   motorLengths;
PVector   actorTarget;
PVector   actorPosition;
float     easing = 0.1;

Table     recordData;
int       recordTimer;
boolean   isRecording;
boolean   isPlaying;
int       playbackPosition;

ControlP5 cp5;

void setup() {
  size(1024, 768, P3D);
  smooth(8);

  isRecording = false;
  recordData = new Table();
  recordData.addColumn("x");
  recordData.addColumn("y");
  recordData.addColumn("z");

  motorLengths = new float[4];
  motorPositions = new PVector[4];
  motorPositions[0] = new PVector(-widthCM/2, -heightCM/2, -depthCM/2);
  motorPositions[1] = new PVector(widthCM/2, -heightCM/2, -depthCM/2);
  motorPositions[2] = new PVector(widthCM/2, -heightCM/2, depthCM/2);
  motorPositions[3] = new PVector(-widthCM/2, -heightCM/2, depthCM/2);

  // start in center of floor
  actorTarget  = new PVector(0, heightCM/2, 0);
  actorPosition = actorTarget.get();

  cp5 = new ControlP5(this);
  cp5.addToggle("isRecording")
    .setSize(60, 20);
  cp5.addButton("loadData")
    .setLabel("loaddata...");
  cp5.addButton("playback");
  cp5.addSlider("easing").
    setRange(0.001, 0.5);
}

void update() {

  // move the actor closer to the target
  float dx = actorTarget.x - actorPosition.x;
  float dy = actorTarget.y - actorPosition.y;
  float dz = actorTarget.z - actorPosition.z;
  actorPosition.x += dx * easing;
  actorPosition.y += dy * easing;
  actorPosition.z += dz * easing;

  for (int i = 0; i < 4; i++) {
    motorLengths[i] = actorPosition.dist(motorPositions[i]);
  }

  // are we recording
  if (isRecording && (millis()-recordTimer) > 125) {
    TableRow newData = recordData.addRow();
    newData.setFloat("x", actorTarget.x);
    newData.setFloat("y", actorTarget.y);
    newData.setFloat("z", actorTarget.z);
    recordTimer = millis();
  }

  // are we playing
  else if (isPlaying && (millis()-recordTimer) > 125) {
    // update the target position
    actorTarget.set( 
      recordData.getFloat(playbackPosition, "x"), 
      recordData.getFloat(playbackPosition, "y"), 
      recordData.getFloat(playbackPosition, "z")  ); 

    if (playbackPosition < recordData.getRowCount()-1) {
      playbackPosition++;
    } else {
      isPlaying = false;
    }

    recordTimer = millis();
  }
}

void draw() {
  update();

  background(0, 0, 0);

  pushMatrix();
  translate(width/2, (height/2), scaleCM);
  rotateX(worldRotationX);
  rotateY(worldRotationY);

  //draw frame
  noFill();
  stroke(#444444);
  box(widthCM, heightCM, depthCM);

  // draw floor
  for (int i = 0; i < 10; i++) {
    line(-widthCM/2, heightCM/2, map(i, 0, 10, depthCM/2, -depthCM/2), 
      widthCM/2, heightCM/2, map(i, 0, 10, depthCM/2, -depthCM/2));
    line(map(i, 0, 10, -widthCM/2, widthCM/2), heightCM/2, -depthCM/2, 
      map(i, 0, 10, -widthCM/2, widthCM/2), heightCM/2, depthCM/2);
  }

  // draw cables
  stroke(255);
  for (int i = 0; i < 4; i++) {
    line(motorPositions[i].x, motorPositions[i].y, motorPositions[i].z, 
      actorPosition.x, actorPosition.y, actorPosition.z);
  }
  noStroke();

  // draw actorTarget
  pushMatrix();
  fill(100);
  translate(actorTarget.x, actorTarget.y, actorTarget.z);
  sphere(20);
  popMatrix();

  stroke(50, 50, 0);
  line(  actorTarget.x, actorTarget.y, -depthCM/2, 
    actorTarget.x, actorTarget.y, depthCM/2  );
  line(  -widthCM/2, actorTarget.y, actorTarget.z, 
    widthCM/2, actorTarget.y, actorTarget.z  );
  line(  actorTarget.x, -heightCM/2, actorTarget.z, 
    actorTarget.x, heightCM/2, actorTarget.z  );

  noStroke();

  // draw actorPosition
  pushMatrix();
  fill(255);
  translate(actorPosition.x, actorPosition.y, actorPosition.z);
  sphere(20);
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

  // draw the recorded motion?
  stroke(255, 255, 0);
  noFill();
  beginShape();
  for ( TableRow row : recordData.rows() ) {
    vertex( row.getFloat("x"), row.getFloat("y"), row.getFloat("z") );
  }
  endShape();

  //== end world translate and zoom ==//
  popMatrix();

  // output the current lengths
  text("A = "+motorLengths[0]+"\nB = "+motorLengths[1]+"\nC = "+motorLengths[2]+"\nD = "+motorLengths[3], 20, height-100);
}

void loadData() {
  selectInput("Select a file to playback:", "dataSelected");
}

void dataSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    isRecording = false;
    recordData.clearRows();
    recordData = loadTable(selection.getAbsolutePath(), "header");
  }
}

void isRecording(boolean b) {
  if (b) {
    // start recording
    println("R* START");
  } else {
    // end recording
    saveTable(recordData, "data/"+getUniqueFileName()+".csv");
    println("R* END");
  }

  // set value
  isRecording = b;
}

void playback() {
  if (isRecording) {
    println("ERROR, you shouldn't playback whilst recording");
  }
  // start playback from beginning
  else if (recordData.getRowCount() > 1) {
    playbackPosition = 0;
    isPlaying = true;
  } else {
    println("you haven't recorded any data yet");
  }
}

String getUniqueFileName() {
  String str = "";

  int y = year();
  str += String.valueOf(y);

  int j = month();
  str += "-"+String.valueOf(j);

  int d = day();
  str += "-"+String.valueOf(d);

  int h = hour();
  str += "_"+String.valueOf(h);

  int m = minute();
  str += "-"+String.valueOf(m);

  int s = second();
  str += "-"+String.valueOf(s);

  return str;
}

void mouseDragged() {
  if (keyPressed && key == 'w') {
    // add x/y to the rotation
    worldRotationX -= (mouseY-pmouseY) * 0.01;
    worldRotationY += (mouseX-pmouseX) * 0.01;
  } 

  // lock to Y axis
  else if (keyPressed && key == 'y') {
    // lock to Y axis
    actorTarget.y += mouseY-pmouseY;
    actorTarget.y = constrain(actorTarget.y, -heightCM/2, heightCM/2);
  } 

  // lock to X axis
  else if (keyPressed && key == 'x') {
    float angle = worldRotationY % TWO_PI;
    float absAngle = abs(angle);
    if (absAngle > PI*0.75 && absAngle < PI*1.25) {
      // back
      actorTarget.x -= mouseX-pmouseX;
    } else {
      actorTarget.x += mouseX-pmouseX;
    }
    actorTarget.x = constrain(actorTarget.x, -widthCM/2, widthCM/2);
  } 

  // lock to Z axis
  else if (keyPressed && key == 'z') {
    float angle = worldRotationY % TWO_PI;
    float absAngle = abs(angle);
    // right side
    if (worldRotationY > 0) {
      actorTarget.z += mouseX-pmouseX;
    } else {
      actorTarget.z -= mouseX-pmouseX;
    }
    actorTarget.z = constrain(actorTarget.z, -depthCM/2, depthCM/2);
  } 

  // x3 axis movement
  else if (keyPressed && key == 'q') {
    // take the y as the actor y position
    actorTarget.y += mouseY-pmouseY;

    // take the x ans the depth or width (dpends on orientation)
    float angle = worldRotationY % TWO_PI;
    float absAngle = abs(angle);
    if (absAngle > PI*0.25 && absAngle < PI*0.75) {
      // right side
      if (worldRotationY > 0) {
        actorTarget.z += mouseX-pmouseX;
      } else {
        actorTarget.z -= mouseX-pmouseX;
      }
    } else if (absAngle > PI*1.25 && absAngle<PI*1.75) {
      // left side
      if (worldRotationY > 0) {
        actorTarget.z -= mouseX-pmouseX;
      } else {
        actorTarget.z += mouseX-pmouseX;
      }
    } else if (absAngle > PI*0.75 && absAngle < PI*1.25) {
      // back
      actorTarget.x -= mouseX-pmouseX;
    } else {
      actorTarget.x += mouseX-pmouseX;
    }

    // constrain just in case
    actorTarget.x = constrain(actorTarget.x, -widthCM/2, widthCM/2);
    actorTarget.y = constrain(actorTarget.y, -heightCM/2, heightCM/2);
    actorTarget.z = constrain(actorTarget.z, -depthCM/2, depthCM/2);
  }
}

void mouseWheel(MouseEvent e) {
  // adjust the scale to give the impression of zoom in/out
  float count = e.getCount() * 10;
  scaleCM += count;
}