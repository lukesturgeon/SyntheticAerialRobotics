void cp5_init() {
  cp5 = new ControlP5(this);
  cp5.setColorBackground( color(80) );
  cp5.setColorForeground( color(255) );
  cp5.setColorActive( color(200) );
  //cp5.setAutoDraw(false);

  cp5.addSlider("easing")
    .setRange(0.001, 0.5)
    .setPosition(20, 20)
    .setSize(150, 20);

  // loading prerecorded paths
  cp5.addTextlabel("recording")
    .setValueLabel("> PATH RECORDING")
    .setPosition(20, 55);

  cp5.addButton("cp5_loadData")
    .setLabel("loaddata...")
    .setPosition(20, 70)
    .setSize(150, 20);

  cp5.addToggle("cp5_record")
    .setLabel("Record")
    .setPosition(20, 100)
    .setSize(70, 20);

  cp5.addToggle("cp5_playback")
    .setLabel("Playback")
    .setPosition(100, 100)
    .setSize(70, 20);

  //framerate debug
  cp5.addFrameRate().setInterval(10).setPosition(17, height - 30);

  cp5.addButton("cp5_getStatus")
    .setBroadcast(false)
    .setLabel("get status")
    .setPosition(20, 150)
    .setSize(150, 20)
    .setBroadcast(true);

  cp5.addButton("cp5_unlock")
    .setBroadcast(false)
    .setLabel("unlock")
    .setPosition(20, 180)
    .setSize(150, 20)
    .setBroadcast(true);

  cp5.addButton("cp5_lock")
    .setBroadcast(false)
    .setLabel("lock")
    .setPosition(20, 210)
    .setSize(150, 20)
    .setBroadcast(true);

  // CALIBRATON
  cp5.addTextlabel("calibration")
    .setValueLabel("CALIBRATE")
    .setPosition(20, 320);  

  // nudge
  cp5.addTextlabel("nudge")
    .setValueLabel("MICROSTEP +/-")
    .setPosition(20, 400);

  // zero
  cp5.addTextlabel("reset")
    .setValueLabel("SET '0' POS")
    .setPosition(20, 470);

  // clockwise
  cp5.addTextlabel("length")
    .setValueLabel("LENGTH (CM)")
    .setPosition(20, 540);

  String[] labels = {"A", "B", "C", "D"};

  for (int i = 0; i < NUM_MOTORS; i++) {

    // calibration
    cp5.addBang("cp5_calibrate"+i)
      .setBroadcast(false)
      .setLabel(labels[i])
      .setPosition(20+(i*40), 340)
      .setSize(30, 30)
      .setBroadcast(true);

    // counter-clockwise
    cp5.addBang("cp5_ccw"+i)
      .setBroadcast(false)
      .setLabelVisible(false)
      .setPosition(20+(i*40), 420)
      .setSize(30, 15)
      .setBroadcast(true);

    // clockwise
    cp5.addBang("cp5_cw"+i)
      .setBroadcast(false)
      .setLabelVisible(false)
      .setPosition(20+(i*40), 435)
      .setSize(30, 15)
      .setBroadcast(true);

    // set 0 pos
    cp5.addBang("cp5_zero"+i)
      .setBroadcast(false)
      .setLabelVisible(false)
      .setPosition(20+(i*40), 490)
      .setSize(30, 30)
      .setBroadcast(true);

    // length slider
    cp5.addSlider("cp5_length"+i)
      .setLabel(str(i))
      .setColorValueLabel(color(0))
      .setLock(true)
      .setRange(0, 2300)
      .setPosition(20, 560+(i*22))
      .setSize(150, 20);
  }
}

//---------------------------------------------
void cp5_record(boolean b) {
  if (b) {
    // start recording
    println("R* START");
  } else {
    // end recording
    saveTable(recordData, "data/"+utils_getUniqueFileName()+".csv");
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
void cp5_getStatus() {
  serial.sendCommand( Serial3D.GET_IS_CALIBRATED );
  serial.sendCommand( Serial3D.GET_IS_LOCKED );
  //arduino.write("?s\n");
  //arduino.write("?mm\n");
}

//---------------------------------------------
void cp5_unlock() {
  serial.sendCommand( Serial3D.UNLOCK );
}
void cp5_lock() {
  serial.sendCommand( Serial3D.LOCK );
}

//---------------------------------------------
void cp5_calibrate0() {
  serial.sendCommand( Serial3D.CALIBRATE_A );
}
void cp5_calibrate1() {
  serial.sendCommand( Serial3D.CALIBRATE_B );
}
void cp5_calibrate2() {
  serial.sendCommand( Serial3D.CALIBRATE_C );
}
void cp5_calibrate3() {
  serial.sendCommand( Serial3D.CALIBRATE_D );
}

//---------------------------------------------
void cp5_cw0() {
  serial.sendCommand( Serial3D.STEP_CW_A );
}
void cp5_cw1() {
  serial.sendCommand( Serial3D.STEP_CW_B );
}
void cp5_cw2() {
  serial.sendCommand( Serial3D.STEP_CW_C );
}
void cp5_cw3() {
  serial.sendCommand( Serial3D.STEP_CW_D );
}

//---------------------------------------------
void cp5_ccw0() {
  serial.sendCommand( Serial3D.STEP_CCW_A );
}
void cp5_ccw1() {
  serial.sendCommand( Serial3D.STEP_CCW_B );
}
void cp5_ccw2() {
  serial.sendCommand( Serial3D.STEP_CCW_C );
}
void cp5_ccw3() {
  serial.sendCommand( Serial3D.STEP_CCW_D );
}

//---------------------------------------------
void cp5_zero0() {
  serial.sendCommand( Serial3D.ZERO_A );
}
void cp5_zero1() {
  serial.sendCommand( Serial3D.ZERO_B );
}
void cp5_zero2() {
  serial.sendCommand( Serial3D.ZERO_C );
}
void cp5_zero3() {
  serial.sendCommand( Serial3D.ZERO_D );
}