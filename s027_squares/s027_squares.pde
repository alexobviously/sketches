// made by alex
// iamalexbaker@gmail.com
// dailygenerative.art.blog

float midSquare = 3.5;
float gap = 1;
float minLen = 3;
int maxPower = 2; // 1 - will always divide into 2, 2 - divides into 2 or 4, 3 - 2, 4 or 8
float colourRange = 1;
boolean innerSquare = false;
float drawChance = 1.0;
float fillAlpha = 150;
boolean alwaysFinish = false; // doesn't work yet
int drawMode = 0; // 0 - squares, 1 - lines from midpoints, 2 - square lines

float midSquareSize;
PVector origin;

int nc = 2;
color[] c = new color[nc];

class edge{
  PVector dir;
  
}

void setup(){
  size(800,800);
  origin = new PVector(width/2, height/2);
  rectMode(CENTER);
  colorMode(HSB, TWO_PI, 1, 1);
  
  for(int i = 0; i < nc; i++){
    c[i] = color(random(TWO_PI), random(1), random(1));
  }
  stroke(0,0,0,200);
  //noStroke();
  background(0, 0, 0.8);
  //bggrid(40, 4);
  fill(c[0], fillAlpha);
  midSquareSize = width/midSquare;
  
  if(innerSquare && random(1) < drawChance) rect(origin.x, origin.y, midSquareSize-gap*2, midSquareSize-gap*2);
  subdivide(int(pow(2,int(random(maxPower))+1)), new PVector(origin.x, origin.y - midSquareSize/2), midSquareSize, new PVector(0,-1), true);
  subdivide(int(pow(2,int(random(maxPower))+1)), new PVector(origin.x, origin.y + midSquareSize/2), midSquareSize, new PVector(0,1), true);
  subdivide(int(pow(2,int(random(maxPower))+1)), new PVector(origin.x - midSquareSize/2, origin.y), midSquareSize, new PVector(-1,0), true);
  subdivide(int(pow(2,int(random(maxPower))+1)), new PVector(origin.x + midSquareSize/2, origin.y), midSquareSize, new PVector(1,0), true);
}

void bggrid(int div, float gap){
  
  float n = width/div;
  for(int i = 0; i < div; i++){
    for(int j = 0; j < div; j++){
      fill(PI * ((j+i)%2), 0.2, 0.2);
      rect(i*n + n/2, j*n + n/2, n - gap*2, n - gap*2);
    }
  }
}

void subdivide(int n, PVector mid, float len, PVector dir, boolean corner){
  float x, y;
  float newLen = len/n;
  if(newLen < minLen){
    if(alwaysFinish){
      while (newLen < minLen){
          
          newLen *= 2;
          n /= 2;
          println(newLen+" "+minLen+" "+n);
      } 
      if(n<2) return;
    }
    else return;
  }
  PVector newMid = new PVector(mid.x + (dir.x * newLen * 0.5), mid.y + (dir.y * newLen * 0.5));
  PVector divDir = new PVector(dir.y, dir.x);
  PVector start = new PVector((newMid.x + newLen/2 * divDir.x) - (divDir.x * newLen*(n/2)), (newMid.y + newLen/2 * divDir.y) - (divDir.y * newLen*(n/2)));
  PVector step = new PVector(newLen * divDir.x, newLen * divDir.y);
  for(int i = 0; i < n; i++){
    x = start.x + step.x * i;
    y = start.y + step.y * i;
    fill(lerpColor(c[0], c[1], origin.dist(new PVector(x, y))/(width/colourRange)), fillAlpha);
    if(random(1) < drawChance){
      switch(drawMode){
        case 0:
          rect(x, y, newLen - gap*2, newLen - gap*2);
          break;
        case 1:
          line(mid.x, mid.y, x, y);
          break;
      }
    }
    subdivide(int(pow(2,int(random(maxPower))+1)), new PVector(x + (dir.x * newLen * 0.5), y + (dir.y * newLen * 0.5)), newLen, dir, false);
  }
  if(corner){
    x = start.x - step.x;
    y = newMid.y + (newMid.y - (start.y - step.y)); // have to invert the corners for one axis because of Processing's backwards y axis
    fill(lerpColor(c[0], c[1], origin.dist(new PVector(x, y))/(width/colourRange)), fillAlpha);
    if(random(1) < drawChance){
      switch(drawMode){
        case 0:
          rect(x, y, newLen - gap*2, newLen - gap*2);
          break;
        case 1:
          line(mid.x, mid.y, x, y);
          break;
      }
    }
    subdivide(int(pow(2,int(random(maxPower))+1)), new PVector(x + (dir.x * newLen * 0.5), y + (dir.y * newLen * 0.5)), newLen, dir, true);
    subdivide(int(pow(2,int(random(maxPower))+1)), new PVector(x - (divDir.x * newLen * 0.5), y + (divDir.y * newLen * 0.5)), newLen, new PVector(-divDir.x, divDir.y), false);
  }
}

void draw(){}

void keyPressed()
{
  if (keyCode==32) {
    saveFrame("sq-"+hour()+"-"+minute()+"-"+second()+".png");
  }
  if (keyCode==10) {
    setup();
  }
}
