/*
  A rocket that could be used in several different 2D video games.
 You control it with the arrow keys or 'a' and 'd' plus the mouse for thrust.
 The starry skies was also made possible...
 by Charlie McDowell
 */
 
 /* This program was further edited to add a background among other features such as fuel, oxygen, and a goal
 for landing with set conditions for success.
   By Mark Medved and Farhan Saeed
 */
 
 //arrays for the stars in the backround
int[] starX = new int[1000];
int[] starY = new int[1000];
color[] starC = new color[1000];
boolean start = false;

void setup() {
  size(500, 500);
  rocket = new Rocket(width/2, height/2);
  //gives each star in the array an x, y, and starting color
  for (int i =0; i < 1000; i++) {
    starX[i] = (int)random(width);
    starY[i] = (int)random(height);
    starC[i] = color((int)random(100, 255));
  }
}

Rocket rocket;  
float groundY = 475;
void draw() {
  background(0);
  //For loop to create a random background of twinkling stars
  for (int i = 0; i<1000; i++) {
    if (random(10) < 1) {
      starC[i] = (int)random(100, 255);
    }
    noStroke();
    fill(starC[i]);
    ellipse(starX[i], starY[i], 2, 2);
  }
  adjustControls(rocket); //sends data to control function to turn the rocket
  rocket.start(); //runs the start function

  fill(225);
  stroke(225);
  rect((width-width), groundY, width, groundY);
}



/*
  Control the rocket using mouseY for thrust and 'a' or left-arrow for rotating
 counter-clockwise and 'd' or right-arrow for rotating clockwise.
 It takes a single parameter, which is the rocket being controlled.
 */
void adjustControls(Rocket rocket) {
  if (start) { //once started, user is able to control rocket
    // control thrust with the y-position of the mouse
    if (mouseY < height/2) {
      rocket.setThrust(height/2 - mouseY);
    } else {
      rocket.setThrust(0);
    }
    // allow for right handed control with arrow keys or
    // left handed control with 'a' and 'd' keys

    // right hand rotate controls
    if (keyPressed) {
      if (key == CODED) { // tells us it was a "special" key
        if (keyCode == RIGHT) {
          rocket.rotateRocket(3);
        } else if (keyCode == LEFT) {
          rocket.rotateRocket(-3);
        }
      }
      // left hand rotate controls
      else if (key == 'a') {
        rocket.rotateRocket(-3);
      } else if (key == 'd') {
        rocket.rotateRocket(3);
      }
    }
  }
}