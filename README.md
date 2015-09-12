# SyntheticAerialRobotics #

Working repository for control software and Arduino code to choreograph a robotic performance. Using 4 stepper motors, drivers and software. This repository is started during a two month residency at [Laboratory](http://laboratoryspokane.com) Spokane and is a development of an original project [Choreographed Synthetic Temperaments in Aerial Robotics](http://lukesturgeon.co.uk/Choreographed-Synthetic-Temperaments-in-Aerial-Robotics).

---

## Arduino ##

#### AccelStepper_x4
A working sketch that allows serial communication to control and calibrate four stepper motors simultaniously.

##### Commands
- s = sleep
- w = wake
- u = unlock
- l = lock

- ccw0 = 1 step counterclockwise for motor 0
- cw2 = 1 step clockwise for motor 2
- z1 = set current position to zero for motor 1
- c3 = start calibration process for motor 3

- ?l = get locked status
- ?s = get sleep status
- ?c = get calibration status (all four motors)

---

## Processing ##

#### single_stepper_controller
A working sketch that includes all basic interface elements necessary to interact with a single motor.

#### SyntheticAerialRoboticsInterface
A working sketch to visualise and measure the position of the actor in 3D space. Using real-world measurements in CM to construct the box, all values afterwards will work at that scale.

---

## Datasheets ##

The specifications for the components used for this particular installation. Stepper motors and A4988 Polulo stepper driver.

---

## Design Files ##

- quadstepper.fzz : The circuit diagram and components created in Fritzing.
- powersupply.pdf : The power supply used for the installation 12V 5A
- motor-unit.ai : The illustrator file used to fabricate the acrylic sheets to assemble the four motor units. This file is to scale but some measurements are imprecise. File reflects the changes made manually to the current working acrylic sheets.