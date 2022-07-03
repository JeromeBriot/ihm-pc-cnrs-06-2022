#include <Elegoo_GFX.h>    // Core graphics library
#include <Elegoo_TFTLCD.h> // Hardware-specific library
#include <TouchScreen.h>

#define YP A3  // must be an analog pin, use "An" notation!
#define XM A2  // must be an analog pin, use "An" notation!
#define YM 9   // can be a digital pin
#define XP 8   // can be a digital pin

//Touch For New ILI9341 TP
//#define TS_MINX 120
//#define TS_MAXX 900
//
//#define TS_MINY 70
//#define TS_MAXY 920

#define TS_MINX 104
#define TS_MAXX 926

#define TS_MINY 73
#define TS_MAXY 907

// For better pressure precision, we need to know the resistance
// between X+ and X- Use any multimeter to read it
// For the one we're using, its 300 ohms across the X plate
TouchScreen ts = TouchScreen(XP, YP, XM, YM, 300);

#define LCD_CS A3
#define LCD_CD A2
#define LCD_WR A1
#define LCD_RD A0
// optional
#define LCD_RESET A4

// Assign human-readable names to some common 16-bit color values:
#define	BLACK   0x0000
#define	BLUE    0x001F
#define	RED     0xF800
#define	GREEN   0x07E0
#define CYAN    0x07FF
#define MAGENTA 0xF81F
#define YELLOW  0xFFE0
#define WHITE   0xFFFF


Elegoo_TFTLCD tft(LCD_CS, LCD_CD, LCD_WR, LCD_RD, LCD_RESET);

#define BOXSIZE 40
#define PENRADIUS 3
int oldcolor = BLACK;
int currentcolor = RED;

void setup(void) {
  Serial.begin(9600);
  Serial.println(F("Paint!"));

  tft.reset();

  uint16_t identifier = tft.readID();

  if (identifier == 0x9325) {
    Serial.println(F("Found ILI9325 LCD driver"));
  } else if (identifier == 0x9328) {
    Serial.println(F("Found ILI9328 LCD driver"));
  } else if (identifier == 0x4535) {
    Serial.println(F("Found LGDP4535 LCD driver"));
  } else if (identifier == 0x7575) {
    Serial.println(F("Found HX8347G LCD driver"));
  } else if (identifier == 0x9341) {
    Serial.println(F("Found ILI9341 LCD driver"));
  } else if (identifier == 0x8357) {
    Serial.println(F("Found HX8357D LCD driver"));
  } else if (identifier == 0x0101)
  {
    identifier = 0x9341;
    Serial.println(F("Found 0x9341 LCD driver"));
  } else {
    Serial.print(F("Unknown LCD driver chip: "));
    Serial.println(identifier, HEX);
    Serial.println(F("If using the Elegoo 2.8\" TFT Arduino shield, the line:"));
    Serial.println(F("  #define USE_Elegoo_SHIELD_PINOUT"));
    Serial.println(F("should appear in the library header (Elegoo_TFT.h)."));
    Serial.println(F("If using the breakout board, it should NOT be #defined!"));
    Serial.println(F("Also if using the breakout, double-check that all wiring"));
    Serial.println(F("matches the tutorial."));
    identifier = 0x9341;

  }

  tft.begin(identifier);
  tft.setRotation(2);

  tft.fillScreen(BLACK);

  tft.drawRect(0, 0, BOXSIZE * 6, BOXSIZE, WHITE);

  tft.fillRect(0, BOXSIZE, BOXSIZE, BOXSIZE, RED);
  tft.fillRect(BOXSIZE, BOXSIZE, BOXSIZE, BOXSIZE, YELLOW);
  tft.fillRect(BOXSIZE * 2, BOXSIZE, BOXSIZE, BOXSIZE, GREEN);
  tft.fillRect(BOXSIZE * 3, BOXSIZE, BOXSIZE, BOXSIZE, CYAN);
  tft.fillRect(BOXSIZE * 4, BOXSIZE, BOXSIZE, BOXSIZE, BLUE);
  tft.fillRect(BOXSIZE * 5, BOXSIZE, BOXSIZE, BOXSIZE, MAGENTA);

  tft.drawRect(0, BOXSIZE, BOXSIZE, BOXSIZE, WHITE);

  pinMode(13, OUTPUT);
}

