import processing.serial.*;

class Serial3D {

  // LOCK SYSTEM
  static final String UNLOCK            = "u\n";
  static final String LOCK              = "l\n";
  static final String GET_IS_LOCKED     = "?l\n"; // will return "l=0 / l=1"

  // CALIBRATE
  static final String CALIBRATE_A       = "c0\n";
  static final String CALIBRATE_B       = "c1\n";
  static final String CALIBRATE_C       = "c2\n";
  static final String CALIBRATE_D       = "c3\n";
  static final String ZERO_A            = "z0\n";
  static final String ZERO_B            = "z1\n";
  static final String ZERO_C            = "z2\n";
  static final String ZERO_D            = "z3\n";
  static final String GET_IS_CALIBRATED = "?c\n"; // will return all 4 motors "c=0,1,0,0,1"

  // MOVEMENT
  static final String STEP_CW_A         = "cw0\n";
  static final String STEP_CW_B         = "cw1\n";
  static final String STEP_CW_C         = "cw2\n";
  static final String STEP_CW_D         = "cw3\n";
  static final String STEP_CCW_A         = "ccw0\n";
  static final String STEP_CCW_B         = "ccw1\n";
  static final String STEP_CCW_C         = "ccw2\n";
  static final String STEP_CCW_D         = "ccw3\n";
  
  Serial thePort;

  Serial3D() {
  }

  boolean connect(PApplet target, String portName, int baudRate) {
    boolean portDetected = false;
    String[] availablePorts = Serial.list();

    for (int i = 0; i < availablePorts.length; i++) {
      if (availablePorts[i].equals(portName)) {
        thePort = new Serial(target, portName, baudRate);
        thePort.bufferUntil('\n');
        portDetected = true;
        break;
      }
    }


    return portDetected;
  }

  /**
   * Sends a predefined string to the arduino
   */
  void sendCommand( String cmd ) {
    thePort.write( cmd );
  }
}