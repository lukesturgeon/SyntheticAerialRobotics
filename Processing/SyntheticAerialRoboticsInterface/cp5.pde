void cp5_init() {
  cp5 = new ControlP5(this);
  cp5.setColorBackground( color(100) );
  cp5.setColorForeground( color(200) );
  cp5.setColorActive( color(150) );
  cp5.setFont(bodyFont);

  // VARIABLES

  cp5.addSlider("easing")
    .setRange(0.001, 0.5)
    .setPosition(20, 20)
    .setSize(150, 18);

  cp5.addSlider("maxSpeed")
    .setLabel("speed")
    .setRange(100, 1500)
    .setPosition(20, 40)
    .setSize(150, 18);

  cp5.addSlider("maxAcceleration")
    .setLabel("acceleration")
    .setRange(100, 1500)
    .setPosition(20, 60)
    .setSize(150, 18);

  cp5.addSlider("sleep")
    .setLock(true)
    .setColorForeground( color(255) )
    //.setColorValue(color(0))
    .setRange(0, SLEEP_AFTER_MILLIS)
    .setPosition(20, 100)
    .setSize(150, 18);



  cp5.addBang("cp5_getLocked")
    .setLabel("lock?")
    .setPosition(20, 250)
    .setSize(30, 30);
  cp5.addBang("cp5_getSleep")
    .setLabel("sleep?")
    .setPosition(90, 250)
    .setSize(30, 30);
  /*cp5.addBang("cp5_getCalibration")
    .setLabel("calibrate?")
    .setPosition(160, 250)
    .setSize(30, 30);
  cp5.addBang("cp5_getLength")
    .setLabel("length?")
    .setPosition(230, 250)
    .setSize(30, 30);*/
    
    
  cp5.addBang("cp5_wake")
    .setLabel("wake!")
    .setPosition(20, 180)
    .setSize(30, 30);
  cp5.addToggle("cp5_sync")
    .setLabel("Sync!")
    .setColorActive(color(255, 255, 0))
    .setPosition(90, 180)
    .setSize(30, 30);



  // GET STATUS UPDATE
  cp5.addButton("cp5_unlock")
    .setBroadcast(false)
    .setLabel("unlock")
    .setPosition(20, 320)
    .setSize(150, 18)
    .setBroadcast(true);

  cp5.addButton("cp5_lock")
    .setBroadcast(false)
    .setLabel("lock")
    .setPosition(20, 340)
    .setSize(150, 18)
    .setBroadcast(true);



  // PATH RECORDING
  cp5.addTextlabel("recording")
    .setValueLabel("PATH RECORDING")
    .setPosition(20, 390);

  cp5.addButton("cp5_loadData")
    .setLabel("loaddata...")
    .setPosition(20, 400)
    .setSize(150, 18);

  cp5.addToggle("cp5_record")
    .setLabel("Record")
    .setPosition(20, 420)
    .setSize(70, 18);

  cp5.addToggle("cp5_playback")
    .setLabel("Playback")
    .setPosition(100, 420)
    .setSize(70, 18);




  // CALIBRATON
  cp5.addTextlabel("calibration")
    .setValueLabel("CALIBRATE")
    .setPosition(20, 490);  

  // nudge
  cp5.addTextlabel("step")
    .setValueLabel("STEP -/+")
    .setPosition(20, 560);

  String[] labels = {"A", "B", "C", "D"};
  for (int i = 0; i < NUM_MOTORS; i++) {

    // calibration
    cp5.addBang("cp5_calibrate"+i)
      .setBroadcast(false)
      .setLabel(labels[i])
      .setPosition(20+(i*40), 500)
      .setSize(30, 30)
      .setBroadcast(true);

    // counter-clockwise
    cp5.addBang("cp5_ccw"+i)
      .setBroadcast(false)
      .setLabelVisible(false)
      .setPosition(20+(i*40), 570)
      .setSize(30, 15)
      .setBroadcast(true);

    // clockwise
    cp5.addBang("cp5_cw"+i)
      .setBroadcast(false)
      .setLabelVisible(false)
      .setColorForeground(color(165))
      .setPosition(20+(i*40), 585)
      .setSize(30, 15)
      .setBroadcast(true);
  }


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
    saveTable(recordData, "data/"+utils_getTimestamp()+".csv");
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
void cp5_getLocked() {
  serial.sendCommand( Motor3dSerial.GET_IS_LOCKED );
}
void cp5_getSleep() {
  serial.sendCommand( Motor3dSerial.GET_IS_SLEEP );
}
void cp5_getCalibration() {
  println("get calibration");
  serial.sendCommand( Motor3dSerial.GET_IS_CALIBRATED );
}
void cp5_getLength() {
  serial.sendCommand( Motor3dSerial.GET_LENGTH_MM );
}
void cp5_sync(boolean flag) {
  if (system.isCalibrated()) {
    system.isSendingData = flag;
  } else {
    println("you cannot sync until the motors are calibrated!");
  }
}
void cp5_wake() {
  serial.sendCommand( Motor3dSerial.WAKE );
}

//---------------------------------------------
void cp5_unlock() {
  serial.sendCommand( Motor3dSerial.UNLOCK );
}
void cp5_lock() {
  serial.sendCommand( Motor3dSerial.LOCK );
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

//---------------------------------------------
/*void cp5_zero0() {
 serial.sendCommand( Motor3dSerial.ZERO_A );
 }
 void cp5_zero1() {
 serial.sendCommand( Motor3dSerial.ZERO_B );
 }
 void cp5_zero2() {
 serial.sendCommand( Motor3dSerial.ZERO_C );
 }
 void cp5_zero3() {
 serial.sendCommand( Motor3dSerial.ZERO_D );
 }*/