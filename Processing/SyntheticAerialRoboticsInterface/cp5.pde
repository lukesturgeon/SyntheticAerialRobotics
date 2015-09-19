void cp5_init() {
  cp5 = new ControlP5(this);
  cp5.setColorBackground( color(50) );
  cp5.setColorForeground( color(80) );
  cp5.setColorActive( color(100) );
  cp5.setFont(bodyFont);

  // VARIABLES

  cp5.addSlider("easing")
    .setRange(0.001, 0.5)
    .setPosition(20, 20)
    .setSize(190, 18);

  cp5.addSlider("maxSpeed")
    .setLabel("speed")
    .setRange(100, 400)
    .setValue(200)
    .setNumberOfTickMarks(13)
    .showTickMarks(false)
    .setPosition(20, 40)
    .setSize(190, 18);

  cp5.addSlider("maxAcceleration")
    .setLabel("acceleration")
    .setRange(100, 400)
    .setValue(200)
    .setNumberOfTickMarks(13)
    .showTickMarks(false)
    .setPosition(20, 60)
    .setSize(190, 18);

  cp5.addSlider("sleep")
    .setLock(true)
    .setColorForeground( color(255) )
    .setRange(0, SLEEP_AFTER_MILLIS)
    .setPosition(20, 100)
    .setSize(190, 18);

  // labels
  cp5.addTextlabel("calibration")
    .setValueLabel("1. CALIBRATE")
    .setPosition(20-3, 285);  

  cp5.addTextlabel("actions")
    .setValueLabel("2. ACTIONS")
    .setPosition(20-3, 385);  

  cp5.addTextlabel("step")
    .setValueLabel("3. ADVANCED")
    .setPosition(20-3, 495);

  // buttons

  cp5.addToggle("cp5_wake")
    .setLabel("awake")
    .setState(true)
    .setColorActive(color(255))
    .setPosition(20, 400)
    .setSize(50, 50);

  cp5.addToggle("cp5_unlock")
    .setLabel("unlock")
    .setColorActive(color(255))
    .setPosition(90, 400)
    .setSize(50, 50);

  cp5.addToggle("cp5_sync")
    .setLabel("Sync")
    .setColorActive(color(255))
    .setPosition(160, 400)
    .setSize(50, 50);

  // motor calibration buttons

  String[] labels = {"A", "B", "C", "D"};
  for (int i = 0; i < NUM_MOTORS; i++) {

    // calibration
    cp5.addBang("cp5_calibrate"+i)
      .setLabel(labels[i])
      .setColorForeground( color(50) )
      .setPosition(20+(i*50), 300)
      .setSize(40, 40);

    // counter-clockwise
    cp5.addBang("cp5_ccw"+i)
      .setLabelVisible(false)
      .setColorForeground( color(50) )
      .setPosition(20+(i*50), 510)
      .setSize(40, 19);

    // clockwise
    cp5.addBang("cp5_cw"+i)
      .setLabel(labels[i])
      .setColorForeground( color(50) )
      .setPosition(20+(i*50), 530)
      .setSize(40, 20);
  }

  // PATH RECORDING
  cp5.addTextlabel("recording")
    .setValueLabel("PATH RECORDING")
    .setPosition(20, 580);

  cp5.addButton("cp5_loadData")
    .setLabel("loaddata...")
    .setPosition(20, 600)
    .setSize(150, 18);

  cp5.addToggle("cp5_record")
    .setLabel("Record")
    .setPosition(20, 620)
    .setSize(70, 18);

  cp5.addToggle("cp5_playback")
    .setLabel("Playback")
    .setPosition(100, 620)
    .setSize(70, 18);


  Textarea myTextarea = cp5.addTextarea("txt")
    .setPosition(width-220, 20)
    .setSize(200, 300)
    .setFont(bodyFont)
    .setLineHeight(15)
    .setColorBackground(color(0, 100));
  console = cp5.addConsole(myTextarea);


  //framerate debug
  cp5.addFrameRate().setInterval(30).setPosition(17, height - 30);
}

//---------------------------------------------
void cp5_record(boolean b) {
  if (b) {
    // start recording
    println("R* START");
  } else {
    // end recording
    saveTable(recordData, "data/paths/"+utils_getTimestamp()+".csv");
    println("R* END");
  }

  // set value
  isRecording = b;
}

void cp5_playback(boolean b) {
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

void cp5_loadData() {
  selectInput("Select a file to playback:", "cp5_dataSelected");
}

void cp5_dataSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    isRecording = false;
    recordData.clearRows();
    recordData = loadTable(selection.getAbsolutePath(), "header");
  }
}

//---------------------------------------------
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
  }
  else {
    // turn off sync
    system.isSendingData = false;
  }
}
void cp5_wake(boolean b) {
  if (b) {
    serial.sendCommand( Motor3dSerial.WAKE );
  } else {
    serial.sendCommand( Motor3dSerial.SLEEP );
  }
}

//---------------------------------------------
void cp5_unlock(boolean b) {
  if (b) {
    serial.sendCommand( Motor3dSerial.UNLOCK );
  } else {
    serial.sendCommand( Motor3dSerial.LOCK );
  }
}

//---------------------------------------------
void cp5_calibrate0() {
  resetSleep();
  serial.sendCommand( Motor3dSerial.CALIBRATE_A );
}
void cp5_calibrate1() {
  resetSleep();
  serial.sendCommand( Motor3dSerial.CALIBRATE_B );
}
void cp5_calibrate2() {
  resetSleep();
  serial.sendCommand( Motor3dSerial.CALIBRATE_C );
}
void cp5_calibrate3() {
  resetSleep();
  serial.sendCommand( Motor3dSerial.CALIBRATE_D );
}

//---------------------------------------------
void cp5_cw0() {
  resetSleep();
  serial.sendCommand( Motor3dSerial.STEP_CW_A );
}
void cp5_cw1() {
  resetSleep();
  serial.sendCommand( Motor3dSerial.STEP_CW_B );
}
void cp5_cw2() {
  resetSleep();
  serial.sendCommand( Motor3dSerial.STEP_CW_C );
}
void cp5_cw3() {
  resetSleep();
  serial.sendCommand( Motor3dSerial.STEP_CW_D );
}

//---------------------------------------------
void cp5_ccw0() {
  resetSleep();
  serial.sendCommand( Motor3dSerial.STEP_CCW_A );
}
void cp5_ccw1() {
  resetSleep();
  serial.sendCommand( Motor3dSerial.STEP_CCW_B );
}
void cp5_ccw2() {
  resetSleep();
  serial.sendCommand( Motor3dSerial.STEP_CCW_C );
}
void cp5_ccw3() {
  resetSleep();
  serial.sendCommand( Motor3dSerial.STEP_CCW_D );
}