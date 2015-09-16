class WarningSystem {

  String  _warningMessage;

  boolean arduinoConnected = false;
  boolean motorAReady = false;
  boolean motorBReady = false;
  boolean motorCReady = false;
  boolean motorDReady = false;
  boolean isLocked = true;
  boolean isSleeping = false;
  boolean isSendingData = false;

  WarningSystem() {
    _warningMessage = "";
  }

  boolean isCalibrated() {
    if (motorAReady && motorBReady && motorCReady && motorDReady) {
      return true;
    } else {
      return false;
    }
  }

  void draw() {

    boolean showWarning = false;

    if (!arduinoConnected) {
      _warningMessage = "The Arduino has not been detected.";
      showWarning = true;
    } else if (isSleeping) {
      _warningMessage = "The system is sleeping";
      showWarning = true;
    } else if (!motorAReady) {
      _warningMessage = "Motor A must be calibrated";
      showWarning = true;
    } else if (!motorBReady) {
      _warningMessage = "Motor B must be calibrated";
      showWarning = true;
    } else if (!motorCReady) {
      _warningMessage = "Motor C must be calibrated";
      showWarning = true;
    } else if (!motorDReady) {
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