// made by alex
// iamalexbaker@gmail.com
// dailygenerative.art.blog

// https://en.wikipedia.org/wiki/Collatz_conjecture

PVector origin;
float shape = 3;
float rc[] = {12,12}; // distance to travel inwards/outwards per iteration, (set two values to the same (or close) for banding patterns - 10, 10 is good)
float initr = 320; // start radius (probably just set this to either innerRing or outerRing)
float innerRing = 100; // set to 0 for lines to disappear towards centre
float outerRing = 400; // set to >width for lines to disappear off edge
int radiusMode = 0; // 0 = barrier, 1 = allow negative, 2 = soft reflection (once), 3 = hard reflection, 4 = kill line
float[] anglemult = {0.05, 0.1, 0};
float[] startangle = {0, PI/12}; // lines will start randomly between these two angles
float[] startOffset = {0, TWO_PI, 0};
float[] strokeAlpha = {10, 15, 0};
int[] start = {1, 2500000};
int[] len = {1000, 2000};
int colourMode = 3; // -1 = fixedColour, 0 = solid, 1 = lerp, 2 = hue, 3 = saturation, 4 = brightness
boolean colourRotateMode = true; // false = 0 -> 1, true = sin(0) -?> sin(1)
boolean colourUseOffset = true; // false = use angle, true = use angle - offset (this refers to the random line offset, not colourOffsetAngle, just set that to 0, 0)
float[] colourLerpMag = {0.5, 1, 0};
float[] colourOffsetAngle = {0, TWO_PI, 0};
float[] hueRange = {0, TWO_PI};
float[] satRange = {0, 1};
float[] briRange = {0, 1};
// set fixed colour in setup

int nc = 2;
color[] c = new color[nc];
color fixedColour;
float hue = 0;
float sat = 0;
float bri = 0;
boolean init = true;
float crd2, bigt;

void setup(){
  size(800, 800);
  colorMode(HSB, TWO_PI, TWO_PI, TWO_PI);
  background(0, 0, TWO_PI * 0.8); // * 0.2 and * 0.8 are both nice
  fixedColour = color(PI, PI, PI);
  startOffset[2] = random(startOffset[0], startOffset[1]);
  strokeAlpha[2] = random(strokeAlpha[0], strokeAlpha[1]);
  colourOffsetAngle[2] = random(colourOffsetAngle[0], colourOffsetAngle[1]);
  colourLerpMag[2] = random(colourLerpMag[0], colourLerpMag[1]);
  hue = random(hueRange[0], hueRange[1]);
  sat = random(satRange[0], satRange[1]) * TWO_PI;
  bri = random(briRange[0], briRange[1]) * TWO_PI;
  for(int i = 0; i < nc; i++){
    c[i] = color(random(hueRange[0], hueRange[1]), random(satRange[0], satRange[1]) * TWO_PI, random(briRange[0], briRange[1]) * TWO_PI);
  }
  init = true;
  origin = new PVector(width/2, height/2);
  anglemult[2] = random(anglemult[0], anglemult[1]);
  bigt = TWO_PI / shape;
  crd2 = sin(bigt/2);
  int s = int(random(start[0], start[1]));
  int e = s + int(random(len[0], len[1]));
  cycle(s, e, origin);
}

void cycle(int s, int e, PVector o)
{
  for (int i = s; i < e; i++) {
    LongList seq = new LongList();
    resetMatrix();
    translate(o.x, o.y);
    //rotate(r);
    long n = i;
    int steps = 0;
    do {
      seq.append(n);
      n = collatz(n);
      steps++;
    } while (n != 1);
    seq.append(1);
    seq.reverse();
    //println("Line "+i+", length "+seq.size());
    float r = initr;
    float lastx = 0, lasty = 0;
    float offset = random(startangle[0], startangle[1]);
    float rr = r;
    LINE_LOOP:
    for (int j = 0; j < seq.size(); j++)
    {
      boolean break_loop = false;
      long value = seq.get(j);
      if (value % 2 == 0) {
        r += random(rc[0], rc[1]);
      } else {
        r -= random(rc[0], rc[1]);
      }
      if(r < innerRing){
        switch(radiusMode){
          default:
          case 0: rr = innerRing; break;
          case 1: rr = r; break;
          case 2: rr = innerRing + (innerRing - r);
          case 3:
            rr = hardReflect(r, innerRing, outerRing);
            break;
          case 4:
            rr = innerRing;
            break_loop = true;
            break;
        }
      }
      else if(r > outerRing){
        switch(radiusMode){
          default:
          case 0: rr = outerRing; break;
          case 1: rr = r; break;
          case 2: rr = outerRing - (r-outerRing); break;
          case 3:
            rr = hardReflect(r, innerRing, outerRing);
            break;
          case 4:
            rr = outerRing;
            break_loop = true;
            break;
        }
      } else { rr = r; }
      
      // this took me an embarrassingly long time to figure out
      float t = startOffset[2] + offset + (j * anglemult[2]);
      float tt = (startOffset[2] + t) % bigt;
      float rrr = crd2 / (tan(abs(bigt/2)) * cos(abs(bigt/2 - tt)));
      float x = rrr *rr* cos(t);
      float y = rrr *rr* sin(t);
      
      if(j > 0){
        color cc;
        float step = 0;
        if(colourRotateMode){
          step = sin((((colourUseOffset)?(t-offset):t) + colourOffsetAngle[2]) * colourLerpMag[2]);
        }
        else{
          step = abs((((((colourUseOffset)?(t-offset):t) + colourOffsetAngle[2]) * colourLerpMag[2]) % TWO_PI) / TWO_PI);
        }
        switch(colourMode){
          default:
            cc = fixedColour;
            break;
          case 0:
            cc = c[0];
            break;
          case 1:
            cc = lerpColor(c[0], c[1], step);
            break;
          case 2:
            cc = color(TWO_PI * step, sat, bri);
            break;
          case 3:
            cc = color(hue, TWO_PI * step, bri);
            break;
          case 4:
            cc = color(hue, sat, TWO_PI * step);
            break;
        }
        stroke(cc, strokeAlpha[2]);
        line(lastx, lasty, x, y);
        if(break_loop) break LINE_LOOP;
      }
      lastx = x;
      lasty = y;
    }
  }
}

void draw(){}

long collatz(long n) {
  if (n % 2 == 0) {
    return n / 2;
  } else {
    return (3*n + 1) / 2;
  }
}

float hardReflect(float in, float low, float high){
  do{
    if(in < low) in = low + (low - in);
    if(in > high) in = high - (in - high);
  }
  while (in < low || in > high);
  return in;
}

void keyPressed()
{
  if (keyCode==32) {
    saveFrame("triangularity-"+hour()+"-"+minute()+"-"+second()+".png");
  }
  if (keyCode==10) {
    setup();
  }
}
