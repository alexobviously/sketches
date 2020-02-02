float t = 0;
float u = 0;
float w = 300;
float a = PI/128;
float[] inc = {random(1,4), random(1,4)};
void setup() {
  size(800, 800);
  frameRate(120);
}

void draw() {
  translate(width/2, height/2);
  //background(230);
  t += a*inc[0];
  if (t > TWO_PI) t -= TWO_PI;
  u += a*inc[1];
  if(u > TWO_PI) u -= TWO_PI;

  float x = sin(t) * w;
  float y = sin(u) * w;

  noStroke();
  fill(30);
  ellipse(x, y, 10, 10);
}
