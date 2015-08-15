#include <AccelStepper.h>
#include "Calibrated_AccelStepper.h"

boolean isSystemLocked = true;
const int numMotors = 2;

Calibrated_AccelStepper stepper[numMotors] {
  Calibrated_AccelStepper(3, 2, 4),
  Calibrated_AccelStepper(6, 5, 7)
};


void setup()
{
  // initialise the motors
  for (int i = 0; i < numMotors; i++)
  {
    stepper[i].setMinPosition(0);
    stepper[i].setMaxPosition(3600);
    stepper[i].setMaxSpeed(1000.0);
    stepper[i].setAcceleration(500.0);
  }

  Serial.begin(115200);
}

void loop()
{
  for (int i = 0; i < numMotors; i++)
  {
    if ( stepper[i].isCalibrating() )
    {
      stepper[i].runCalibration();
    }

    if (!isSystemLocked)
    {
      if ( !stepper[i].isSensorBlocked() )
      {
        stepper[i].run();
      }
      else
      {
        // A hard stop is used if the motor is blocked
        // Will set the target position to the current position
        // To stop movement when the motor is run again
        for (int j = 0; j < numMotors; j++)
        {
          stepper[j].setSpeed(0.0);
          stepper[j].moveTo( stepper[j].currentPosition() );
        }
        isSystemLocked = true;
        Serial.println("l=1");
        return;
      }
    }
  }
}

void serialEvent()
{
  static char buffer[80];
  if (readline(Serial.read(), buffer, 80) > 0) {
    // Convert buffer to a string
    String str = String(buffer);

    // - - - - - - MOVE - - - - - - -

    // move x mm
    if ( str.startsWith("a") && !isSystemLocked ) {
      float len = str.substring(1).toInt();
      stepper[0].moveToMM(len);
    }

    if ( str.startsWith("b") && !isSystemLocked ) {
      float len = str.substring(1).toInt();
      stepper[1].moveToMM(len);
    }

    if ( str.startsWith("c") && !isSystemLocked ) {
      float len = str.substring(1).toInt();
      stepper[2].moveToMM(len);
    }

    if ( str.startsWith("d") && !isSystemLocked ) {
      float len = str.substring(1).toInt();
      stepper[3].moveToMM(len);
    }

    //move x steps
    if ( str.startsWith("s") && !isSystemLocked ) {
      int step = str.substring(1).toInt();
      stepper[0].moveTo(step);
    }

    // - - - - - - LOCK - - - - - - -

    if ( str.equals("u") ) {
      isSystemLocked = false;
      Serial.println("l=0");
    }

    if ( str.equals("l") ) {
      isSystemLocked = true;
      Serial.println("l=1");
    }

    // - - - - - - CALIBRATE - - - - - - -

    if ( str.equals("cw") ) {
      stepper[0].move(1);
    }

    if ( str.equals("ccw") ) {
      stepper[0].move(-1);
    }

    if ( str.equals("z") ) {
      stepper[0].setCurrentPosition(0);
    }

    if ( str.equals("c") ) {
      isSystemLocked = true;
      stepper[0].initCalibration();
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
      Serial.println(stepper[0].currentPosition());
    }

    if ( str.equals("?c") ) {
      Serial.print("c=");
      Serial.println(stepper[0].isCalibrated());
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