#define MINPRESSURE 10
#define MAXPRESSURE 1000

void loop()
{
  digitalWrite(13, HIGH);
  TSPoint p = ts.getPoint();
  digitalWrite(13, LOW);

  pinMode(XM, OUTPUT);
  pinMode(YP, OUTPUT);

  // we have some minimum pressure we consider 'valid'
  // pressure of 0 means no pressing!

  if (p.z > MINPRESSURE && p.z < MAXPRESSURE) {

    // scale from 0->1023 to tft.width
    p.x = map(p.x, TS_MINX, TS_MAXX, tft.width(), 0);
    p.y = (tft.height() - map(p.y, TS_MINY, TS_MAXY, tft.height(), 0));

    if   (p.y < BOXSIZE) {
      // press the left of the screen to erase
      tft.fillRect(0, 2 * BOXSIZE, tft.width(), tft.height() - 2 * BOXSIZE, BLACK);
      Serial.println("!");
    }
    else if (p.y < 2 * BOXSIZE) {

      oldcolor = currentcolor;

      if (p.x < BOXSIZE) {
        currentcolor = RED;
      } else if (p.x < BOXSIZE * 2) {
        currentcolor = YELLOW;
      } else if (p.x < BOXSIZE * 3) {
        currentcolor = GREEN;
      } else if (p.x < BOXSIZE * 4) {
        currentcolor = CYAN;
      } else if (p.x < BOXSIZE * 5) {
        currentcolor = BLUE;
      } else if (p.x < BOXSIZE * 6) {
        currentcolor = MAGENTA;
      }

      if (oldcolor != currentcolor) {
        if (currentcolor == RED) {
          tft.fillRect(0, BOXSIZE, BOXSIZE, BOXSIZE, RED);
          tft.drawRect(0, BOXSIZE, BOXSIZE, BOXSIZE, WHITE);
          Serial.println("R");
        }
        else if (currentcolor == YELLOW) {
          tft.fillRect(BOXSIZE, BOXSIZE, BOXSIZE, BOXSIZE, YELLOW);
          tft.drawRect(BOXSIZE, BOXSIZE, BOXSIZE, BOXSIZE, WHITE);
          Serial.println("Y");
        }
        else if (currentcolor == GREEN) {
          tft.fillRect(BOXSIZE * 2, BOXSIZE, BOXSIZE, BOXSIZE, GREEN);
          tft.drawRect(BOXSIZE * 2, BOXSIZE, BOXSIZE, BOXSIZE, WHITE);
          Serial.println("G");
        }
        else if (currentcolor == CYAN) {
          tft.fillRect(BOXSIZE * 3, BOXSIZE, BOXSIZE, BOXSIZE, CYAN);
          tft.drawRect(BOXSIZE * 3, BOXSIZE, BOXSIZE, BOXSIZE, WHITE);
          Serial.println("C");
        }
        else if (currentcolor == BLUE) {
          tft.fillRect(BOXSIZE * 4, BOXSIZE, BOXSIZE, BOXSIZE, BLUE);
          tft.drawRect(BOXSIZE * 4, BOXSIZE, BOXSIZE, BOXSIZE, WHITE);
          Serial.println("B");
        }
        else if (currentcolor == MAGENTA) {
          tft.fillRect(BOXSIZE * 5, BOXSIZE, BOXSIZE, BOXSIZE, MAGENTA);
          tft.drawRect(BOXSIZE * 5, BOXSIZE, BOXSIZE, BOXSIZE, WHITE);
          Serial.println("M");
        }
      }
    }
    else if (((p.y - PENRADIUS) > BOXSIZE) && ((p.y + PENRADIUS) < tft.height())) {
      tft.fillCircle(p.x, p.y, PENRADIUS, currentcolor);
      Serial.print("X");
      Serial.print(p.x);
      Serial.print("Y");
      Serial.println(p.y);
    }
  }
}
