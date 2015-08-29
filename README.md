# SyntheticAerialRobotics #

Working repository for control software and Arduino code to choreograph a robotic performance. Using 4 stepper motors, drivers and software. This repository is started during a two month residency at [Laboratory](http://laboratoryspokane.com) Spokane and is a development of an original project [Choreographed Synthetic Temperaments in Aerial Robotics](http://lukesturgeon.co.uk/Choreographed-Synthetic-Temperaments-in-Aerial-Robotics).

---

## Arduino ##

##### AccelStepper_test
A working sketch that allows serial communication to control and calibrate a single motor driver.

##### AccelStepper_x2
A working sketch that allows serial communication to control and calibrate two stepper motors simultaniously.

---

## Processing ##

##### single_stepper_controller
A working sketch that includes all basic interface elements necessary to interact with a single motor.

##### SyntheticAerialRoboticsInterface
A working sketch to visualise and measure the position of the actor in 3D space. Using real-world measurements in CM to construct the box, all values afterwards will work at that scale.

---

## Datasheets ##

The specifications for the components used for this particular installation. Stepper motors and A4988 Polulo stepper driver.

---

## Design Files ##

- quadstepper.fzz : The circuit diagram and components created in Fritzing.
- powersupply.pdf : The power supply used for the installation 12V 5A
- motor-unit.ai : The illustrator file used to fabricate the acrylic sheets to assemble the four motor units. This file is to scale but some measurements are imprecise. File reflects the changes made manually to the current working acrylic sheets.