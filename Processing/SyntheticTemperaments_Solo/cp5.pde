void cp5_initTemperaments() {
  cp5 = new ControlP5(this);
  cp5.setFont(bodyFont);

  cp5.addRadioButton("cp5_temperaments")
    .setItemsPerRow(6)
    .setSpacingColumn(80)
    .setPosition(20, 20)
    .setSize(30, 30)
    .addItem("anger", 0)
    .addItem("fear", 1)
    .addItem("surprise", 2)
    .addItem("disgust", 3)
    .addItem("happiness", 4)
    .addItem("sadness", 5);

  cp5.addSlider("cp5_maxSpeed")
    .setPosition(20, 70)
    .setRange(0, 2)
    .setValue(1)
    .setSize(180, 18);
  cp5.addSlider("cp5_damping")
    .setPosition(20, 90)
    .setRange(0, .99)
    .setValue(0.95)
    .setSize(180, 18);
  cp5.addSlider("cp5_mass")
    .setPosition(20, 110)
    .setRange(1, 100)
    .setValue(10.0)
    .setSize(180, 18);

  cp5.addSlider("originStrength")
    .setPosition(20, 140)
    .setRange(0, 1)
    .setValue(0.1)
    .setSize(180, 18);

  cp5.addSlider("oscVelocity")
    .setPosition(20, 160)
    .setRange(0, .5)
    .setValue(0.01)
    .setSize(180, 18);
  cp5.addSlider("oscStrength")
    .setPosition(20, 180)
    .setRange(0, .5)
    .setValue(0)
    .setSize(180, 18);

  cp5.addSlider("wanderStrength")
    .setPosition(20, 220)
    .setRange(0, .5)
    .setValue(0)
    .setSize(180, 18);

  cp5.addSlider("cp5_windx")
    .setPosition(20, 250)
    .setRange(-0.5, 0.5)
    .setSize(180, 18);
  cp5.addSlider("cp5_windz")
    .setPosition(20, 270)
    .setRange(-0.5, 0.5)
    .setSize(180, 18);

  cp5.addButton("cp5_randomizePerformance")
    .setPosition(20, 300)
    .setLabel("Randomise")
    .setSize(180, 18);

  cp5.addButton("cp5_restPerformance")
    .setPosition(20, 320)
    .setLabel("Rest")
    .setSize(180, 18);

  cp5.addToggle("cp5_isPerformanceRandomized")
    .setValue(false)
    .setLabelVisible(false)
    .setPosition(20, 350)
    .setSize(30, 30);

  cp5.addLabel("isSolo_lbl")
    .setValueLabel("TIMED PERFORMANCE\n5mins dance / 5mins sleep")
    .setPosition(50, 355)
    .setSize(30, 30);

  //framerate debug
  cp5.addFrameRate().setInterval(30).setPosition(17, height - 30);
}

//---------------------------------------------
void cp5_randomizePerformance() {
  
  // lift up the floor bounds
  safeZone3d.setBottom(HEIGHT_CM/2-100);
  
  println("randomise at " + nf(hour(), 2)+":"+nf(minute(), 2)+":"+nf(second(), 2));
  cp5.getController("originStrength").setValue(0);
  cp5.getController("cp5_windx").setValue(random(-0.3, 0.3));
  cp5.getController("cp5_windz").setValue(random(-0.3, 0));
  //
  cp5.getController("oscVelocity").setValue(random(0.01, 0.2));
  cp5.getController("oscStrength").setValue(random(0, 0.6));
  cp5.getController("wanderStrength").setValue(random(0.1, 0.8));
  cp5.getController("cp5_mass").setValue(random(1, 20));
}

void cp5_isPerformanceRandomized(boolean b) {
  isPerformanceRandomized = b;
  if (b) {
    cp5_randomizePerformance();
  }
}

void cp5_restPerformance() {
  println("rest at " + nf(hour(), 2)+":"+nf(minute(), 2)+":"+nf(second(), 2));
  
  // drop the floor bounds
  safeZone3d.setBottom(HEIGHT_CM/2);
  
  cp5.getController("originStrength").setValue(.2);
  cp5.getController("cp5_windx").setValue(0);
  cp5.getController("cp5_windz").setValue(0);
  //
  cp5.getController("oscVelocity").setValue(0);
  cp5.getController("oscStrength").setValue(0);
  cp5.getController("wanderStrength").setValue(0);
  cp5.getController("cp5_mass").setValue(0);
}

//---------------------------------------------

void cp5_temperaments(int a) {
  println("a radio Button event: "+a);
  switch (a) {
  case ANGER_TEMPERAMENT :
    println("make it angry");
    break;

  case FEAR_TEMPERAMENT :
    println("make it fear");
    break;

  case SURPRISE_TEMPERAMENT :
    println("make it surprised");
    break;

  case DISGUST_TEMPERAMENT :
    println("make it disgusted");
    break;

  case HAPPINESS_TEMPERAMENT :
    println("make it happy");
    break;

  case SADNESS_TEMPERAMENT :
    println("make it sad");
    break;
  }
}

//---------------------------------------------

void cp5_maxSpeed(float value) {
  actor.maxSpeed = value;
}

void cp5_mass(float value) {
  actor.mass = value;
}

void cp5_windx(float value) {
  wind.x = value;
}
void cp5_windz(float value) {
  wind.z = value;
}

//---------------------------------------------

