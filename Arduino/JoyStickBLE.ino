#include <SPI.h>
#include <stdlib.h>
#include "Adafruit_BLE_UART.h"

#define ADAFRUITBLE_REQ 10
#define ADAFRUITBLE_RDY 2
#define ADAFRUITBLE_RST 9

const int SW_pin = 0; // digital pin connected to switch output

// player 1
const int X_pin = 0; // analog pin connected to X output
const int Y_pin = 1; // analog pin connected to Y output

// player 2
const int X2_pin = 2;
const int Y2_pin = 3;

Adafruit_BLE_UART BTLEserial = Adafruit_BLE_UART(ADAFRUITBLE_REQ, ADAFRUITBLE_RDY, ADAFRUITBLE_RST);


void setup() {
  Serial.begin(9600);
  pinMode(SW_pin, INPUT);
  digitalWrite(SW_pin, HIGH);
  BTLEserial.setDeviceName("BLE_temp");
  BTLEserial.begin();
}

aci_evt_opcode_t laststatus = ACI_EVT_DISCONNECTED;

void loop() {
  BTLEserial.pollACI();

  aci_evt_opcode_t status = BTLEserial.getState();
  if (status != laststatus) {
    laststatus = status;
  }

  if (status == ACI_EVT_CONNECTED) {
  
    int x = analogRead(X_pin);
    int y = analogRead(Y_pin);
    int s = digitalRead(SW_pin);

    int x2 = analogRead(X2_pin);
    int y2 = analogRead(Y2_pin);

    // array that data be sent out in
    char p1Char[20] = {0};
    char p2Char[20] = {0};
    char switchArray[20] = {0};

    int countP1 = 2;
    int countP2 = 2;

    // id, # xDigits, x1 .. xDigits, # ydigits, y1 .. yDigits
    p1Char[0] = '1';
    p1Char[1] = '0' + calcLength(x);
    countP1 += calcLength(x);
    popArray(p1Char, countP1, 1,  x);
    p1Char[countP1] = '0' + calcLength(y);
    countP1++;
    countP1 += calcLength(y);
    popArray(p1Char, countP1, countP1-calcLength(y)-1,  y);

    BTLEserial.write(p1Char,20);

    // id, # xDigits, x1 .. xDigits, # ydigits, y1 .. yDigits
    p2Char[0] = '2';
    p2Char[1] = '0' + calcLength(x2);
    countP2 += calcLength(x2);
    popArray(p2Char, countP2, 1,  x2);
    p2Char[countP2] = '0' + calcLength(y2);
    countP2++;
    countP2 += calcLength(y2);
    popArray(p2Char, countP2, countP2-calcLength(y2)-1,  y2);
    BTLEserial.write(p2Char,20);

    // id, pressed value --> 1 is unpressed, 0 is pressed
    switchArray[0] = 's';
    switchArray[1] = '0'+ s;
    BTLEserial.write(switchArray,20);
    
  }
  delay(50);
}


int calcLength(int n){
  int count = 0;
  if(n ==0){
    count = 1;
  }
  while(n > 0){
    n /= 10;
    count++;
  }
  return count;
}

void popArray(char arr[], int start, int finish, int num){
  for(int i = start - 1; i >finish; i--){
    arr[i] = '0' + (num % 10);
    num/=10;
  } 
}
