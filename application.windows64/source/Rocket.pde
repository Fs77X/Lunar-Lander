/*
  A simple rocket class, operating in a vacuum (no friction)
 but with gravity pulling it down.
 by Charlie McDowell 
 */

/* 
 The rocket class was further edited by Mark Medved and Farhan Saeed to add further features such as a fuel gauge
 oxygen supply among other things.
 */
class Rocket {
  /**
   Initial location of the rocket.
   @param startX - horizontal location
   @param startY - vertical location
   */
  Rocket(int startX, int startY) {
    x = startX;
    y = startY;
  }
  //Method used to track the amount of fuel and display it
  void fuel() {
    textSize(15);

    if (y < 475) {
      fuel = fuel - 11*thrust;
    }
    //Converts the fuel float from a messy number to a percentage
    String fuelLeft = nf((fuel/70)*100, 0, 2);
    float fuel1 = float (fuelLeft);
    fill(255, 0, 0);
    if (fuel> 0) {
      text("Fuel: ", 10, 30);
      text(fuel1 +" %", 50, 30);
    } else if (fuel <= 0) {
      text("No Fuel!", 10, 30);
    }
  }

  /*This method converts the velocity values from decimal numbers into nice integers
   and then displays the result on the screen */
  void speed() { 
    if (y<=475) { //if rocket isn't at touchdown altitude, then show speed real time
      float speedY = -yVel*100;
      String Yvel = nf(speedY, 0, 2);
      float downSpeedY = float(Yvel);
      text("Speed:", 10, 90);
      text(downSpeedY + " mph", 60, 90);
      float speedX = abs(xVel*100);
      String Xvel = nf(speedX, 0, 2);
      float horizSpeed = float(Xvel);
      text("Horizontal Speed:", 10, 70);
      text(horizSpeed + " mph", 150, 70);
    } else { //if rocket crashed or made a good landing, the rocket will be at a stop and it will display 0 mph
      text("Speed:", 10, 90);
      text("0" + " mph", 60, 90);
      text("Horizontal Speed: ", 10, 70);
      text("0" + "mph", 150, 70);
    }
  }

  /* This method is used to track the amount of oxygen which remains full when there is 
   fuel but once the fuel runs out, the oxygen is depleted until a warning message is 
   shown once there is no more oxygen. Once there's no more oxygen, controls are disabled to 
   show the crew is dead (NOTE: the code for this is in the rotateRocket function and it may
   take some time (without crashing) to see the rockets controls be disabled.*/
  void oxygen() {
    float o = O2;
    float f = fuel;
    if (O2 > 0) {
      text("Oxygen:", 10, 50);
      text(O2 + " seconds of Oxygen", 70, 50);
    }
    if (f <= 0) {
      if (frameCount%60==0) {
        O2 = O2 - 1;
        if (y>=475) { //once rocket crashes or lands and oxygen starts to decrease, we make oxygen stop decreasing
          O2 = o;
        }
      }
      if (O2 <= 0) {
        text("NO OXYGEN, CREW IS DYING!", 10, 50);
      }
    }
  }



  /**
   Decrease the thrust by the specified amount where decreasing by 100 will
   immediately reduce thrust to zero.
   */
  void setThrust(int amount) {
    amount = constrain(amount, 0, 100);
    thrust = MAX_THRUST*amount/100;
    if (thrust < 0 || fuel < 0 || crashed)
      thrust = 0;
  }

  /**
   Rotate the rocket positive means right or clockwise, negative means
   left or counter clockwise.
   */
  void rotateRocket(int amt) {
    float x= tilt;
    if (O2 > 0 && y <= 475) {
      tilt = tilt + amt*TILT_INC;
    } else if (O2 <= 0 || crashed || y >= 475) {
      tilt = x; //when crashed, rocket won't be able to turn
    }
  }

  /**
   Adjust the position and velocity, and draw the rocket.
   */
  void update() {
    x = x + xVel;
    y = y + yVel;
    xVel = xVel - cos(tilt)*thrust;
    yVel = yVel - sin(tilt)*thrust + GRAVITY;
    // to make it more stable set very small values to 0
    if (abs(xVel) < 0.00005) xVel = 0;
    if (abs(yVel) < 0.00005) yVel = 0;
    // draw it
    pushMatrix();
    translate(x, y);
    rotate(tilt - HALF_PI); 
    // draw the rocket thrust "flames"
    stroke(255, 0, 0);
    line(0, 0, 0, thrust * FLAME_SCALE);
    stroke(255);
    fill(255);
    // draw the rocket body
    drawRocket(x, y);
    popMatrix();
  }

