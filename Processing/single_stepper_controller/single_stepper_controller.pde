import controlP5.*;
import processing.serial.*;

ControlP5 cp5;
Serial arduino;

boolean isSystemLocked = true;
int currentStep = 0;
int currentLength = 0;
int millisTimer;

void setup() {
  size(1024, 768);
  cp5 = new ControlP5(this);

  cp5.addFrameRate().setInterval(10).setPosition(17, height - 30);

  cp5.addToggle("lockToggle")
    .setBroadcast(false)
    .setLabel("Locked (l/u)")
    .setValue(isSystemLocked)
    .setPosition(width-300, 20)
    .setSize(28, 28)
    .setBroadcast(true);

  cp5.addButton("zero")
    .setBroadcast(false)
    .setLabel("Zero (z)")
    .setValue(0)
    .setPosition(width-300, 120)
    .setSize(280, 28)
    .setBroadcast(true);
  cp5.addButton("ccw")
    .setBroadcast(false)
    .setLabel("CCW (ccw)")
    .setValue(0)
    .setPosition(width-300, 150)
    .setSize(280, 28)
    .setBroadcast(true);
  cp5.addButton("cw")
    .setBroadcast(false)
    .setLabel("CW (cw)")
    .setValue(0)
    .setPosition(width-300, 180)
    .setSize(280, 28)
    .setBroadcast(true);

  cp5.addButton("get")
    .setBroadcast(false)
    .setLabel("GET ALL (?s?mm?c?l)")
    .setValue(0)
    .setPosition(width-300, 230)
    .setSize(280, 28)
    .setBroadcast(true);

  cp5.addButton("stepCCW")
    .setBroadcast(false)
    .setLabel("STEP -100")
    .setPosition(width-300, 280)
    .setSize(280, 28)
    .setBroadcast(true);
  cp5.addButton("stepCW")
    .setBroadcast(false)
    .setLabel("STEP +100")
    .setPosition(width-300, 310)
    .setSize(280, 28)
    .setBroadcast(true);

  cp5.addSlider("currentStep")
    .setBroadcast(false)
    .setLabel("Steps")
    .setRange(1800, 0)
    .setPosition(400, 400)
    .setSize(30, 200)
    .setLock(true);
    
  cp5.addToggle("calibrateToggle")
    .setBroadcast(false)
    .setLabel("Calibrate (c)")
    .setPosition(400, 640)
    .setSize(30, 30)
    .setBroadcast(true);

  //printArray(Serial.list());
  arduino = new Serial(this, "/dev/tty.usbmodem411", 115200);
  arduino.bufferUntil('\n');

  // get all the latest data
  //arduino.write("?c\n");
  //arduino.write("?l\n");
  //arduino.write("?s\n");
  //arduino.write("?mm\n");
}

void draw() {

  if (millis()-millisTimer > 500) {
    millisTimer = millis();

    if (!isSystemLocked) {
      //arduino.write("?s\n");
      //arduino.write("?mm\n");
    }
  }

  //==========================================
  background(0);

  // output the commands for reference
  fill(255);
  String commandStr = "COMMANDS";
  commandStr += "\n-----------------------";
  commandStr += "\nu = unlock";
  commandStr += "\nl = lock";
  commandStr += "\nc = calibrate";
  commandStr += "\nz = zero";
  commandStr += "\ncw = 1 step CW";
  commandStr += "\nccw = 1 step CCW";
  commandStr += "\n-----------------------";
  commandStr += "\ns = step";
  commandStr += "\nmm = move";
  commandStr += "\n-----------------------";
  commandStr += "\n?s = get currentStep";
  commandStr += "\n?mm = get currentLength";
  commandStr += "\n?c = get calibrated";
  commandStr += "\n?l = get locked";
  text(commandStr, 20, 30);

  text(currentStep, 200, 30);
  text(currentLength, 400, 30);

  // controlbackground
  fill(255, 20);
  rect(width-320, 0, 320, height);
}

void keyPressed() {
  if (keyCode == DOWN) {
    stepCW();
  }
  
  else if (keyCode == UP) {
    stepCCW();
  }
  
  else if (key == 'c') {
    Toggle t = (Toggle) cp5.getController("calibrateToggle");
    t.setValue( true );
  }
}

void serialEvent(Serial p) {
  String message = p.readString();
  message = trim(message);

  if ( message.substring(0, 3).equals("mm=") ) 
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
    Toggle t = (Toggle) cp5.getController("calibrateToggle");
    t.setBroadcast(false);
    t.setValue( c.equals("1") ? true : false );
    t.setBroadcast(true);
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
  }
}

public void lockToggle(boolean theFlag) {
  if (isSystemLocked) {
    println("try to unlock");
    arduino.write("u\n");
  } else {
    println("try to lock");
    arduino.write("l\n");
  }
  isSystemLocked = theFlag;
}

public void calibrateToggle(boolean theFlag) {
  if (theFlag) {
    println("run calibration");
    arduino.write("c\n");
  }
}

public void zero(int theValue) {
  println("zero the values");
  arduino.write("z\n");
}

public void cw(int theValue) {
  println("step once cw");
  arduino.write("cw\n");
}

public void ccw(int theValue) {
  println("step once ccw");
  arduino.write("ccw\n");
}

public void get(int theValue) {
  arduino.write("?c\n");
  arduino.write("?l\n");
  arduino.write("?s\n");
  arduino.write("?mm\n");
}

public void stepCW() {
  if (!isSystemLocked) {
    arduino.write("s" + (currentStep+=100) + "\n");
  } else {
    println("system locked");
  }
}

public void stepCCW() {
  if (!isSystemLocked) {
    arduino.write("s" + (currentStep-=100) + "\n");
  } else {
    println("system locked");
  }
}