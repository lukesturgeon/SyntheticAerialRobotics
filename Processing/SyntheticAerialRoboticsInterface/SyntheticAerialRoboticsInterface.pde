import controlP5.*; //<>//

final float     WIDTH_CM = 1500; // left to right (in cm)
final float     DEPTH_CM = 1500; // front to back (in cm)
final float     HEIGHT_CM = 800; // top to bottom (in cm)
final int       NUM_MOTORS = 4; // controls the loops and settings

float     scaleCM = -1200.0; // default size to scale down to
float     worldRotationX = 0.0;
float     worldRotationY = 0.0;

Motor3D[] motor;
PVector   actorTarget;
PVector   actorTarget2D;
PVector   actorPosition;
float     easing = 0.1;

Table     recordData;
int       recordTimer;
boolean   isRecording;
boolean   isPlaying;
int       playbackPosition;

ControlP5 cp5;
WarningSystem warning;

Serial3D serial;

void setup() {
  size(1400, 800, P3D);
  smooth(8);

  cp5_init();

  warning = new WarningSystem();

  isRecording = false;
  recordData = new Table();
  recordData.addColumn("x");
  recordData.addColumn("y");
  recordData.addColumn("z");

  motor = new Motor3D[4];
  motor[0] = new Motor3D(-WIDTH_CM/2, -HEIGHT_CM/2, -DEPTH_CM/2);
  motor[0].setLabel("MOTOR A");
  motor[1] = new Motor3D(WIDTH_CM/2, -HEIGHT_CM/2, -DEPTH_CM/2);
  motor[1].setLabel("MOTOR B");
  motor[2] = new Motor3D(WIDTH_CM/2, -HEIGHT_CM/2, DEPTH_CM/2);
  motor[2].setLabel("MOTOR C");
  motor[3] = new Motor3D(-WIDTH_CM/2, -HEIGHT_CM/2, DEPTH_CM/2);
  motor[3].setLabel("MOTOR D");

  // start in center of floor
  actorTarget  = new PVector(0, HEIGHT_CM/2, 0);
  actorTarget2D = new PVector();
  actorPosition = actorTarget.get();

  // connect to arduino
  serial = new Serial3D();
  warning.arduinoConnected = serial.connect(this, "/dev/tty.usbmodem411", 115200);
}

