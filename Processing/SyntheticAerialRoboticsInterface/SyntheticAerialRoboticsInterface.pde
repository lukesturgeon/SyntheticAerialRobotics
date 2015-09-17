import controlP5.*; //<>//

final float         WIDTH_CM = 301.00; // left to right (in cm)
final float         DEPTH_CM = 290.52; // front to back (in cm)
final float         HEIGHT_CM = 279.40; // top to bottom (in cm)
final int           NUM_MOTORS = 4; // controls the loops and settings
final int           SLEEP_AFTER_MILLIS = 1000*60; // seconds until we should sleep

float               scaleCM = 100.0; // default size to scale down to
float               worldRotationX = 0.0;
float               worldRotationY = 0.0;

ControlP5           cp5;
Println             console;
WarningSystem       system;
Motor3dSerial       serial;
Motor3d[]           motor;
Target3d            actorTarget;
Target3d            actorPosition;
float               easing = 0.1;
int                 maxSpeed = 1000;
int                 prev_maxSpeed = maxSpeed;
int                 maxAcceleration = 500;
int                 prev_maxAcceleration = maxAcceleration;

Table               recordData;
int                 recordTimer;
boolean             isRecording;
boolean             isPlaying;
int                 playbackPosition;

int                 updateTimer;
int                 lastChangedTimer;
int                 lastQueryTimer;

PFont               headingFont;
PFont               bodyFont;

void setup() {

  // to improve performance and run less maths calculations
  frameRate(30);

  // aesthetics
  size(1400, 800, P3D);
  smooth(8);
  headingFont = loadFont("fonts/AkzidenzGrotesk-Bold-24.vlw");
  bodyFont = loadFont("fonts/AkzidenzGrotesk-Roman-11.vlw");

  // setup the warning system to check the status of the installation
  // this is the main system that validates and alerts
  system = new WarningSystem();

  isRecording = false;
  recordData = new Table();
  recordData.addColumn("x");
  recordData.addColumn("y");
  recordData.addColumn("z");

  motor = new Motor3d[4];
  motor[0] = new Motor3d(-WIDTH_CM/2, -HEIGHT_CM/2, -DEPTH_CM/2);
  motor[0].setLabel("A");
  motor[1] = new Motor3d(WIDTH_CM/2, -HEIGHT_CM/2, -DEPTH_CM/2);
  motor[1].setLabel("B");
  motor[2] = new Motor3d(WIDTH_CM/2, -HEIGHT_CM/2, DEPTH_CM/2);
  motor[2].setLabel("C");
  motor[3] = new Motor3d(-WIDTH_CM/2, -HEIGHT_CM/2, DEPTH_CM/2);
  motor[3].setLabel("D");

  // start in center of floor
  actorTarget  = new Target3d(0, HEIGHT_CM/2, 0);
  actorPosition = actorTarget.get();

  // connect to arduino
  serial = new Motor3dSerial();
  system.arduinoConnected = serial.connect(this, "/dev/tty.usbmodem411", 115200);

  cp5_init();
}

void resetSleep() {
  lastChangedTimer = millis();
  cp5.getController("sleep").setValue(0);
}