void cp5_initSystem() {
  cp5.addSlider("maxSpeed")
    .setLabel("speed")
    .setRange(100, 400)
    .setValue(200)
    .setNumberOfTickMarks(13)
    .showTickMarks(false)
    .setPosition(width-300, 20)
    .setSize(190, 18);

  cp5.addSlider("maxAcceleration")
    .setLabel("acceleration")
    .setRange(100, 400)
    .setValue(200)
    .setNumberOfTickMarks(13)
    .showTickMarks(false)
    .setPosition(width-300, 40)
    .setSize(190, 18);

  cp5.addSlider("sleep")
    .setLock(true)
    .setRange(0, SLEEP_AFTER_MILLIS)
    .setPosition(width-300, 60)
    .setSize(190, 18);

  cp5.addToggle("cp5_canSleep")
    .setValue(false)
    .setPosition(width-300, 80)
    .setSize(18, 18);

  // labels
  cp5.addTextlabel("calibration")
    .setValueLabel("1. CALIBRATE")
    .setPosition(width-300-3, 120);  

  cp5.addTextlabel("actions")
    .setValueLabel("2. ACTIONS")
    .setPosition(width-300-3, 220);

  cp5.addToggle("cp5_wake")
    .setLabel("awake")
    .setState(true)
    .setPosition(width-300-3, 240)
    .setSize(50, 50);

  cp5.addToggle("cp5_unlock")
    .setLabel("unlock")
    .setPosition(width-300+70, 240)
    .setSize(50, 50);

  cp5.addToggle("cp5_sync")
    .setLabel("Sync")
    .setPosition(width-300+140, 240)
    .setSize(50, 50);

  cp5.addTextlabel("step")
    .setValueLabel("3. ADVANCED")
    .setPosition(width-300, 320);

  String[] labels = {"A", "B", "C", "D"};
  for (int i = 0; i < NUM_MOTORS; i++) {

    // calibration
    cp5.addBang("cp5_calibrate"+i)
      .setLabel(labels[i])
      .setPosition(width-300+(i*50), 140)
      .setSize(40, 40);

    // counter-clockwise
    cp5.addBang("cp5_ccw"+i)
      .setLabelVisible(false)
      .setPosition(width-300+(i*50), 340)
      .setSize(40, 19);

    // clockwise
    cp5.addBang("cp5_cw"+i)
      .setLabel(labels[i])
      .setPosition(width-300+(i*50), 360)
      .setSize(40, 20);
  }

  Textarea myTextarea = cp5.addTextarea("txt")
    .setPosition(width-300, 440)
    .setSize(280, 300)
    .setFont(bodyFont)
    .setLineHeight(15)
    .setColorBackground(color(0));
  cp5.addConsole(myTextarea);
}

void cp5_wake(boolean b) {
  if (b) {
    serial.sendCommand( Serial3d.WAKE );
  } else {
    serial.sendCommand( Serial3d.SLEEP );
  }
}

void cp5_unlock(boolean b) {
  if (b) {
    serial.sendCommand( Serial3d.UNLOCK );
  } else {
    serial.sendCommand( Serial3d.LOCK );
  }
}

void cp5_sync(boolean b) {
  if (b) {
    if (system.isCalibrated()) {
      system.isSendingData = true;
    } else {
      Toggle t = (Toggle) cp5.getController("cp5_sync");
      t.setBroadcast(false);
      t.setValue(false);
      t.setBroadcast(true);
      println("Must calibrate motors");
    }
  } else {
    // turn off sync
    system.isSendingData = false;
  }
}

void cp5_canSleep(boolean b) {
  canSleep = b;
  if (canSleep) {
    cp5_resetSleep();
  }
}

//---------------------------------------------
void cp5_calibrate0() {
  cp5_resetSleep();
  serial.sendCommand( Serial3d.CALIBRATE_A );
}
void cp5_calibrate1() {
  cp5_resetSleep();
  serial.sendCommand( Serial3d.CALIBRATE_B );
}
void cp5_calibrate2() {
  cp5_resetSleep();
  serial.sendCommand( Serial3d.CALIBRATE_C );
}
void cp5_calibrate3() {
  cp5_resetSleep();
  serial.sendCommand( Serial3d.CALIBRATE_D );
}

//---------------------------------------------
void cp5_cw0() {
  cp5_resetSleep();
  serial.sendCommand( Serial3d.STEP_CW_A );
}
void cp5_cw1() {
  cp5_resetSleep();
  serial.sendCommand( Serial3d.STEP_CW_B );
}
void cp5_cw2() {
  cp5_resetSleep();
  serial.sendCommand( Serial3d.STEP_CW_C );
}
void cp5_cw3() {
  cp5_resetSleep();
  serial.sendCommand( Serial3d.STEP_CW_D );
}

//---------------------------------------------
void cp5_ccw0() {
  cp5_resetSleep();
  serial.sendCommand( Serial3d.STEP_CCW_A );
}
void cp5_ccw1() {
  cp5_resetSleep();
  serial.sendCommand( Serial3d.STEP_CCW_B );
}
void cp5_ccw2() {
  cp5_resetSleep();
  serial.sendCommand( Serial3d.STEP_CCW_C );
}
void cp5_ccw3() {
  cp5_resetSleep();
  serial.sendCommand( Serial3d.STEP_CCW_D );
}

void cp5_resetSleep() {
  lastChangedTimer = millis();
  cp5.getController("sleep").setValue(0);
}