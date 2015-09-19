import controlP5.*;

final int           ANGER_TEMPERAMENT = 0;
final int           FEAR_TEMPERAMENT = 1;
final int           SURPRISE_TEMPERAMENT = 2;
final int           DISGUST_TEMPERAMENT = 3;
final int           HAPPINESS_TEMPERAMENT = 4;
final int           SADNESS_TEMPERAMENT = 5;

final float         WIDTH_CM = 301.00; // left to right (in cm)
final float         DEPTH_CM = 290.52; // front to back (in cm)
final float         HEIGHT_CM = 279.40; // top to bottom (in cm)
final int           NUM_MOTORS = 4; // controls the loops and settings
final int           SLEEP_AFTER_MILLIS = 1000*60*10; // seconds until we should sleep

float               scaleCM = 100.0; // default size to scale down to
float               worldRotationX = 0.0;
float               worldRotationY = 0.0;

ControlP5           cp5;
Box3d               room3d;
Box3d               safeZone3d;
Motor3d[]           motor;
//Target3d            actorTarget;
Target3d            actor;

Target3d            origin;
float               originStrength;
float               wandertheta;
float               wanderStrength;
PVector             wind = new PVector();
float               oscAmount;
float               oscVelocity;
float               oscStrength;
float               oscHorizontal;

int                 performanceTimer;

PFont               headingFont;
PFont               bodyFont;

void setup() {
  // to improve performance and run less maths calculations
  frameRate(30);

  // aesthetics
  size(1400, 740, P3D);
  smooth(8);
  headingFont = loadFont("fonts/AkzidenzGrotesk-Bold-24.vlw");
  bodyFont = loadFont("fonts/AkzidenzGrotesk-Roman-11.vlw");

  // math
  motor = new Motor3d[4];
  motor[0] = new Motor3d(-WIDTH_CM/2, -HEIGHT_CM/2, -DEPTH_CM/2);
  motor[0].setLabel("A");
  motor[1] = new Motor3d(WIDTH_CM/2, -HEIGHT_CM/2, -DEPTH_CM/2);
  motor[1].setLabel("B");
  motor[2] = new Motor3d(WIDTH_CM/2, -HEIGHT_CM/2, DEPTH_CM/2);
  motor[2].setLabel("C");
  motor[3] = new Motor3d(-WIDTH_CM/2, -HEIGHT_CM/2, DEPTH_CM/2);
  motor[3].setLabel("D");

  room3d = new Box3d(
    -WIDTH_CM/2, 
    -HEIGHT_CM/2, 
    -DEPTH_CM/2, 
    WIDTH_CM/2, 
    HEIGHT_CM/2, 
    DEPTH_CM/2  );

  safeZone3d = new Box3d(
    -WIDTH_CM/2, 
    -HEIGHT_CM/2+50, 
    -DEPTH_CM/2, 
    WIDTH_CM/2, 
    HEIGHT_CM/2-50, 
    DEPTH_CM/2  );

  // start in center of floor
  //actorTarget = new Target3d(0, -HEIGHT_CM/2, 0);
  //actorTarget.mass = 30;
  actor = new Target3d(0, 0, 0);
  actor.mass = 10;
  origin = new Target3d(0, 0, 0);

  cp5_init();

  // call this initially to apply some forces to things
  cp5_randomizePerformance();
}

