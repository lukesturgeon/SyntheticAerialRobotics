import controlP5.*; //<>//
import processing.serial.*;

final float     WIDTH_CM = 1500; // left to right (in cm)
final float     DEPTH_CM = 1500; // front to back (in cm)
final float     HEIGHT_CM = 800; // top to bottom (in cm)
final int       NUM_MOTORS = 4;

float     scaleCM = -1200.0; // default size to scale down to
float     worldRotationX = 0.0;
float     worldRotationY = 0.0;

Motor3D[] motorPositions;
PVector   actorTarget;
PVector   actorPosition;
float     easing = 0.1;

Table     recordData;
int       recordTimer;
boolean   isRecording;
boolean   isPlaying;
int       playbackPosition;

ControlP5 cp5;
String warnMessage = "";
boolean isSystemLocked = true;

Serial arduino;

void setup() {
  size(1280, 800, P3D);
  smooth(8);

  cp5_init();

  isRecording = false;
  recordData = new Table();
  recordData.addColumn("x");
  recordData.addColumn("y");
  recordData.addColumn("z");

  //motorLengths = new float[4];
  motorPositions = new Motor3D[4];
  motorPositions[0] = new Motor3D(-WIDTH_CM/2, -HEIGHT_CM/2, -DEPTH_CM/2);
  motorPositions[1] = new Motor3D(WIDTH_CM/2, -HEIGHT_CM/2, -DEPTH_CM/2);
  motorPositions[2] = new Motor3D(WIDTH_CM/2, -HEIGHT_CM/2, DEPTH_CM/2);
  motorPositions[3] = new Motor3D(-WIDTH_CM/2, -HEIGHT_CM/2, DEPTH_CM/2);

  // start in center of floor
  actorTarget  = new PVector(0, HEIGHT_CM/2, 0);
  actorPosition = actorTarget.get();

  // connect to arduino
  boolean portDetected = false;
  String portName = "/dev/tty.usbmodem411";

  String[] availablePorts = Serial.list();
  for (int i = 0; i < availablePorts.length; i++) {
    if (availablePorts[i].equals(portName)) {
      arduino = new Serial(this, portName, 115200);
      arduino.bufferUntil('\n');
      portDetected = true;
      break;
    }
  }

  if (!portDetected) {
    showWarning("The Arduino was not detected! Connect Arduino USB cable and restart software.");
  }
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
    motorPositions[i].calculateLengthTo( actorPosition );
    Slider s = (Slider) cp5.getController("cp5_length"+i);
    s.setValue(motorPositions[i].getLength());
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

  // run program as normal
  update();

  background(0, 0, 0);

  pushMatrix();
  translate(width/2, (height/2), scaleCM);
  rotateX(worldRotationX);
  rotateY(worldRotationY);

  //draw frame
  noFill();
  stroke(#444444);
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
  line(  actorTarget.x, actorTarget.y, -DEPTH_CM/2, 
    actorTarget.x, actorTarget.y, DEPTH_CM/2  );
  line(  -WIDTH_CM/2, actorTarget.y, actorTarget.z, 
    WIDTH_CM/2, actorTarget.y, actorTarget.z  );
  line(  actorTarget.x, -HEIGHT_CM/2, actorTarget.z, 
    actorTarget.x, HEIGHT_CM/2, actorTarget.z  );

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

  if ( !warnMessage.equals("") ) {
    // there's an error
    //pushStyle();
    fill(255, 255, 0);
    rect(200, 300, width-400, height-600);
    fill(0);
    //textSize(20);
    textAlign(CENTER, CENTER);
    text(warnMessage, width/2, height/2);
    //popStyle();
  }
}

void showWarning(String e) {
  warnMessage = e;
}

void clearWarning() {
  warnMessage = "";
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

  /*if ( message.substring(0, 3).equals("mm=") ) 
   {
   String mm = message.substring(3);
   currentLength = int( mm );
   } else if ( message.substring(0, 2).equals("s=") ) 
   {
   String s = message.substring(2);
   currentStep = int( s );
   cp5.getController("currentStep").setValue(currentStep);
   } else if ( message.substring(0, 2).equals("c=") ) 
   {
   String c = message.substring(2);
   println("calibration = " + c);
   
   
   } else if ( message.substring(0, 2).equals("l=") ) 
   {
   String l = message.substring(2);
   isSystemLocked = l.equals("1") ? true : false;
   Toggle t = (Toggle) cp5.getController("lockToggle");
   t.setBroadcast(false);
   t.setValue(isSystemLocked);
   t.setBroadcast(true);
   } else
   {
   println("> "+message);
   }*/

  if ( message.substring(0, 2).equals("l=") ) 
  {
    String l = message.substring(2);
    isSystemLocked = l.equals("1") ? true : false;    
    if (isSystemLocked) {
      showWarning("Arduino is locked. A cable is too close!");
    } else {
      clearWarning();
    }
  } else if ( message.substring(0, 2).equals("c=") ) {    
    String[] list = split(message.substring(2), ',');
    for (int i = 0; i < list.length; i++) {
      // mark as calibrated
      Toggle t = (Toggle) cp5.getController("cp5_calibrate"+i);
      t.setBroadcast(false);
      t.setValue( list[i].equals("1") ? true : false );
      t.setBroadcast(true);
    }
  }
  // just output the unknown reponse
  else {
    println("> "+message);
  }
}