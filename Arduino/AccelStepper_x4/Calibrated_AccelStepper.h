class Calibrated_AccelStepper : public AccelStepper
{
  public :

    Calibrated_AccelStepper(int stepPin, int dirPin, int sensorPin) :
      AccelStepper(AccelStepper::DRIVER, stepPin, dirPin) {
      _stepPin = stepPin;
      _dirPin = dirPin;
      _sensorPin = sensorPin;
      _isCalibrated = _isCalibratingIn = _isCalibratingOut = false;
      _isFreeStepping = false;
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
          _isCalibrated = true;
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

    bool isFreeStepping() {
      return _isFreeStepping;
    }

    void freeStep(int steps) {
      _isFreeStepping = true;
      move(steps);
    }

    void runFreeStep() {
      if (distanceToGo() == 0) {
        _isFreeStepping = false;
      } else {
        run();
      }
    }

    void stepCW() {
      digitalWrite(_dirPin, HIGH);
      digitalWrite(_stepPin, HIGH);
      digitalWrite(_stepPin, LOW);
    }

    void stepCCW() {
      digitalWrite(_dirPin, LOW);
      digitalWrite(_stepPin, HIGH);
      digitalWrite(_stepPin, LOW);
    }

    void moveToMM(float len) {
      float stepsPerRevolution = 400.0f;
      float lengthPerRevolutionMM = 200.0f;
      int numSteps = int( (stepsPerRevolution / lengthPerRevolutionMM) * len );

      // constrain
      if (_minSteps != -1 && numSteps < _minSteps)
      {
        // limit the target
        moveTo(_minSteps);
      }
      else if (_maxSteps != -1 && numSteps > _maxSteps)
      {
        // limit the target
        moveTo(_maxSteps);
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
    void setMinSteps(int p) {
      _minSteps = p;
    }

    /**
     * Set the maximum position in steps that motor can move to
     */
    void setMaxSteps(int p) {
      _maxSteps = p;
    }

  private:
    bool  _isCalibrated;
    bool  _isCalibratingIn;
    bool  _isCalibratingOut;
    bool  _isFreeStepping;
    int   _stepPin;
    int   _dirPin;
    int   _sensorPin;
    int   _minSteps = -1;
    int   _maxSteps = -1;
};
