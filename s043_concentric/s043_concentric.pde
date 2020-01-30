// made by alex
// iamalexbaker@gmail.com
// dailygenerative.art.blog

PVector origin;
int numPoints = 360;
float radius = 50;
float thickness = 3;
float spacing = 0;
int numCircles = 50;
boolean resetArray = true;
int connectDepth = 2;
boolean useShape = true;
int shape = 8;
float startShape = 0;
int blendShape = 1;
boolean drawArcs = false;
boolean drawConn = true;

float[] hue = {0, TWO_PI, 0};
float[] sat = {0, 0.7, 0};
float[] bri = {0., 0.8, 0};
int nc = 2;
color[] c = new color[nc];
color bgc, lc;

float a = TWO_PI / numPoints;
float[][] circles = new float[numCircles][numPoints];
float bigt = TWO_PI / shape;
float crd2 = sin(bigt / 2);

boolean do_draw = true;


void setup(){
  size(800, 800);
  smooth(4);
  colorMode(HSB, TWO_PI, 1, 1);
  bgc = color(0, 0, 0.8);
  lc = color(0, 0, 0.2);
  for(int i = 0; i < nc; i++){
    c[i] = color(random(hue[0], hue[1]), random(sat[0], sat[1]), random(bri[0], bri[1]));
  }
  origin = new PVector(width/2, height/2);
  stroke(230);
  noFill();
  startShape = random(PI);
  do_draw = true;
  if(resetArray){
    for(int i = 0; i < numCircles; i++){
      for(int j = 0; j < numPoints; j++){
        circles[i][j] = 0.0;
      }
    }
  }
}

void draw(){
  if(!do_draw) return;
  background(bgc);
  float _radius = radius;
  for(int j = 0; j < numCircles; j++){
    beginShape();
    int sP = int(random(float(numPoints)));
    int nP = int(random(float(numPoints)));
    float bs = (blendShape!=0)?(float(j) / numCircles):1.0;
    for(int i = sP; i < sP + nP; i++){
      int ii = i % numPoints;
      float t = ii * a;
      float r = random(_radius - thickness, _radius + thickness);
      
      if(useShape){
        switch(blendShape){
          default:
          case 0:
            r *= mapShape(t);
            break;
          case 1:
            r *= lerp(1.0, mapShape(t), bs);
            break;
          case -1:
            r *= lerp(mapShape(t), 1.0, bs);
            break;
        }
      }
      circles[j][ii] = r;
      float x = origin.x + r * cos(t);
      float y = origin.y + r * sin(t);
      vertex(x, y);
      if(j > 0 && drawConn){
        boolean found = false;
        for(int k = 0; k < min(connectDepth, j); k++){
          if(found) continue;
          float z = circles[j-(k+1)][ii];
          if(z > 0){
            float x2 = origin.x + z * cos(t);
            float y2 = origin.y + z * sin(t);
            //stroke(lc, 120);
            stroke(lerpColor(c[0], c[1], float(j)/numCircles));
            line(x, y, x2, y2);
            found = true;
          }
        }
      }
    }
    _radius += spacing + thickness * 2;
    if(drawArcs) stroke(lerpColor(c[0], c[1], float(j)/numCircles));
    else noStroke();
    endShape();
  }
  do_draw = false;
}

float mapShape(float t){
  float tt = (startShape + t) % bigt;
  float r = crd2 / (tan(abs(bigt/2)) * cos(abs(bigt/2 - tt)));
  return r;
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
