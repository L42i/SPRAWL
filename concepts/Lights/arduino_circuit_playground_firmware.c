#include <Adafruit_CircuitPlayground.h>

void setup() {
  Serial.begin(115200);
  CircuitPlayground.begin(); // Initialize Circuit Playground
}

void loop() {
  if (Serial.available() > 0) {
    int brightness = Serial.read(); // Read brightness value from SuperCollider
    brightness = constrain(brightness, 0, 255); // Ensure brightness is within range

    // Set brightness for all 10 LEDs on Circuit Playground
    for (int i = 0; i < 10; i++) {
      CircuitPlayground.setPixelColor(i, brightness, brightness, brightness); // White light
    }
  }
}