void update() {

  // move the actor closer to the target
  float dx = actorTarget.x - actorPosition.x;
  float dy = actorTarget.y - actorPosition.y;
  float dz = actorTarget.z - actorPosition.z;
  actorPosition.x += dx * easing;
  actorPosition.y += dy * easing;
  actorPosition.z += dz * easing;

  for (int i = 0; i < NUM_MOTORS; i++) {
    motor[i].calculateLengthTo( actorPosition );
    Slider s = (Slider) cp5.getController("cp5_length"+i);
    s.setValue(motor[i].getLengthCM());
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

  // run position maths
  update();

  // redraw interface
  background(0, 0, 0);  

  pushMatrix();
  translate(width/2, (height/2), scaleCM);
  rotateX(worldRotationX);
  rotateY(worldRotationY);


  //draw frame
  noFill();
  stroke(#5E6E8E);
  box(WIDTH_CM, HEIGHT_CM, DEPTH_CM);

  // draw floor
  for (int i = 0; i < 10; i++) {
    line(-WIDTH_CM/2, HEIGHT_CM/2, map(i, 0, 10, DEPTH_CM/2, -DEPTH_CM/2), 
      WIDTH_CM/2, HEIGHT_CM/2, map(i, 0, 10, DEPTH_CM/2, -DEPTH_CM/2));
    line(map(i, 0, 10, -WIDTH_CM/2, WIDTH_CM/2), HEIGHT_CM/2, -DEPTH_CM/2, 
      map(i, 0, 10, -WIDTH_CM/2, WIDTH_CM/2), HEIGHT_CM/2, DEPTH_CM/2);
  }

  // draw cables
  stroke(255);
  for (int i = 0; i < 4; i++) {
    line(motor[i].x, motor[i].y, motor[i].z, 
      actorPosition.x, actorPosition.y, actorPosition.z);
  }
  noStroke();

  // draw actorTarget
  actorTarget2D.set(
    screenX(actorTarget.x, actorTarget.y, actorTarget.z), 
    screenY(actorTarget.x, actorTarget.y, actorTarget.z));
  /*pushMatrix();
   fill(100);
   translate(actorTarget.x, actorTarget.y, actorTarget.z);
   sphere(20);
   popMatrix();*/

  /*stroke(50, 50, 0);
   line(  actorTarget.x, actorTarget.y, -DEPTH_CM/2, 
   actorTarget.x, actorTarget.y, DEPTH_CM/2  );
   line(  -WIDTH_CM/2, actorTarget.y, actorTarget.z, 
   WIDTH_CM/2, actorTarget.y, actorTarget.z  );
   line(  actorTarget.x, -HEIGHT_CM/2, actorTarget.z, 
   actorTarget.x, HEIGHT_CM/2, actorTarget.z  );*/

  noStroke();

  // draw actorPosition
  pushMatrix();
  fill(255);
  translate(actorPosition.x, actorPosition.y, actorPosition.z);
  sphere(20);
  popMatrix();

  // draw motors
  for (int i = 0; i < NUM_MOTORS; i++) {
    pushMatrix();
    pushStyle();
    fill(255);
    motor[i].calculate2d();
    translate(motor[i].x, motor[i].y, motor[i].z);
    sphere(10);
    popStyle();
    popMatrix();
  }

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

  pushStyle();
  noFill();
  strokeWeight(3);
  stroke(255);
  ellipse(actorTarget2D.x, actorTarget2D.y, 30, 30);
  popStyle();

  for (int i = 0; i < NUM_MOTORS; i++) {
    motor[i].draw2d();
  }

  warning.draw();
}

void mouseDragged() {
  if (keyPressed && key == ' ') {
    // add x/y to the rotation
    worldRotationX -= (mouseY-pmouseY) * 0.01;
    worldRotationY += (mouseX-pmouseX) * 0.01;
  } 

  // lock to Y axis
  else if (keyPressed && key == 'y') {
    // lock to Y axis
    actorTarget.y += mouseY-pmouseY;
    actorTarget.y = constrain(actorTarget.y, -HEIGHT_CM/2, HEIGHT_CM/2);
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
    actorTarget.x = constrain(actorTarget.x, -WIDTH_CM/2, WIDTH_CM/2);
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
    actorTarget.z = constrain(actorTarget.z, -DEPTH_CM/2, DEPTH_CM/2);
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
    actorTarget.x = constrain(actorTarget.x, -WIDTH_CM/2, WIDTH_CM/2);
    actorTarget.y = constrain(actorTarget.y, -HEIGHT_CM/2, HEIGHT_CM/2);
    actorTarget.z = constrain(actorTarget.z, -DEPTH_CM/2, DEPTH_CM/2);
  }
}

void mouseWheel(MouseEvent e) {
  // adjust the scale to give the impression of zoom in/out
  float count = e.getCount() * 10;
  scaleCM += count;
}

void serialEvent(Serial p) {
  String message = p.readString();
  message = trim(message);

  // check for locked message
  if ( message.substring(0, 2).equals("l=") ) 
  {
    String l = message.substring(2);
    warning.isSystemLocked = l.equals("1") ? true : false;
  } 

  // check for calibration
  else if ( message.substring(0, 2).equals("c=") ) {    
    String[] list = split(message.substring(2), ',');
    for (int i = 0; i < list.length; i++) {
      // mark as calibrated
      warning.motorAReady = list[0].equals("1") ? true : false;
      warning.motorBReady = list[1].equals("1") ? true : false;
      warning.motorCReady = list[2].equals("1") ? true : false;
      warning.motorDReady = list[3].equals("1") ? true : false;
    }
  }
  // just output the unknown reponse
  else {
    println("> "+message);
  }
}