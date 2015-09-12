class WarningSystem {

  String  _value;

  boolean arduinoConnected = false;
  boolean motorAReady = false;
  boolean motorBReady = false;
  boolean motorCReady = false;
  boolean motorDReady = false;
  boolean isSystemLocked = true;
  boolean isSendingData = false;

  WarningSystem() {
    _value = "";
  }

  void draw() {

    boolean hasError = false;

    if (!arduinoConnected) {
      _value = "The Arduino has not been detected.";
      hasError = true;
    } else if (!motorAReady) {
      _value = "Motor A must be calibrated";
      hasError = true;
    } else if (!motorBReady) {
      _value = "Motor B must be calibrated";
      hasError = true;
    } else if (!motorCReady) {
      _value = "Motor C must be calibrated";
      hasError = true;
    } else if (!motorDReady) {
      _value = "Motor D must be calibrated";
      hasError = true;
    } else if (isSystemLocked) {
      _value = "The System is locked!";
      hasError = true;
    } else if (!isSendingData) {
      _value = "No data is being sent";
      hasError = true;
    }

    // draw the error
    if (hasError) {
      pushStyle();

      noStroke();
      fill(255, 255, 0);
      float w = _value.length() * 9;
      rect(mouseX-(w/2), mouseY-24, w, 32);

      fill(0);
      textSize(16);
      textAlign(CENTER, BOTTOM);
      text(_value, mouseX, mouseY);
      popStyle();
    }
  }
}