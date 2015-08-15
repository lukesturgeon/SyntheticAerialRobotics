#include <AccelStepper.h>
#include "Calibrated_AccelStepper.h"

boolean isSystemLocked = true;

Calibrated_AccelStepper stepper1(3, 2, 4); // step, dir, sensor

void setup()
{
  stepper1.setMinPosition(0);
  stepper1.setMaxPosition(3600);
  stepper1.setMaxSpeed(1000.0);
  stepper1.setAcceleration(500.0);
  Serial.begin(115200);
}

void loop()
{
  if ( stepper1.isCalibrating() ) {
    stepper1.runCalibration();
  }

  if (!isSystemLocked)
  {
    if ( !stepper1.isSensorBlocked() )
    {
      stepper1.run();
    }
    else
    {
      // A hard stop is used if the motor is blocked
      // Will set the target position to the current position
      // To stop movement when the motor is run again
      stepper1.setSpeed(0.0);
      stepper1.moveTo( stepper1.currentPosition() );
      isSystemLocked = true;
      Serial.println("l=1");
    }
  }
}

void serialEvent()
{
  static char buffer[80];
  if (readline(Serial.read(), buffer, 80) > 0) {
    // Convert buffer to a string
    String str = String(buffer);

    if ( str.equals("u") ) {
      isSystemLocked = false;
      Serial.println("l=0");
    }

    if ( str.equals("l") ) {
      isSystemLocked = true;
      Serial.println("l=1");
    }

    // - - - - - - SET - - - - - - -

    //move x steps
    if ( str.startsWith("s") && !isSystemLocked ) {
      int step = str.substring(1).toInt();
      stepper1.moveTo(step);
    }

    // move x mm
    if ( str.startsWith("m") && !isSystemLocked ) {
      float len = str.substring(1).toInt();
      stepper1.moveToMM(len);
    }

    if ( str.equals("cw") ) {
      stepper1.move(1);
    }

    if ( str.equals("ccw") ) {
      stepper1.move(-1);
    }

    if ( str.equals("z") ) {
      stepper1.setCurrentPosition(0);
    }

    if ( str.equals("c") ) {
      isSystemLocked = true;
      stepper1.initCalibration();
      // send lock status
      Serial.println("l=1");
    }

    // - - - - - - GET - - - - - - -
    if ( str.equals("?l") ) {
      Serial.print("l=");
      Serial.println(isSystemLocked);
    }

    if ( str.equals("?s") ) {
      Serial.print("s=");
      Serial.println(stepper1.currentPosition());
    }

    if ( str.equals("?c") ) {
      Serial.print("c=");
      Serial.println(stepper1.isCalibrated());
    }


    /*
        else if (str.indexOf(',') != -1) {
          //extract all 3 int values
          int a = atoi( strtok(buffer, ",") );
          int b = atoi( strtok(0, ",") );
          int c = atoi( strtok(0, ",") );
          Serial.println(a);
          Serial.println(b);
          Serial.println(c);
        }*/
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
