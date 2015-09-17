#include <AccelStepper.h>
#include "Calibrated_AccelStepper.h"

boolean isSystemLocked = true;
const int numMotors = 4;
const int sleepPin = A0;

// step,  dir,    sensor
// green, yellow, red
Calibrated_AccelStepper stepper[numMotors] {
  Calibrated_AccelStepper(3, 2, 4),
  Calibrated_AccelStepper(6, 5, 7),
  Calibrated_AccelStepper(9, 8, 10),
  Calibrated_AccelStepper(12, 11, 13)
};


void setup()
{
  // wake the arduino by default
  pinMode(sleepPin, OUTPUT);
  digitalWrite(sleepPin, HIGH);

  // initialise the motors
  for (int i = 0; i < numMotors; i++)
  {
    stepper[i].setMinSteps(0);
    stepper[i].setMaxSteps(3600);
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

    else if ( stepper[i].isFreeStepping() ) {
      stepper[i].runFreeStep();
    }

    else if (!isSystemLocked)
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

boolean isSleeping() {
  return (digitalRead(sleepPin) == LOW);
}

void wake() {
  digitalWrite(sleepPin, HIGH);
  Serial.println("s=0");
  delay(2); // allow a 2ms delay for the system to stabalize
}

void serialEvent()
{
  static char buffer[80];
  if (readline(Serial.read(), buffer, 80) > 0) {
    // Convert buffer to a string
    String str = String(buffer);

    // - - - - - - MOVE - - - - - - -

    if ( str.indexOf(',') > 0 ) {
      // assume its for numbers
      if (isSystemLocked) {
        Serial.println("l=1");
      }
      else {
        // we have received a command, so lets wake the system up
        if (isSleeping()) {
          wake();
        }

        //extract all values
        long a = atol( strtok(buffer, ",") );
        long b = atol( strtok(0, ",") );
        long c = atol( strtok(0, ",") );
        long d = atol( strtok(0, ",") );

        // update targets
        //      stepper[0].moveTo( mmToSteps(a) );
        //      stepper[1].moveTo( mmToSteps(b) );
        //      stepper[2].moveTo( mmToSteps(c) );
        stepper[3].moveToMM(d);


//        Serial.print("D : ");
//        Serial.println(d);
      }
    }

    else if ( str.startsWith("ccw") ) {
      if (isSleeping()) {
        // wake the system up
        wake();
      }
      int index = str.substring(3).toInt();
      stepper[index].freeStep(-100);
    }

    else if ( str.startsWith("cw") ) {
      if (isSleeping()) {
        // wake the system up
        wake();
      }
      int index = str.substring(2).toInt();
      stepper[index].freeStep(100);
    }

    else if ( str.startsWith("c") ) {
      if (isSleeping()) {
        // wake the system up
        wake();
      }
      int index = str.substring(1).toInt();
      isSystemLocked = true;
      stepper[index].initCalibration();
      // send lock status
      Serial.println("l=1");
    }

    // - - - - - - CONFIG - - - - - - -

    else if ( str.startsWith("ms") ) {
      int newSpeed = str.substring(2).toInt();
      for (int i = 0; i < numMotors; i++) {
        stepper[i].setMaxSpeed( newSpeed );
      }
    }

    else if ( str.startsWith("ma") ) {
      int newAcceleration = str.substring(2).toInt();
      for (int i = 0; i < numMotors; i++) {
        stepper[i].setAcceleration( newAcceleration );
      }
    }

    // - - - - - - SLEEP - - - - - - -

    else if ( str.equals("s") ) {
      digitalWrite(sleepPin, LOW);
      Serial.println("s=1");
    }

    else if ( str.equals("w") ) {
      digitalWrite(sleepPin, HIGH);
      Serial.println("s=0");
    }

    // - - - - - - LOCK - - - - - - -

    else if ( str.equals("u") ) {
      isSystemLocked = false;
      Serial.println("l=0");
    }

    else if ( str.equals("l") ) {
      isSystemLocked = true;
      Serial.println("l=1");
    }

    else if ( str.startsWith("z") ) {
      int index = str.substring(1).toInt();
      stepper[index].setCurrentPosition(0);
    }

    // - - - - - - GET - - - - - - -

    else if ( str.equals("?l") ) {
      Serial.print("l=");
      Serial.println(isSystemLocked);
    }

    else if ( str.equals("?s") ) {
      Serial.print("s=");
      Serial.println(isSleeping());
      //Serial.println( digitalRead(sleepPin) );
    }

    else if ( str.equals("?c") ) {
      String responseStr = "c=";
      for (int i = 0; i < numMotors; i++)
      {
        responseStr += stepper[i].isCalibrated();
        if (i < numMotors - 1) {
          responseStr += ",";
        }
      }
      Serial.println(responseStr);
    }

    else if ( str.equals("?mm") ) {
      String responseStr = "mm=";
      for (int i = 0; i < numMotors; i++)
      {
        responseStr += stepper[i].currentPosition();
        if (i < numMotors - 1) {
          responseStr += ",";
        }
      }
      Serial.println(responseStr);
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
