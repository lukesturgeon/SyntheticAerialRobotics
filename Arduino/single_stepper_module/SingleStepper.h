/**
 * Controller class for a custom module using the A4988 stepper driver.
 *
 * By Luke Sturgeon <hello@lukesturgeon.co.uk>
 */

#include <Arduino.h>

class StepperModule
{
  public:

    bool isCalibrated;
    bool isCalibratingIn;
    bool isCalibratingOut;

    StepperModule() {
      // Set default steps
      currentStep = targetStep = 0;
      minSteps = 0;
      maxSteps = 1800;
      isCalibrated = isCalibratingIn = isCalibratingOut = false;
    };

    void setup(int _dirPin, int _stepPin, int _sensorPin) {
      dirPin = _dirPin;       // yellow
      stepPin = _stepPin;     // green
      sensorPin = _sensorPin; // red
      pinMode(dirPin, OUTPUT);
      pinMode(stepPin, OUTPUT);
    }

    void calibrate() {
      isCalibrated = false;
      isCalibratingIn = true;
      isCalibratingOut = false;
    }

    void doNextCalibration() {
      if (isCalibratingIn) {
        // are we close enough
        if ( isLocked() ) {
          isCalibratingIn = false;
          isCalibratingOut = true;
        } else {
          // move closer
          stepCCW();
        }
      }

      if (isCalibratingOut) {
        // are we far enough
        if (isLocked()) {
          // move out
          stepCW();
        } else {
          // stop
          isCalibratingOut = false;
          isCalibrated = true;

          // move out a few times to be safe
          for (int i = 0; i < 10; i++) {
            stepCW();
            delay(10);
          }
          zero();
          Serial.println("READY");
        }
      }
    }

    void moveTo(int _step) {
      targetStep = _step;
    }

    void moveToMM(int _targetLength) {
      float stepsPerRevolution = 400.0f;
      float lengthPerRevolution = 200.0f;

      int numSteps = int( (stepsPerRevolution / lengthPerRevolution) * (float)_targetLength );

//      targetStep = numSteps;

      Serial.print(_targetLength);
      Serial.print("mm = ");
      Serial.print(numSteps);
      Serial.println("steps");
    }

    void zero() {
      currentStep = 0;
      targetStep = 0;
    }

    void doNextStep() {
      if (currentStep < targetStep && currentStep < maxSteps) {
        // more cable
        stepCW();
        currentStep++;
      }

      if (currentStep > targetStep && currentStep > minSteps) {
        // less cable
        stepCCW();
        currentStep--;
      }
    }

    void stepCW() {
      // step once
      digitalWrite(dirPin, HIGH);
      digitalWrite(stepPin, HIGH);
      digitalWrite(stepPin, LOW);
    }

    void stepCCW() {
      // step once
      digitalWrite(dirPin, LOW);
      digitalWrite(stepPin, HIGH);
      digitalWrite(stepPin, LOW);
    }

    bool isLocked() {
      // check if the pushbutton is down and disable motor
      if (digitalRead(sensorPin) == HIGH) {
        return true;
      }

      // if the sensor isn't on
      return false;
    }

    int getCurrentStep() {
      return currentStep;
    }

    int getTargetStep() {
      return targetStep;
    }

    int getCurrentLength() {
      // TODO
      return currentStep;
    }

  private:
    int sensorPin;

    int dirPin;
    int stepPin;
    int currentStep;
    int targetStep;
    int minSteps;
    int maxSteps;
};
