float[] v = {0, 0, 0};
float w = 300;
boolean do_draw = true;

float[] hue = {0, TWO_PI, 0};
float[] sat = {0, 0.7, 0};
float[] bri = {0., 0.8, 0};
int nc = 2;
color[] c = new color[nc];
color bgc, lc;

void setup() {
  size(800, 800);
  smooth(4);
  colorMode(HSB, TWO_PI, 1, 1);
  bgc = color(0, 0, 0.8);
  lc = color(0, 0, 0.2);
  for(int i = 0; i < nc; i++){
    c[i] = color(random(hue[0], hue[1]), random(sat[0], sat[1]), random(bri[0], bri[1]));
  }
  do_draw = true;
  for (int i = 0; i < 3; i++) {
    v[i] = random(1, 2);
  }
}

void draw() {
  if (!do_draw) return;
  background(bgc);
  //translate(width/2, height/2);
  //rotate(random(TWO_PI));

  float tt = 0;
  for (int j = 0; j < 64; j++) {
    beginShape();
    v[0] = lerp(v[0], v[2], 0.1);
    v[2] = lerp(v[2], v[0], 0.1);
    v[1] *= 0.9;
    float t, x = 0, y = 0;
    for (t = tt; t < PI*16 + tt; t += PI/128) {
      x = sin(t*v[0] + v[1]) * width + width/2;
      y = sin(t*v[2]) * height + height/2;
      vertex(x, y);
    }
    stroke(30, 16);
    line(x, -height, x, height);
    line(-width, y, width, y);
    noFill();
    stroke(lerpColor(c[0], c[1], float(j)/64), 64);
    endShape();
    tt = t;
  }

  do_draw = false;
}
void keyPressed()
{
  if (keyCode==32) { // space
    String fn = "cc-"+hour()+"-"+minute()+"-"+second()+".png";
    saveFrame(fn);
    println("Saved image "+fn);
  }
  if (keyCode==10) { // enter
    setup();
    println("Initialising new state");
  }
}
