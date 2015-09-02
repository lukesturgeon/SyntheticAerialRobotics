void cp5_init() {
  cp5 = new ControlP5(this);

  cp5.addSlider("easing")
    .setRange(0.001, 0.5)
    .setPosition(20, 20)
    .setSize(150, 20);

  // loading prerecorded paths
  cp5.addTextlabel("recording")
    .setValueLabel("> PATH RECORDING")
    .setPosition(20, 130);

  cp5.addButton("cp5_loadData")
    .setLabel("loaddata...")
    .setPosition(20, 150)
    .setSize(150, 20);

  cp5.addToggle("cp5_record")
    .setLabel("Record")
    .setPosition(20, 180)
    .setSize(70, 20);

  cp5.addToggle("cp5_playback")
    .setLabel("Playback")
    .setPosition(100, 180)
    .setSize(70, 20);

  //framerate debug
  cp5.addFrameRate().setInterval(10).setPosition(17, height - 30);

  cp5.addButton("cp5_getStatus")
    .setBroadcast(false)
    .setLabel("get status")
    .setPosition(20, 280)
    .setSize(150, 20)
    .setBroadcast(true);

  cp5.addButton("cp5_unlock")
    .setBroadcast(false)
    .setLabel("unlock")
    .setPosition(20, 310)
    .setSize(150, 20)
    .setBroadcast(true);

  cp5.addButton("cp5_lock")
    .setBroadcast(false)
    .setLabel("lock")
    .setPosition(20, 340)
    .setSize(150, 20)
    .setBroadcast(true);

  // CALIBRATON
  cp5.addTextlabel("calibration")
    .setValueLabel("CALIBRATED")
    .setPosition(20, 420);  

  // nudge
  cp5.addTextlabel("nudge")
    .setValueLabel("+/- STEP")
    .setPosition(20, 490);

  // clockwise
  cp5.addTextlabel("length")
    .setValueLabel("LENGTH (CM)")
    .setPosition(20, 570);

  for (int i = 0; i < 4; i++) {

    // calibration
    cp5.addToggle("cp5_calibrate"+i)
      .setBroadcast(false)
      .setLabel(str(i))
      .setPosition(20+(i*40), 440)
      .setSize(30, 20)
      .setBroadcast(true);

    // counter-clockwise
    cp5.addBang("cp5_ccw"+i)
      .setBroadcast(false)
      .setLabelVisible(false)
      .setPosition(20+(i*40), 510)
      .setSize(30, 20)
      .setBroadcast(true);

    // clockwise
    cp5.addBang("cp5_cw"+i)
      .setBroadcast(false)
      .setLabelVisible(false)
      .setPosition(20+(i*40), 532)
      .setSize(30, 20)
      .setBroadcast(true);

    // length slider
    cp5.addSlider("cp5_length"+i)
      .setLabel(str(i))
      .setLock(true)
      .setRange(0, 2300)
      .setPosition(20, 590+(i*22))
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

void playback(boolean b) {
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
  arduino.write("?c\n");
  arduino.write("?l\n");
  //arduino.write("?s\n");
  //arduino.write("?mm\n");
}

//---------------------------------------------
void cp5_unlock() {
  arduino.write("u\n");
}
void cp5_lock() {
  arduino.write("l\n");
}

//---------------------------------------------
void cp5_calibrate0(boolean b) {
  if (b) {
    arduino.write("c0\n");
  }
}
void cp5_calibrate1(boolean b) {
  if (b) {
    arduino.write("c1\n");
  }
}
void cp5_calibrate2(boolean b) {
  if (b) {
    arduino.write("c2\n");
  }
}
void cp5_calibrate3(boolean b) {
  if (b) {
    arduino.write("c3\n");
  }
}

//---------------------------------------------
void cp5_cw0() {
  println("nudge 0 cw 100 steps");
}