void draw() {

  // UPDATE THE PERFORMANCE
  if (millis()-performanceTimer > 1000*30) {
    performanceTimer = millis();
    int hour = hour();
    int min = minute();

    println(nf(hour, 2)+":"+ nf(min, 2));

    // PERFORMANCE CODE
    if (hour < 7) {
      // sleep
      println("between 00:00 and 07:00 so turn off all forces and let the installation sleep");
    } 
    // otherwise must be awake
    // randomize the performance every 1 mins for 5 mins
    else if ((min < 05) || 
      (min > 10 && min < 15) || 
      (min > 20 && min < 25) || 
      (min > 30 && min < 35) || 
      (min > 40 && min < 45) ||
      (min > 50 && min < 55)  ) {
      cp5_randomizePerformance();
    } else {
      cp5_restPerformance();
    }
  }

  // MOVING STUFF
  actor.applyForce(wind);

  // Oscillating y
  oscAmount += oscVelocity;
  PVector osc = new PVector(0, sin(oscAmount)*oscStrength, 0);
  actor.applyForce(osc);

  // Random wander
  float wanderR = 16.0f;         // Radius for our "wander circle"
  float wanderD = 60.0f;         // Distance for our "wander circle"
  float wanderChange = 0.25f;
  wandertheta += random(-wanderChange, wanderChange);     // Randomly change wander theta

  // Now we have to calculate the new location to steer towards on the wander circle
  PVector circleloc = actor.velocity.get();  // Start with velocity
  circleloc.normalize();            // Normalize to get heading
  circleloc.mult(wanderD);          // Multiply by distance
  circleloc.add(actor);               // Make it relative to boid's location

  PVector circleOffSet = new PVector(wanderR*cos(wandertheta), wanderR*sin(wandertheta), wanderR*tan(wandertheta));
  PVector target = PVector.add(circleloc, circleOffSet);
  actor.seek(target, wanderStrength);

  // always try to return to the origin
  actor.arrive(origin, originStrength, 100);

  // constrain the position
  actor.stayInsideBox(safeZone3d);

  actor.update();


  // DRAWING STUFF
  background(#020320);
  pushMatrix();
  translate(width/2, (height/2), scaleCM);
  rotateX(worldRotationX);
  rotateY(worldRotationY);
  draw3d();
  // save position for 2d rendering
  actor.calculate2d();
  for (int i = 0; i < NUM_MOTORS; i++) {
    motor[i].calculate2d();
  }
  popMatrix();
  draw2d();
}

void draw3d() {
  //draw frame
  noFill();
  stroke(#ABBDCE);
  room3d.draw();
  stroke(150, 50, 150);
  safeZone3d.draw();
  //box(WIDTH_CM, HEIGHT_CM, DEPTH_CM);

  // draw floor
  stroke(#ABBDCE);
  for (int i = 0; i < 10; i++) {
    line(-WIDTH_CM/2, HEIGHT_CM/2, map(i, 0, 10, DEPTH_CM/2, -DEPTH_CM/2), 
      WIDTH_CM/2, HEIGHT_CM/2, map(i, 0, 10, DEPTH_CM/2, -DEPTH_CM/2));
    line(map(i, 0, 10, -WIDTH_CM/2, WIDTH_CM/2), HEIGHT_CM/2, -DEPTH_CM/2, 
      map(i, 0, 10, -WIDTH_CM/2, WIDTH_CM/2), HEIGHT_CM/2, DEPTH_CM/2);
  }

  // draw cables
  stroke(255);
  for (int i = 0; i < 4; i++) {
    line(motor[i].x, motor[i].y, motor[i].z, 
      actor.x, actor.y, actor.z);
  }

  // draw forces
  stroke(150, 50, 150);
  line(origin.x, origin.y, origin.z, actor.x, actor.y, actor.z);
}

void draw2d() {
  pushStyle();
  noStroke();
  fill(150, 50, 150);
  ellipse(width/2, height/2, 5, 5);  
  fill(255);
  ellipse(actor.screenX, actor.screenY, actor.mass, actor.mass);
  popStyle();

  for (int i = 0; i < NUM_MOTORS; i++) {
    motor[i].draw2d();
  }

  pushMatrix();
  translate(width/2, height-120);
  pushStyle();

  noStroke();
  fill(255, 255, 0);
  rect(-50, -20, 100, 40);

  fill(0);
  textAlign(CENTER, CENTER);
  textFont(headingFont, 24);
  text(nf(hour(), 2)+":"+nf(minute(), 2)+":"+nf(second(), 2), 0, 0);

  popStyle();
  popMatrix();
}

void mouseDragged() {
  if (keyPressed && key == ' ') {
    // add x/y to the rotation
    worldRotationX -= (mouseY-pmouseY) * 0.01;
    worldRotationY += (mouseX-pmouseX) * 0.01;
  }

  // x3 axis movement
  else if (keyPressed && key == 'q') {
    println("move it");
    // take the y as the actor y position
    //actorTarget.y += mouseY-pmouseY;

    // take the x ans the depth or width (dpends on orientation)
    float angle = worldRotationY % TWO_PI;
    float absAngle = abs(angle);
    if (absAngle > PI*0.25 && absAngle < PI*0.75) {
      // right side
      if (worldRotationY > 0) {
        //actorTarget.z += mouseX-pmouseX;
      } else {
        //actorTarget.z -= mouseX-pmouseX;
      }
    } else if (absAngle > PI*1.25 && absAngle<PI*1.75) {
      // left side
      if (worldRotationY > 0) {
        //actorTarget.z -= mouseX-pmouseX;
      } else {
        //actorTarget.z += mouseX-pmouseX;
      }
    } else if (absAngle > PI*0.75 && absAngle < PI*1.25) {
      // back
      //actorTarget.x -= mouseX-pmouseX;
    } else {
      //actorTarget.x += mouseX-pmouseX;
    }

    // constrain just in case
    //actorTarget.x = constrain(actorTarget.x, -WIDTH_CM/2, WIDTH_CM/2);
    //actorTarget.y = constrain(actorTarget.y, -HEIGHT_CM/2, HEIGHT_CM/2);
    //actorTarget.z = constrain(actorTarget.z, -DEPTH_CM/2, DEPTH_CM/2);
  }
}

void mouseWheel(MouseEvent e) {
  // adjust the scale to give the impression of zoom in/out
  float count = e.getCount() * 10;
  scaleCM += count;
}