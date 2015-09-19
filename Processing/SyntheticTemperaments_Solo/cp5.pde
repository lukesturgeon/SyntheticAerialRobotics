void cp5_init() {
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
}

//---------------------------------------------
void cp5_randomizePerformance() {
  println("== randomize performance ==");
  cp5.getController("cp5_windx").setValue(random(-0.2, 0.2));
  cp5.getController("cp5_windz").setValue(random(-0.2, 0));
  //
  cp5.getController("oscVelocity").setValue(random(0.01, 0.4));
  cp5.getController("oscStrength").setValue(random(0, 0.4));
  cp5.getController("wanderStrength").setValue(random(0, 0.4));
  cp5.getController("cp5_mass").setValue(random(2, 40));
}

void cp5_restPerformance() {
  println("== rest performance ==");
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