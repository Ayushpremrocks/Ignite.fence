#include <WiFi.h>
#include <HTTPClient.h>

// ---------------- WiFi Credentials ----------------
const char* ssid = "OPPO F23 5G 1cb5";
const char* password = "qrdy5383";

// ---------------- API Endpoint ----------------
const char* serverName = "https://ecomlancers.com/Sih_Api/capture_data";

// ---------------- Sensor Pins ----------------
const int voltagePin = 34;
const int currentPin = 35;
const int piezoPin   = 32;
const int buzzerPin  = 25; 

// ---------------- Piezo Threshold ----------------
// CHANGED: Threshold is now 3500
const int piezoThreshold = 3000;

// ---------------- Functions ----------------
void connectToWiFi() {
  Serial.print("Connecting to WiFi: ");
  Serial.println(ssid);
  WiFi.begin(ssid, password);
  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 30) {
    delay(500);
    Serial.print(".");
    attempts++;
  }
  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\n✅ WiFi Connected!");
    Serial.print("IP Address: ");
    Serial.println(WiFi.localIP());
  } else {
    Serial.println("\n❌ WiFi connection failed. Retrying in 5 seconds...");
    delay(5000);
    connectToWiFi(); // retry again
  }
}

void setup() {
  Serial.begin(9600);
  delay(1000);

  pinMode(buzzerPin, OUTPUT);
  digitalWrite(buzzerPin, LOW);

  // --- Buzzer Test ---
  // Beeps once on startup to confirm wiring is correct
  Serial.println("Testing Buzzer...");
  digitalWrite(buzzerPin, HIGH);
  delay(150);
  digitalWrite(buzzerPin, LOW);
  // --- End Test ---

  connectToWiFi();
}

void loop() {
  // If WiFi drops, reconnect
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("⚠ WiFi lost. Reconnecting...");
    connectToWiFi();
  }

  // ---------------- Read Sensors ----------------
  int voltageRaw = analogRead(voltagePin);
  int currentRaw = analogRead(currentPin);
  int piezoRaw   = analogRead(piezoPin);

  // Voltage calculation
  float voltage = (voltageRaw / 4095.0) * 3.3 * 11.0; // adjust divider ratio

  // Current calculation (ACS712 5A module, adjust for 20A/30A)
  float currentVoltage = (currentRaw / 4095.0) * 5.0; 
  float currentA = (currentVoltage - 2.5) / 0.185;    // Value is now in Amperes
  int is_alert=0;
  if (currentA < 0) currentA = 0; // avoid negative noise

  // ---------------- Serial Output ----------------
  Serial.println("------ Sensor Readings ------");

  Serial.print("Voltage: ");
  Serial.print(voltage, 2);
  Serial.println(" V");

  Serial.print("Current: ");
  Serial.print(currentA, 3);
  Serial.println(" A");

  Serial.print("Piezo(raw): ");
  Serial.println(piezoRaw);

  // ---------------- Buzzer Alert ----------------
  if (piezoRaw > piezoThreshold) {
    Serial.println("⚠ Tamper detected! Activating buzzer...");
    digitalWrite(buzzerPin, HIGH);
    delay(1000);
    digitalWrite(buzzerPin, LOW);
    is_alert=1;
  } else {
    digitalWrite(buzzerPin, LOW);
  }

  // ---------------- Send to API ----------------
  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;
    http.begin(serverName);
    http.addHeader("Content-Type", "application/x-www-form-urlencoded");

    // REMOVED: Timestamp is no longer sent
    String payload = "device_id=1";
    payload += "&voltage=" + String(voltage, 2);
    payload += "&current=" + String(currentA, 3);
    payload += "&piezo=" + String(piezoRaw);
    payload += "&is_alert=" + String(is_alert);

    Serial.print("Sending Data: ");
    Serial.println(payload);

    int httpResponseCode = http.POST(payload);

    if (httpResponseCode > 0) {
      String response = http.getString();
      Serial.print("✅ HTTP Response code: ");
      Serial.println(httpResponseCode);
      Serial.print("Response: ");
      Serial.println(response);
    } else {
      Serial.print("❌ Error code: ");
      Serial.println(httpResponseCode);
    }
    http.end();
  } else {
    Serial.println("❌ WiFi disconnected. Skipping API request.");
  }

  delay(2000); 
}