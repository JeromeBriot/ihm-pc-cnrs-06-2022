#define BUILTIN_LED 13

typedef enum {
  DELAY_10_MS  =  10,
  DELAY_20_MS  =  20,
  DELAY_50_MS  =  50,
  DELAY_100_MS = 100
} DELAY_t;

int8_t sinusTable[100] = {   0,    8,   16,   24,   32,   39,   47,   54,   61,   68,
                            75,   81,   87,   93,   98,  103,  107,  111,  115,  118,
                           121,  123,  125,  126,  127,  127,  127,  126,  125,  123,
                           121,  118,  115,  111,  107,  103,   98,   93,   87,   81,
                            75,   68,   61,   54,   47,   39,   32,   24,   16,    8,
                             0,   -8,  -16,  -24,  -32,  -39,  -47,  -54,  -61,  -68,
                           -75,  -81,  -87,  -93,  -98, -103, -107, -111, -115, -118,
                          -121, -123, -125, -126, -127, -127, -127, -126, -125, -123,
                          -121, -118, -115, -111, -107, -103,  -98,  -93,  -87,  -81,
                           -75,  -68,  -61,  -54,  -47,  -39,  -32,  -24,  -16,   -8};
                           
void setup() {

  Serial.begin(9600);
  pinMode(BUILTIN_LED, OUTPUT);

}

void loop() {

  static int ledState = LOW;
  int serialReceivedValue;
  static uint32_t startMillis = 0;
  static uint8_t idx = 0;
  static DELAY_t sinusDelayMs = DELAY_100_MS;

  if ((millis() - startMillis) > sinusDelayMs)
  {

    startMillis = millis();

    Serial.println(sinusTable[idx]);

    if (100 == ++idx)
    {
      idx = 0;
      ledState = !ledState;
      digitalWrite(BUILTIN_LED, ledState);
    }
    
  }

  if (Serial.available())
  {

    serialReceivedValue = Serial.read();

    if ('1' == serialReceivedValue)
    {
      sinusDelayMs = DELAY_100_MS;
    }
    else if ('2' == serialReceivedValue)
    {
      sinusDelayMs = DELAY_50_MS;
    }
    else if ('3' == serialReceivedValue)
    {
      sinusDelayMs = DELAY_20_MS;
    }
    else if ('4' == serialReceivedValue)
    {
      sinusDelayMs = DELAY_10_MS;
    }
    
  }

}
