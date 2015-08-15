class Calibrated_AccelStepper : public AccelStepper
{
  public :

    Calibrated_AccelStepper(int stepPin, int dirPin, int sensorPin) :
      AccelStepper(AccelStepper::DRIVER, stepPin, dirPin) {
      _sensorPin = sensorPin;
      _isCalibrated = _isCalibratingIn = _isCalibratingOut = false;
    }

    /**
     * Check if the pushbutton is triggered
     */
    bool isSensorBlocked() {
      if (digitalRead(_sensorPin) == HIGH) {
        return true;
      } else {
        return false;
      }
    }

    /**
     * Start the calibration process
     * Next loop() will call runCalibration automatically
     */
    void initCalibration() {
      _isCalibrated = false;
      _isCalibratingIn = true;
      _isCalibratingOut = false;
    }

    void runCalibration()
    {
      if (_isCalibratingIn)
      {
        // pull in cable
        if (isSensorBlocked())
        {
          // we are close enough, start dropping
          _isCalibratingIn = false;
          _isCalibratingOut = true;
        } else {
          // move a little bit closer
          moveTo( currentPosition() - 1 );
        }
      }

      else if (_isCalibratingOut)
      {
        // release more cable
        if (distanceToGo() == 0 && isSensorBlocked())
        {
          // keep droping
          moveTo( currentPosition() + 10 );
        }
        else if (distanceToGo() == 0 && !isSensorBlocked())
        {
          // stop now and calibrate
          _isCalibratingIn = false;
          _isCalibratingOut = false;
          setSpeed(0.0);
          setCurrentPosition(0.0);
          moveTo( 0.0 );
        }
      }

      // call the run function ourselves
      run();
    }

    bool isCalibrating() {
      if (_isCalibratingIn || _isCalibratingOut) {
        return true;
      } else {
        return false;
      }
    }

    bool isCalibrated() {
      return _isCalibrated;
    }

    void moveToMM(float len) {
      float stepsPerRevolution = 400.0f;
      float lengthPerRevolutionMM = 200.0f;
      int numSteps = int( (stepsPerRevolution / lengthPerRevolutionMM) * len );

      Serial.print(len);
      Serial.print(" > ");
      Serial.println(numSteps);

      // constrain
      if (_minPosition != -1 && numSteps < _minPosition)
      {
        // limit the target
        moveTo(_minPosition);
      }
      else if (_maxPosition != -1 && numSteps > _maxPosition)
      {
        // limit the target
        moveTo(_maxPosition);
      }
      else
      {
        // do not limit
        moveTo(numSteps);
      }

    }

    /**
     * Set the minimum position in steps that motor can move to
     */
    void setMinPosition(int p) {
      _minPosition = p;
    }

    /**
     * Set the maximum position in steps that motor can move to
     */
    void setMaxPosition(int p) {
      _maxPosition = p;
    }

  private:
    bool  _isCalibrated;
    bool  _isCalibratingIn;
    bool  _isCalibratingOut;
    int   _sensorPin;
    int   _minPosition = -1;
    int   _maxPosition = -1;
};