  /*This method is uses a stored boolean value to check for whether or not the ship has crashed,
   which is false at first, and displays the explosion and crash text or the 
   victory text on success
   */
  void Crashed(boolean crashed) {
    //if crashed is true, it creates an explosion at the rocket and displays the failure text
    if (crashed) {
      int sz = 1;
      crashText();
      fill(255);
      textSize(20);
      text("Press R to restart", 169, 300);
      //used to check if r is pressed and calls the restart() method to restart the position of the rocket and goal
      if (keyPressed) {
        if (key == 'r') {
          restart();
        }
      }
      while (sz < 100) {
        sz+=1;
      }
      fill(255, 0, 0);
      noStroke();
      ellipse(x, y, sz, sz);
      thrust=0;
      yVel = 0;
      xVel=0;
      //When rocket lands succesfully, the victory text is displayed
    } else if (!crashed) {
      thrust = 0;
      yVel = 0;
      xVel=0;
      fill(255);
      textSize(20);
      text("Good Job! Press R to restart", 120, height/2);
      //If 'r' is pressed, restart() is called and the game can be played again
      if (keyPressed) {
        if (key == 'r') {
          restart();
        }
      }
    }
  }

  float x2;
  float x1 = random(0, 450);
  //This function creates a landing pad along the surface of the moon and checks whether a safe landing is made
  void goal() {
    //creates landing pad based of the first random value that is 50 pixels wide
    x2 = x1 + 50;
    fill(255, 0, 255);
    rect(x1, 470, 50, 50);
    //First if statement checks whether the lander is touching the ground,
    if (y>= 475) {
      //Then checks whether or not a safe landing is made
      if (yVel >.30 || tilt < 1.2 || tilt > 1.7 || crashed || abs(xVel) > 0.3) { 
        crashed = true;
        Crashed(crashed);
      } else { 
        // Then checks whether or not the landing is within the goal
        if (x >=x1 && x<= x2) {
          crashed = false;
          Crashed(crashed);
          //all other conditions result in a crash
        } else {
          crashed = true;
          Crashed(crashed);
        }
      }
    }
  }

  //Creates a flashing box of text to alert the player of a crash
  void crashText() {
    if (frameCount%60<30) {
      stroke(255, 0, 0);
      fill(255, 255, 0);
      rect(150, 215, 200, 50);
      fill(0);
      stroke(255, 0, 0);
      textSize(20);
      text("Crash Detected", 180, 250);
    }
  }
  //Draws a rocket of a sphere and triangle with the x and y coordinate given by the constructer
  void drawRocket(float x, float y) {
    pushMatrix();
    fill(255);
    translate(-x, -y);
    ellipse(x, y, 15, 15);
    triangle(x, y-30, x+10, y, x-10, y);
    popMatrix();
  }

  //creates a simple method to check if 's' has been pressed to start the program or not 
  void start() {
    if (keyPressed) {
      if (key == 's') {
        start = true;
      }
    }
    //if s has not been pressed, the rocket is stationary and flashing text prompts the player to press 's'
    if (!start) {
      pushMatrix();
      translate(x, y);
      stroke(255);
      fill(255);
      drawRocket(x, y);
      translate(-x, -y);
      popMatrix();
      if (frameCount%60<30) {
        textSize(25);
        text("Press S to start playing", 125, 200);
      }
    }
    //if 's' is pressed, all of the methods to draw and update the various parameters of the rocket are called
    if (start) {
      update();
      fuel();
      oxygen();
      speed();
      goal();
    }
  }
  /*sets the rocket back to original orientation and position, reseting the crashed boolean, fuel, oxygen, and 
   creates a new landing pad, different from the previous one*/
  void restart() {
    x= 250;
    y = 250;
    tilt = PI/2;
    crashed = false;
    O2 = 10;
    fuel = 70;
    x1 = random(0, 450);
  }
  //boolean used to remember whether or not the ship has crashed, initially false since there has been no crash
  boolean crashed = false;
  //Numbers for the fuel and oxygen which can be asjusted to make the game harder and easier
  private float O2 = 10;
  private float fuel = 70;
  private float x, y, xVel, yVel, thrust = GRAVITY, tilt = HALF_PI;
  // the values below were arrived at by trial and error
  // for something that had the responsiveness desired
  static final float GRAVITY = 0.003;
  static final float MAX_THRUST = 5*GRAVITY;
  static final float TILT_INC = 0.005;
  static final int FLAME_SCALE = 5000; // multiplier to determine how long the flame should be based on thrust
}