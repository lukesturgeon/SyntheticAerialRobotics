/**
 * Single stepper module
 * Using the quad-ethernet module -> ethernet driver module
 *
 * By Luke Sturgeon <hello@lukesturgeon.co.uk>
 */

#include "SingleStepper.h";

StepperModule motorA;

bool isSystemLocked = true;

void setup() {
  motorA.setup(2, 3, 4);
  Serial.begin(9600);
}

void loop() {

  if ( motorA.isCalibratingIn || motorA.isCalibratingOut ) {
    motorA.doNextCalibration();
    delay( 10 );
  }

  if (!isSystemLocked && !motorA.isLocked() ) {
    // step once
    motorA.doNextStep();
    delay( 10 );
  }
  else {
    // lock the setup
    isSystemLocked = true;
  }
}

void serialEvent() {
  static char buffer[80];
  if (readline(Serial.read(), buffer, 80) > 0) {

    // Convert buffer to a string
    String str = String(buffer);

    if ( str.equals("u") ) {
      isSystemLocked = false;
      Serial.println("UNLOCK");
    }

    if ( str.equals("l") ) {
      isSystemLocked = true;
      Serial.println("LOCK");
    }

    if ( str.startsWith("s") ) {
      int stp = str.substring(1).toInt();
      motorA.moveTo(stp);
    }

    if ( str.startsWith("mm") ) {
      int mm = str.substring(2).toInt();
      motorA.moveToMM(mm);
    }

    if ( str.equals("c") ) {
      isSystemLocked = true;
      motorA.calibrate();
    }

    if ( str.equals("z") ) {
      motorA.zero();
      Serial.println("ZERO");
    }

    if ( str.equals("cw") ) {
      motorA.stepCW();
    }

    if ( str.equals("ccw") ) {
      motorA.stepCCW();
    }

    if ( str.equals("?s") ) {
      Serial.print("s=");
      if (motorA.isLocked()) {
        Serial.println("<LOCKED>");
      } else {
        Serial.println(motorA.getCurrentStep());
      }
    }

    if ( str.equals("?mm") ) {
      Serial.print("mm=");
      if (motorA.isLocked()) {
        Serial.println("<LOCKED>");
      } else {
        Serial.println(motorA.getCurrentLength());
      }
    }

    if ( str.equals("?c") ) {
      Serial.print("c=");
      Serial.println(motorA.isCalibrated);
    }

    if ( str.equals("?l") ) {
      Serial.print("l=");
      Serial.println(isSystemLocked);
    }

    else if (str.indexOf(',') != -1) {
      //extract all 3 int values
      int a = atoi( strtok(buffer, ",") );
      int b = atoi( strtok(0, ",") );
      int c = atoi( strtok(0, ",") );
      Serial.println(a);
      Serial.println(b);
      Serial.println(c);
    }
  }
}

int readline(int readch, char *buffer, int len)
{
  static int pos = 0;
  int rpos;

  if (readch > 0) {
    switch (readch) {
      case '\n': // Return new-lines
        rpos = pos;
        pos = 0;  // Reset position index ready for next time
        return rpos;
      case '\r': // Ignore on CR
        break;
      default:
        if (pos < len - 1) {
          buffer[pos++] = readch;
          buffer[pos] = 0;
        }
    }
  }
  // No end of line has been found, so return -1.
  return -1;
}


