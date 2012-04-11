
// **********************************
// Lockout Version 1.0
// **********************************
// For use with the Lockout Shield from "Blinky Boards", a division of "Blinky Partners, LLC".
// Current versions and documentation at http://www.blinkyboards.com/downloads/lockout/.
// This is a pre-release version. Any claims about documentation are pure LIES!!!
// **********************************



// **********************************
// Copyright Information - Free as in "Freedom"
// **********************************
// Copyright 2010 Blinky Partners, LLC. All rights reserved.
/*
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
// **********************************



// **********************************
// Adding Functionality
// **********************************
// This program is fully functional, with lots of options (see "User Editable Parameters" below).
// You can create additional functionality!
// All Arduino pins not used by the Lockout Shield are brought out on the "Sound and More" header.
// They are digital I/O pins 0, 1, 7, 8, 11, & 12.
// 0 and 1 are used by the Arduino serial communication UART, and the USB port (on Arduinos with USB).
// You can use these pins to generate a sound effect indicating a winner.
// Please see the sound effects sections under "User Editable Parameters".
// You can use these pins to tie two shields together, making an eight player system.
// Please see the cascade section of "User Editable Parameters".
// Additional info about sound effects and cascading can be found in the documentation.
// The location of online documentation is given at the top of this file.
// Any remaining pins on the "Sound and More" header can be used as you please.
// Digital I/O pin 13 is used to drive a "heartbeat" LED, but if you need to use the pin
// to do something else, simply set the heartbeatFlag to false in the "User Editable Parameters" below.
// **********************************



// **********************************
// Libraries
// **********************************
// Some of the alternatives supported by this program require
// additional code libraries to be installed. For more info please see the documentation.
// The location of online documentation is given at the top of this file.
#include <NewSoftSerial.h>
#include <EEPROM.h>
// **********************************



// **********************************
// User Editable Parameters.
// **********************************
// These are all things that you can change to alter the behavior of the system.
// To change a flag, type "true" or "false" (lower case, with no quotes) between "=" and ";".
// To change a time, type in a new value (with no leading zeros) between "=" and ";".
// All times are in milliseconds. 1 millisecond is 1/1000 of a second, so...
// 10 milliseconds = 1/100 of a second,
// 100 milliseconds = 1/10 of a second,
// 1000 milliseconds = 1 second,
// 10000 milliseconds = 10 seconds, and so on.
// **********************************
// Cascade
// **********************************
// Two lockout shields can be connected together to make an eight player system.
// We call this "cascading".
// Hook up instructions for cascading can be found in the documentation.
// The location of online documentation is given at the top of this file.
// If you are cascading two shields, set the following flag to true.
boolean cascadeFlag = true;
// When cascading, one shield must be defined as the master. It will be players 1 through 4.
// The other shield, the slave, will be players five through eight.
// For the master, set this flag to true. For the slave, set it false.
const boolean masterFlag = true;
// The two shields will use a serial link on two I/O pins to communicate with each other.
// The Arduino pins brought out to the "Sound & More" header are 0, 1, 7, 8, 11, and 12.
// Pins 0 and 1 are already used by the main Arduino serial communication UART,
// connected to  the USB port (on Arduinos with USB).
// Don't use pins 0 and 1 unless you really know what you're doing.
// Choose two available pins and assign them below.
// Be sure they don't conflict with the sound effects pin assignments, further down in this section.
const byte cascadeRxPin = 11;
const byte cascadeTxPin = 12;
const int cascadeBaudRate = 9600;
// Don't change this
NewSoftSerial cascadeLink(cascadeRxPin, cascadeTxPin);
// When cascading, most of the following parameters must be set alike on both shields.
// The exceptions are the sound effect settings. You'll probably only use one of the two
// interconnected shields to generate sound effects for an eight player system,
// but there's nothing stopping you from using both... we've done it!
// **********************************
// Ties
// **********************************
// Set this flag to true to allow the indication of a tie (however unlikely).
// If set to false, in the unlikely case of a tie a single winner will be chosen at random
// from among the tied players.
boolean allowTiesFlag = false;
// **********************************
// Startup State
// **********************************
// Set this flag to true and the system will be enabled at startup.
// Set false and the system will be disabled at startup until enabled by a manual reset.
boolean startupEnableFlag = true;
// **********************************
// Automatic Reset
// **********************************
// Set to true and the system will clear and enable itself, ready to play again
// after being locked out for a fixed period of time.
// Set false and the system will stay locked out until manually reset.
boolean autoResetFlag = true;
unsigned long autoResetMillis = 3000; // how long before it resets, in milliseconds
// **********************************
// Auto Disable
// **********************************
// Set to true and a locked out state will clear (indicator will turn off) after a fixed time
// but the system will not reset, rather it will enter the disabled mode until manually reset.
// Note: if both auto reset and auto disable are set to true
// the one with the shortest "millis" overrides the other (with a slight prejudice towards auto reset).
boolean autoDisableFlag = false;
unsigned long autoDisableMillis = 3000; // how long before it disables, in milliseconds
// **********************************
// Manual Disable
// **********************************
// Set to true and the disabled state can be set manually via the control button
// by holding it down for a fixed period of time.
// Pressing the button again will reset (enable) the system.
boolean manualDisableFlag = true;
unsigned long manualDisableMillis = 1000; // how long the button must be down to disable
// **********************************
// Enabled Mode Indication
// **********************************
// Set to true and the control button light will flash when the system is enabled.
// Set false and the light will stay on when the system is enabled.
// Please see the note under "Disabled Mode Indication" below.
boolean enabledFlashFlag = false;
unsigned long enabledFlashOnMillis = 250; // how long the indicator stays on while flashing
unsigned long enabledFlashOffMillis = 250; // how long the indicator stays off while flashing
// **********************************
// Disabled Mode Indication
// **********************************
// Set to true and the control button light will flash when the system is disabled.
// Set false and the light will stay off when the system is disabled.
boolean disabledFlashFlag = true;
unsigned long disabledFlashOnMillis = 250; // how long the indicator stays on while flashing
unsigned long disabledFlashOffMillis = 1000; // how long the indicator stays off while flashing
// Note: If both enabledFlashFlag and disabledFlashFlag are set to true, and their respective
// "millis" are similar, then there will be no practical way to tell the difference between
// the enabled and disabled states.
// Here's what we suggest:
// If power consumption is not an issue (for instance, if the system is powered by a
// transformer plugged into the wall), then set enabledFlashFlag to false, and set
// disabledFlashFlag to true. The light will stay on when the system is enabled,
// flash when the system is disabled, and be off when the system is off.
// If, on the other hand, power consumption is an issue (for instance, if the system runs
// on batteries) then set enabledFlashFlag to true, and set disabledFlashFlag to false.
// The light will flash when the system is enabled, and be off when the system is disabled,
// giving the smallest power consumption. The down side to this is that there is no
// indication that the system is powered up (if the heartbeat LED is not visible) when it
// is disabled, increasing the chance that the system will inadvertantly be left on at
// the completion of play, draining the batteries. An alternative is to set both flags
// to true, but set their corresponding "millis" such that the flash rate is obviously
// different for the two states.
// **********************************
// Flash Win Indicator
// **********************************
// Set to true and the winning player's indicator will flash.
// Set false and the indicator will stay on solid.
boolean flashWinningFlag = true;
unsigned long winFlashOnMillis = 250; // how long the winning indicator stays on while flashing
unsigned long winFlashOffMillis = 250; // how long the winning indicator stays off while flashing
// **********************************
// Indicator Brightness
// **********************************
// Brightness of the indicator lights... set from 0 (off) to 255 (full on).
byte playerLightBrightness = 255; // the player's light (indicating the winner)
byte controlLightBrightness = 255; // the control button light (indicating the system state)
// **********************************
// Heartbeat
// **********************************
// Set true to flash a "heartbeat" led.
// This is a handy indication that the board is powered up and the program is running.
// This blinks both the pin 13 led on the Arduino, and an led on the lockout board.
// Setting this to false would allow you to use pin 13 for other things.
boolean heartbeatFlag = true;
unsigned long heartbeatOnMillis = 75;  // how long the heartbeat led stays on
unsigned long heartbeatOffMillis = 1500;  // how long the heartbeat led stays off
// **********************************
// Sound Effects
// **********************************
// A sound effect can be used to indicate a locked out state (a winner!).
// There are several options built in to this software.
// You can choose one or more below!
// **********************************
// Beeper Sound Effect
// **********************************
// The default method for generating a sound effect is by attaching a beeper to an I/O pin,
// and toggling that pin on and off several times to create a series of beeps.
// Hook up instructions for a beeper can be found in the documentation.
// The location of online documentation is given at the top of this file.
// Set this flag to true to sound a beeper.
boolean beeperFlag = true;
// The Arduino pins brought out to the "Sound & More" header are 0, 1, 7, 8, 11, and 12.
// Pins 0 and 1 are already used by the main Arduino serial communication UART,
// connected to  the USB port (on Arduinos with USB).
// Don't use pins 0 and 1 unless you really know what you're doing.
// Choose an available pin number and enter it below.
// If you are cascading two shields, make sure that what you do here doesn't conflict
// with the cascade pin assignments at the top of this section.
const byte beeperPin = 7; // 7, 8, 11, or 12
byte numberOfBeeps = 5; // how many times it beeps
unsigned long beeperOnMillis = 100; // how long each beep lasts
unsigned long beeperOffMillis = 100; // the length of silence between beeps
// **********************************
// Sound Effect Closure
// **********************************
// It is common to generate a sound effect by supplying
// a brief pulse on an I/O pin to trigger an external device.
// Usually the I/O pin would drive a relay, providing a "contact closure"...
// hence us refering to this as a "closure".
// Hook up instructions for a relay can be found in the documentation.
// The location of online documentation is given at the top of this file.
// Set this flag to true to generate a closure.
boolean closureFlag = true;
// The Arduino pins brought out to the "Sound & More" header are 0, 1, 7, 8, 11, and 12.
// Pins 0 and 1 are already used by the main Arduino serial communication UART,
// connected to  the USB port (on Arduinos with USB).
// Don't use pins 0 and 1 unless you really know what you're doing.
// Choose an available pin number and enter it below.
// If you are cascading two shields, make sure that what you do here doesn't conflict
// with the cascade pin assignments at the top of this section.
const byte closurePin = 8; // 7, 8, 11, or 12
const byte closureAtRestState = LOW;  // set "HIGH" or "LOW" for the closure pin's normal state
unsigned long closureMillis = 500; // how long the pin is toggled, in milliseconds
// **********************************
// 4D Systems SOMO - 14D Sound Effect
// **********************************
// You can add a 4D Systems SOMO - 14D sound board, available from Sparkfun Electronics:
// http://www.sparkfun.com/commerce/product_info.php?products_id=9534
// Hook up instructions for the SOMO board can be found in the documentation.
// The location of online documentation is given at the top of this file.
// Set this flag true to make use of the SOMO board
const byte somoFlag = false;
// The shield will use a serial link on two I/O pins to communicate with this board.
// The Arduino pins brought out to the "Sound & More" header are 0, 1, 7, 8, 11, and 12.
// Pins 0 and 1 are already used by the main Arduino serial communication UART,
// connected to  the USB port (on Arduinos with USB).
// Don't use pins 0 and 1 unless you really know what you're doing.
// Choose two available pins and assign them below.
// If you are cascading two shields, make sure that what you do here doesn't conflict
// with the cascade pin assignments at the top of this section.
const byte somoClockPin = 7;
const byte somoDataPin = 8;
// **********************************
// Debug Messages
// **********************************
// Set this to true and the program will send debug messages out the serial/USB port.
// This allows you to monitor program flow and see what's going on.
boolean usbDebugFlag = true;
// Set the baud rate for the Serial connection.
const unsigned int usbBaudRate = 9600;
// **********************************



// **********************************
// Advanced Editable Parameters
// **********************************
// change these only if you're having related problems
// how long the clear line is held high to clear the lockout
const byte clearMillis = 5; // in milliseconds
// how long after a button press to allow for contact bounce
const unsigned long debounceMillis = 15; // in milliseconds



// **********************************
// Other Flags, Variables and Constants - don't change these
// **********************************
// Input Stuff
// **********************************
// These assign the inputs to specific Arduino pins.
const byte player1 = 14; // the individual player buttons
const byte player2 = 15;
const byte player3 = 16;
const byte player4 = 17;
// Let's put the above in an array so we can access them in a loop.
// Arrays are zero indexed, but for the sake of readability we'll index from 1.
// So we'll declare an extra element (at position zero) and ignore it.
const byte player[] = {
  0, player1, player2, player3, player4};
const byte cascade = 18;  // pin goes low to indicate a lockout state
const byte controlButton = 19; // for local control of the system
// **********************************
// Output Stuff
// **********************************
// These assign the outputs to specific Arduino pins
// Lights 1-4 are mapped to PWM pins so they can be dimmed
const byte light1 = 3; // these indicate which player(s) hit the button first
const byte light2 = 5;
const byte light3 = 6;
const byte light4 = 9;
// Let's put the above in an array so we can access them in a loop.
// Arrays are zero indexed, but for the sake of readability we'll index from 1.
// So we'll declare an extra element (at position zero) and ignore it.
const byte light[] = {
  0, light1, light2, light3, light4};
const byte controlButtonLight = 10; // the light in the control button, also pwm
const byte enableLine = 4; // set this line high to enable lockout
const byte clearLine = 2;  // pulse this line high to clear the lockout
const byte heartbeatPin = 13; // the heartbeat LED
// **********************************
// Operational Mode
// **********************************
// This is used to control program flow
const byte disabled = 0;
const byte enabled = 1;
const byte lockedOut = 2;
byte opMode = disabled;
// **********************************
// Winners
// **********************************
// Arrays are zero indexed, but for the sake of readability we'll index from 1.
// So we'll declare an extra element and ignore it.
// We'll make the the arrays for nine elements (eight + 1 ignored) so we can use them
// when there are two shields cascaded to make an eight player system.
boolean playerWinFlag[9]; // flags for each player, indicating winner(s)
byte winners[9]; // list of winners
byte numberOfWinners; // shows length of list above
byte winner; // the one and only winner!
// **********************************
// Sound
// **********************************
boolean closureActiveFlag = false; // if the closure is closed
unsigned long closureStartMillis; // used by the closure routine
boolean beeperActiveFlag = false; // if the beeping is in progress
byte beeperState = LOW; // current state of the beeper pin
byte beeperCount; // current number of beeps
unsigned long beeperStartMillis; // used by the beep routine
unsigned long beeperInterval;
// **********************************
// Timing
// **********************************
unsigned long flashStartMillis; // shared by winner, enable, and/or disabled flashing
unsigned long flashInterval; // ditto
byte flashState; // ditto
unsigned long lockedOutStartMillis; // used by auto reset and/or auto disable
// **********************************
// Heartbeat
// **********************************
unsigned long heartbeatStartMillis = 0;
unsigned long heartbeatInterval = 0;
byte heartbeatState = LOW;
// **********************************
// Control button
// **********************************
unsigned long buttonChangeStartMillis;
boolean buttonDownFlag = false;
// **********************************



// **********************************
// The Functions
// **********************************


// This runs once at startup.
void setup() {
  // initialize the serial port
  if (usbDebugFlag) {
    Serial.begin(usbBaudRate);
    Serial.println("starting setup function");
  }
  // set pin modes
  // the digital io pins default to input, but let's set 'em anyway
  pinMode(player1, INPUT);
  pinMode(player2, INPUT);
  pinMode(player3, INPUT);
  pinMode(player4, INPUT);
  pinMode(cascade, INPUT);
  pinMode(controlButton, INPUT);
  pinMode(light1, OUTPUT);
  pinMode(light2, OUTPUT);
  pinMode(light3, OUTPUT);
  pinMode(light4, OUTPUT);
  pinMode(controlButtonLight, OUTPUT);
  pinMode(enableLine, OUTPUT);
  pinMode(clearLine, OUTPUT);
  if (heartbeatFlag) pinMode(heartbeatPin, OUTPUT);
  // initialize cascading
  if (cascadeFlag) cascadeLink.begin(9600);
  // initialize the closure pin
  if (closureFlag) {
    pinMode(closurePin, OUTPUT);
    digitalWrite(closurePin, closureAtRestState);
  }
  // initialize the beeper pin
  if (beeperFlag) pinMode(beeperPin, OUTPUT);
  // enable internal pullup resistors
  digitalWrite(controlButton, HIGH);
  // initialize SOMO
  // 
  // initialize lockout
  disableLockout();
  clearLockout();
  if (startupEnableFlag) enableLockout();
  if (usbDebugFlag) Serial.println("setup function complete");
}


// The main program loop.
// This executes continiously, controlling the program flow.
void loop() {
  switch (opMode) { // branches depending on the current mode
  case disabled:
    doDisabled();
    break;
  case enabled:
    doEnabled();
    break;
  case lockedOut:
    doLockedOut();
    break;
  }
  if (heartbeatFlag) doHeartbeat(); // blink the heartbeat LED
  if (closureFlag && closureActiveFlag) checkClosure();
  if (beeperFlag && beeperActiveFlag) checkBeeper();
}


// this executes every time through the loop when the mode == disabled
void doDisabled() {
  if (disabledFlashFlag) flashControlButtonLight(); // blink the control button light
  // deal with a manual enable request
  // the button must open after being held down to disable
  if (digitalRead(controlButton) == LOW){ // if the control button has been pressed
    // if it was previously up AND enough time has passed to allow for contact bounce
    if (!buttonDownFlag && ((millis() - buttonChangeStartMillis) > debounceMillis)) {
      // then set some variables
      buttonChangeStartMillis = millis();
      buttonDownFlag = true;
      // and enable the lockout
      if (usbDebugFlag) Serial.println("manually enabling lockout");
      enableLockout();
    }
  }
  else { // the button is up
    // if it was previously down AND enough time has passed to allow for contact bounce
    if (buttonDownFlag && ((millis() - buttonChangeStartMillis) > debounceMillis)) {
      // then set some variables
      buttonChangeStartMillis = millis();
      buttonDownFlag = false;
    }
  }
}


// this executes every time through the loop when the mode == enabled
void doEnabled() {
  if (enabledFlashFlag) flashControlButtonLight(); // blink the control button light
  // deal with a lockout state
  if(digitalRead(cascade) == LOW){ // a player button has been pressed... we have a lockout!
    lockoutLockout();
  }
  // deal with a manual disable request
  if (manualDisableFlag) { // if manual disable is allowed
    if(digitalRead(controlButton) == LOW){ // if the control button has been pressed
      if (buttonDownFlag) { // if it was already pressed
        // if it has been pressed long enough, then disable the lockout
        if ((millis() - buttonChangeStartMillis) > manualDisableMillis) {
          if (usbDebugFlag) Serial.println("manually disabling lockout");
          disableLockout();
        }
      }
      else { // if it wasn't already pressed, then set some variables
        buttonChangeStartMillis = millis();
        buttonDownFlag = true;
      }
    }
    else { // if  the button is up
      // if it was previously down AND enough time has passed to allow for contact bounce
      if (buttonDownFlag && ((millis() - buttonChangeStartMillis) > debounceMillis)) {
        // then set some variables
        buttonChangeStartMillis = millis();
        buttonDownFlag = false;
      }
    }
  }
}


// this executes every time through the loop when the mode == lockedOut
void doLockedOut() {
  if (flashWinningFlag) flashWinnerIndicators(); // flash the winning indicator(s)
  // deal with a manual reset request
  if(digitalRead(controlButton) == LOW){ // control button has been pressed
    buttonChangeStartMillis = millis();
    buttonDownFlag = true;
    if (usbDebugFlag) Serial.println("manually reseting lockout");
    disableLockout();
    clearLockout();
    enableLockout();
    // we don't need to do the rest of this function, so...
    return; // bail out
  }
  // deal with an auto reset
  if (autoResetFlag) {
    if ((millis() - lockedOutStartMillis) > autoResetMillis) {
      if (usbDebugFlag) Serial.println("auto reseting lockout");
      disableLockout();
      clearLockout();
      enableLockout();
      // we don't need to do the rest of this function, so...
      return; // bail out
    }
  }
  // deal with an auto disable
  if (autoDisableFlag) {
    if ((millis() - lockedOutStartMillis) > autoDisableMillis) {
      if (usbDebugFlag) Serial.println("auto disabling lockout");
      disableLockout();
      clearLockout();
    }
  }
}


void disableLockout(){
  digitalWrite(enableLine, LOW);
  digitalWrite(controlButtonLight, LOW);
  opMode = disabled;
  flashStartMillis = millis(); // set up for flashing the control button light
  flashInterval = disabledFlashOffMillis; // ditto
  flashState = LOW; // ditto
  if (usbDebugFlag) Serial.println("lockout disabled");
}

void enableLockout(){
  digitalWrite(enableLine, HIGH);
  analogWrite(controlButtonLight, controlLightBrightness);
  opMode = enabled;
  flashStartMillis = millis(); // set up for flashing the control button light
  flashInterval = enabledFlashOnMillis; // ditto
  flashState = HIGH; // ditto
  if (usbDebugFlag) Serial.println("lockout enabled");
}


void lockoutLockout() {
  if (usbDebugFlag) Serial.println("locked out! determining winner(s)");
  numberOfWinners = 0; // init number of winners to 0
  winner = 0; // init winner variable to 0 (no winner)
  for (byte i = 1; i <= 4; i ++) { // loop 4 times
    playerWinFlag[i] = (digitalRead(player[i]) == HIGH); // read the inputs, set flags in flag array
    if (usbDebugFlag) {
      Serial.print("player # ");
      Serial.print(i, DEC);
    }
    if (playerWinFlag[i]) { // if i is a winner...
      numberOfWinners ++; // increment the number of winners
      winners[numberOfWinners] = i; // write winner in winner array
      winner = i; // set single winner, it'll change later if there are more than one
      if (usbDebugFlag) Serial.println(" wins!");
    }
    else {
      if (usbDebugFlag) Serial.println(" does not win");
    }
  }
  // let's deal with ties
  if (numberOfWinners > 1) { // if there are multiple winners... a tie!
    if (allowTiesFlag) { // if we allow ties
      if (usbDebugFlag) printTheWinners();
    }
    else { // if we don't allow ties
      eliminateTie(); // pick one
      if (usbDebugFlag) printTheWinner();
    }
  }
  else { // there's only one winner, not a tie
    if (usbDebugFlag) printTheWinner();
  }
  // if there are two shields tied together to make an eight player system
  if (cascadeFlag) doCascade();
  turnOnWinnerIndicators();
  digitalWrite(controlButtonLight, LOW); // turn off the control button light
  if (closureFlag) startClosure();
  if (beeperFlag) startBeeper();
  opMode = lockedOut;
  lockedOutStartMillis = millis();  // set up for auto disable and/or reset
  flashStartMillis = millis(); // set up for flashing the win indicator
  flashInterval = winFlashOnMillis; // ditto
  flashState = HIGH; // ditto
}


void clearLockout(){ // clears the gates on the board
  turnOffWinnerIndicators();
  if (beeperFlag && beeperActiveFlag) stopBeeper();
  digitalWrite(clearLine, HIGH);
  delay(clearMillis);
  digitalWrite(clearLine, LOW);
  if (usbDebugFlag) Serial.println("lockout cleared");
}


void eliminateTie() {
  if (usbDebugFlag) Serial.println("eliminating tie");
  randomSeed(millis()); // init random function
  winner = winners[(random(1, (numberOfWinners + 1)))]; // pick one winner at random from the tied players
  // set all variables to reflect one winner
  numberOfWinners = 1;
  for (byte i = 1; i <= 4; i ++) {
    playerWinFlag[i] = false; // set all elements of array to false
  }
  playerWinFlag[winner] = true; // set just one winner element of array to true
}


void doCascade() {
      if (usbDebugFlag) Serial.println("Two units are cascaded.");
    if (masterFlag) { // this shield is the master (players 1 - 4)
      if (usbDebugFlag) Serial.println("This is the master unit.");
      if (allowTiesFlag) {

      }
      else {

      }
    }
    else { // this shield is the slave (players 5 - 8)
      if (usbDebugFlag) Serial.print("This is the slave unit sending: ");
      if (allowTiesFlag) { // if we allow ties
        for (byte i = 1; i <= 4; i ++) { // loop 4 times
          if (playerWinFlag[i]) { // if player i is a winner
            cascadeLink.print("t"); // send a "t" for true
            if (usbDebugFlag) Serial.print("t");
          }
          else { // if not a winner
            cascadeLink.print("f"); // send an "f" for false
            if (usbDebugFlag) Serial.print("f");
          }
        }
        cascadeLink.println("");
        if (usbDebugFlag) Serial.println("");
      }
      else { // we don't allow ties
        cascadeLink.println(winner);
        if (usbDebugFlag) Serial.println(winner, DEC);
      }
    }
}


void printTheWinner() {
  Serial.print("The winner is: ");
  Serial.println(winner, DEC);
}


void printTheWinners() {
  Serial.print("It's a tie! The winners are:");
  for (byte i = 1; i <= numberOfWinners; i ++) {
    Serial.print(" ");
    Serial.print(winners[i], DEC);
  }
  Serial.println("");
}


void flashControlButtonLight() {
  if ((millis() - flashStartMillis) > flashInterval) {
    switch (flashState) {
    case LOW:
      analogWrite(controlButtonLight, controlLightBrightness);
      switch (opMode) {
      case enabled:
        flashInterval = enabledFlashOnMillis;
        break;
      case disabled:
        flashInterval = disabledFlashOnMillis;
        break;
      default:
        // do nothing
        break;
      }
      break;
    case HIGH:
      digitalWrite(controlButtonLight, LOW);
      switch (opMode) {
      case enabled:
        flashInterval = enabledFlashOffMillis;
        break;
      case disabled:
        flashInterval = disabledFlashOffMillis;
        break;
      default:
        // do nothing
        break;
      }
      break;
    default:
      // do nothing
      break;
    }
    flashState = !flashState;
    flashStartMillis = millis();
  }
}


void flashWinnerIndicators() {
  if ((millis() - flashStartMillis) > flashInterval) {
    if(flashState == LOW) {
      turnOnWinnerIndicators();
      flashInterval = winFlashOnMillis;
    }
    else {
      turnOffWinnerIndicators();
      flashInterval = winFlashOffMillis;
    }
    flashState = !flashState;
    flashStartMillis = millis();
  }
}


void turnOnWinnerIndicators() {
  for (byte i = 1; i <= 4; i ++) {
    if (playerWinFlag[i]) analogWrite(light[i], playerLightBrightness);
  }
}


void turnOffWinnerIndicators() {
  for (byte i = 1; i <= 4; i ++) {
    digitalWrite(light[i], LOW);
  }
}


void doHeartbeat() {
  if ((millis() - heartbeatStartMillis) > heartbeatInterval) {
    if(heartbeatState == LOW) {
      heartbeatState = HIGH;
      heartbeatInterval = heartbeatOnMillis;
    }
    else {
      heartbeatState = LOW;
      heartbeatInterval = heartbeatOffMillis;
    }
    digitalWrite(heartbeatPin, heartbeatState);
    heartbeatStartMillis = millis();
  }
}


void startClosure() {
  if (usbDebugFlag) Serial.println("starting closure");
  digitalWrite(closurePin, !closureAtRestState);
  closureStartMillis = millis();
  closureActiveFlag = true;
}


void checkClosure() {
  if ((millis() - closureStartMillis) > closureMillis) {
    if (usbDebugFlag) Serial.println("ending closure");
    digitalWrite(closurePin, closureAtRestState);
    closureActiveFlag = false;
  }
}


void startBeeper() {
  if (usbDebugFlag) Serial.println("starting beeper");
  beeperActiveFlag = true;
  beeperCount = 0;
  beeperState = HIGH;
  beeperInterval = beeperOnMillis;
  digitalWrite(beeperPin, HIGH);
  beeperStartMillis = millis();
}


void checkBeeper() {
  if ((millis() - beeperStartMillis) > beeperInterval) {
    if(beeperState == LOW) {
      beeperState = HIGH;
      beeperInterval = beeperOnMillis;
    }
    else {
      beeperState = LOW;
      beeperInterval = beeperOffMillis;
      beeperCount += 1;
      if (beeperCount >= numberOfBeeps) {
        stopBeeper();
        return;
      }
    }
    digitalWrite(beeperPin, beeperState);
    beeperStartMillis = millis();
  }
}


void stopBeeper() {
  if (usbDebugFlag) Serial.println("ending beeper");
  digitalWrite(beeperPin, LOW);
  beeperActiveFlag = false;
}
