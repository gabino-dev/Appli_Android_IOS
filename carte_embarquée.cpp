#include "SevSeg.h"

SevSeg sevseg;

void setup() {
  byte numDigits = 4;

  // Digits reliés aux pins 2, 3, 4, 5
  byte digitPins[] = {2, 3, 4, 5}; 
  
  // Segments reliés aux pins 6, 7, 8, 9, 10, 11, 12, 13
  // Ordre standard : A, B, C, D, E, F, G, DP
  byte segmentPins[] = {6, 7, 8, 9, 10, 11, 12, 13}; 

  bool resistorsOnSegments = true;
  
  byte hardwareConfig = COMMON_CATHODE; 
  
  bool updateWithDelays = false; 
  bool leadingZeros = false;
  bool disableDecPoint = false;

  sevseg.begin(hardwareConfig, numDigits, digitPins, segmentPins, resistorsOnSegments,
  updateWithDelays, leadingZeros, disableDecPoint);
  
  sevseg.setBrightness(90);
  Serial.begin(9600);
}

// Variable pour stocker le solde
long solde = 0; 

void loop() {
  // 1. Lecture du port série 
  if (Serial.available() > 0) {
    long recu = Serial.parseInt();
    // On met à jour seulement si on reçoit un vrai chiffre
    if (recu != 0 || Serial.peek() == '\n') {
       solde = recu;
       sevseg.setNumber(solde);
    }
    // Nettoyage du port série pour éviter les bouchons
    while (Serial.available() > 0) { Serial.read(); }
  }

  // 2. Rafraîchissement de l'écran 
  sevseg.refreshDisplay(); 
}
