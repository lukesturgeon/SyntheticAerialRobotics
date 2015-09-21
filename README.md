# SyntheticAerialRobotics #

Working repository for control software and Arduino code to choreograph a robotic performance. Using 4 stepper motors, drivers and software. This repository is started during a two month residency at [Laboratory](http://laboratoryspokane.com) Spokane and is a development of an original project [Choreographed Synthetic Temperaments in Aerial Robotics](http://lukesturgeon.co.uk/Choreographed-Synthetic-Temperaments-in-Aerial-Robotics).

---

## Arduino ##

#### AccelStepper_x4
A working sketch that allows serial communication to control and calibrate four stepper motors simultaniously. At it's core is the Calibrated_AccelStepper class which extends the awesome [AccelStepper library](http://www.airspayce.com/mikem/arduino/AccelStepper/) to include a calibration method using a limit switch to wind in and then unwind the cables.

##### Commands
- 1,2,3,4 : four long int to move each motor to the new length in MM
- s : sleep
- w : wake
- u : unlock
- l : lock
- ccw0 : 1 step counterclockwise for motor 0
- cw2 : 1 step clockwise for motor 2
- z1 : set current position to zero for motor 1
- c3 : start calibration process for motor 3
- ms : set max speed
- ma : set max acceleration
- ?l : get locked status
- ?s : get sleep status
- ?c : et calibration status (all four motors)
- ?mm : get length in steps, mm not supported yet (all four motors)

---

## Processing ##

#### SyntheticAerialRoboticsInterface
A working sketch to visualise and measure the position of the actor in 3D space. Using real-world measurements in CM to construct the box, all values afterwards will work at that scale.

#### SyntheticTemperaments_Solo
A non-interactive working sketch to visualise and output the cable lenght (in mm) to control a 4-point mechanical pulley system. Built specifically for the Laboratory Gallery space in Spokane. This non interactive version includes a timed performance mode that randomises the forces to move the actor around the space, with a 5 minute sleep cycle to let the stepper motors rest.

#### single_stepper_controller
A working sketch that includes all basic interface elements necessary to interact with a single motor.

---

## Resources ##
- Datasheets for variable electronic components
- quadstepper.fzz : The circuit diagram and components created in Fritzing.
- powersupply.pdf : The power supply used for the installation 12V 5A
- motor-unit.ai : The illustrator file used to fabricate the acrylic sheets to assemble the four motor units. This file is to scale but some measurements are imprecise. File reflects the changes made manually to the current working acrylic sheets.
- installation-setup.ai : floorplan and dimensions for public installation at Laboratory Residency in Spokane, US.