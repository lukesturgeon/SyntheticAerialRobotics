class System {

  String  _warningMessage;

  boolean isArduinoConnected = false;
  boolean isMotorAReady = true;
  boolean isMotorBReady = true;
  boolean isMotorCReady = true;
  boolean isMotorDReady = true;
  boolean isLocked = true;
  boolean isSleeping = false;
  boolean isSendingData = false;

  System() {
    _warningMessage = "";
  }

  boolean isCalibrated() {
    if (isMotorAReady && isMotorBReady && isMotorCReady && isMotorDReady) {
      return true;
    } else {
      return false;
    }
  }

  void draw() {

    boolean showWarning = false;

    if (!isArduinoConnected) {
      _warningMessage = "The Arduino has not been detected.";
      showWarning = true;
    } else if (isSleeping) {
      _warningMessage = "The system is sleeping";
      showWarning = true;
    } else if (!isMotorAReady) {
      _warningMessage = "Motor A must be calibrated";
      showWarning = true;
    } else if (!isMotorBReady) {
      _warningMessage = "Motor B must be calibrated";
      showWarning = true;
    } else if (!isMotorCReady) {
      _warningMessage = "Motor C must be calibrated";
      showWarning = true;
    } else if (!isMotorDReady) {
      _warningMessage = "Motor D must be calibrated";
      showWarning = true;
    } else if (isLocked) {
      _warningMessage = "The system is locked!";
      showWarning = true;
    } else if (!isSendingData) {
      _warningMessage = "No data is being sent";
      showWarning = true;
    } 

    // draw the error
    if (showWarning) {
      pushMatrix();
      translate(width/2, height-60);
      pushStyle();

      noStroke();
      fill(255, 255, 0);
      float w = _warningMessage.length() * 13;
      rect(-(w/2), -20, w, 40);

      fill(0);
      textAlign(CENTER, CENTER);
      textFont(headingFont, 24);
      text(_warningMessage, 0, 0);

      popStyle();
      popMatrix();
    }
  }
}