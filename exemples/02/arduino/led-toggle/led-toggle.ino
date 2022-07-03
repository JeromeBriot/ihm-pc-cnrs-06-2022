void setup() {

  Serial.begin(9600);

  pinMode(LED_BUILTIN, OUTPUT);

}

void loop() {

  int serialReceivedValue;

  if (Serial.available() > 0) {

    serialReceivedValue = Serial.read();

    if ('1' == serialReceivedValue) {
      digitalWrite(LED_BUILTIN, HIGH);
    }
    else if ('0' == serialReceivedValue) {
      digitalWrite(LED_BUILTIN, LOW);
    }

  }

}