void update() {

  // move the actor closer to the target
  float dx = actorTarget.x - actorPosition.x;
  float dy = actorTarget.y - actorPosition.y;
  float dz = actorTarget.z - actorPosition.z;
  actorPosition.x += dx * easing;
  actorPosition.y += dy * easing;
  actorPosition.z += dz * easing;

  // have the lengths changed?
  boolean hasChanged = false;
  for (int i = 0; i < NUM_MOTORS; i++) {
    motor[i].calculateLengthTo( actorPosition );
    if (motor[i].hasChanged()) {
      hasChanged = true;
    }
  }

  if (hasChanged) {
    if (!system.isLocked) {
      // this is it, send lengths to arduino
      // if the system is sleeping it will automatically wake
      serial.sendLengthMM(  
        motor[0].getLengthMM(), 
        motor[1].getLengthMM(), 
        motor[2].getLengthMM(), 
        motor[3].getLengthMM()  );

      resetSleep();
    }
  } else {
    // nothing is happening, should we sleep?
    if (!system.isSleeping && millis() - lastChangedTimer > SLEEP_AFTER_MILLIS) {
      // times up, so sleep
      serial.sendCommand( Motor3dSerial.SLEEP );
    } else if (!system.isSleeping) {
      // keep counting
      cp5.getController("sleep").setValue(millis() - lastChangedTimer);
    }
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

  // run the maths and calculations
  if (millis()-updateTimer > 100) {
    updateTimer = millis();
    if (system.arduinoConnected) {
      update();
    }
  }

  // run the occasional status query to arduino
  if (millis()-lastQueryTimer > 3000) {
    lastQueryTimer = millis();

    if (!system.motorAReady || !system.motorBReady || !system.motorCReady || !system.motorDReady) {
      serial.sendCommand(Motor3dSerial.GET_IS_CALIBRATED);
    } else {
      serial.sendCommand(Motor3dSerial.GET_LENGTH_MM);
    }
  }

  // redraw interface 
  background(#020320);

  pushMatrix();
  translate(width/2, (height/2), scaleCM);
  rotateX(worldRotationX);
  rotateY(worldRotationY);


  //draw frame
  noFill();
  stroke(#82A5C6);
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

  // save actorTarget for 2d rendering
  actorTarget.calculate2d();
  actorPosition.calculate2d();

  /*noStroke();
   
   // draw actorPosition
   pushMatrix();
   fill(255);
   translate(actorPosition.x, actorPosition.y, actorPosition.z);
   //sphere(20);
   popMatrix();*/

  // draw motors
  for (int i = 0; i < NUM_MOTORS; i++) {
    motor[i].calculate2d();
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
  ellipse(actorTarget.screenX, actorTarget.screenY, 15, 15);
  noStroke();
  fill(255);
  ellipse(actorPosition.screenX, actorPosition.screenY, 10, 10);
  popStyle();

  for (int i = 0; i < NUM_MOTORS; i++) {
    motor[i].draw2d();
  }

  system.draw();
}

void mouseReleased() {
  // check the arduino variables
  if (maxSpeed != prev_maxSpeed) {
    serial.sendMaxSpeed(maxSpeed);
    prev_maxSpeed = maxSpeed;
  } else if (maxAcceleration != prev_maxAcceleration) {
    serial.sendMaxAcceleration(maxAcceleration);
    prev_maxAcceleration = maxAcceleration;
  }
}

void mouseDragged() {
  if (keyPressed && key == ' ') {
    // add x/y to the rotation
    worldRotationX -= (mouseY-pmouseY) * 0.01;
    worldRotationY += (mouseX-pmouseX) * 0.01;
  } 

  // safety lock
  if (system.isLocked) {
    return;
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
    String flag = message.substring(2);
    system.isLocked = flag.equals("1") ? true : false;
    println("isLocked : " + system.isLocked);
    Toggle t = (Toggle) cp5.getController("cp5_unlock");
    t.setBroadcast(false);
    t.setValue(!system.isLocked);
    t.setBroadcast(true);
  }

  // check for sleep message
  else if ( message.substring(0, 2).equals("s=") ) 
  {
    String flag = message.substring(2);
    boolean prevSleep = system.isSleeping;
    system.isSleeping = flag.equals("1") ? true : false;
    println("isSleeping : " + system.isSleeping);

    // update the ui to show the correct thing
    Toggle t = (Toggle) cp5.getController("cp5_wake");
    t.setBroadcast(false);
    t.setValue(!system.isSleeping);
    t.setBroadcast(true);

    if (prevSleep == true && system.isSleeping == false) {
      // system has woken up, reset counters
      lastChangedTimer = millis();
      cp5.getController("sleep").setValue(0);
    } else if (prevSleep == false && system.isSleeping == true) {
      // system has gone to sleep
      cp5.getController("sleep").setValue(SLEEP_AFTER_MILLIS );
    }
  }

  // check for length message
  else if ( message.substring(0, 3).equals("mm=") ) {
    float[] mm = float( split(message.substring(3), ',') );
    motor[0].setLiveLength(mm[0]);
    motor[1].setLiveLength(mm[1]);
    motor[2].setLiveLength(mm[2]);
    motor[3].setLiveLength(mm[3]);
  }

  // check for calibration
  else if ( message.substring(0, 2).equals("c=") ) {    
    String[] list = split(message.substring(2), ',');
    for (int i = 0; i < list.length; i++) {
      // mark as calibrated
      system.motorAReady = list[0].equals("1") ? true : false;
      system.motorBReady = list[1].equals("1") ? true : false;
      system.motorCReady = list[2].equals("1") ? true : false;
      system.motorDReady = list[3].equals("1") ? true : false;

      if (system.motorAReady) {
        cp5.getController("cp5_calibrate0").setColorForeground(color(255));
      }
      if (system.motorBReady) {
        cp5.getController("cp5_calibrate1").setColorForeground(color(255));
      }
      if (system.motorCReady) {
        cp5.getController("cp5_calibrate2").setColorForeground(color(255));
      }
      if (system.motorDReady) {
        cp5.getController("cp5_calibrate3").setColorForeground(color(255));
      }
    }
  }
  // just output the unknown reponse
  else {
    println("> "+message);
  }
}