// made by alex
// iamalexbaker@gmail.com
// dailygenerative.art.blog

// with variables in sets like {a, b, c}, a is the minimum and b is the maximum, a random value will be chosen in that range

float limit = 800;
float startR = 100;
float endR = 800;
float[] circle = {100, 5000, 200};
int[] numArcs = {100, 4000, 1000};
int[] offset = {0, 0, 0};
float[] startAngle = {0, TWO_PI, 0};

float alpha = 16;
float[] hue = {0, TWO_PI, 0};
float[] sat = {0, 0.7, 0};
float[] bri = {0, 0.8, 0};
int colourMode = 2; // -1 = solid colour, 0 = interp through radius, 1: interp through angle, 2: interp based on line length
int nc = 2;
color[] c = new color[nc];
color bgc, lc;

ArrayList<Integer> numbers;
int count = 1;
int index = 0;
ArrayList<Integer> sequence;

float r = startR;
float ri = 0.1;

void setup(){
  size(800,800);
  smooth(4);
  colorMode(HSB, TWO_PI, 1, 1);
  bgc = color(0, 0, 0.8);
  for(int i = 0; i < nc; i++){
    c[i] = color(random(hue[0], hue[1]), random(sat[0], sat[1]), random(bri[0], bri[1]));
  }
  background(bgc);
  numbers = new ArrayList<Integer>();
  sequence = new ArrayList<Integer>();
  startAngle[2] = random(startAngle[0], startAngle[1]);
  numArcs[2] = int(random(numArcs[0], numArcs[1]));
  circle[2] = random(circle[0], circle[1]);
  count = int(random(offset[0], offset[1]));
  println("Count offset: "+count);
  println("Start angle: "+(startAngle[2]/PI)+"PI");
  println("Num arcs: "+numArcs[2]);
  println("Circumference units: "+circle[2]);
  index = 0;
  r = startR;
  ri = (endR - startR) / float(numArcs[2]);
  noFill();
  stroke(255);
  for(int i = 0; i < numArcs[2]; i++){
    step();
  }
}
void draw(){
}

void step(){
  pushMatrix();
  int next = index - count;
  int dir = -1;
  if(next <= 0 || numbers.contains(next)){
    next = index + count;
    dir = 1;
  }
  float t1 = ((float(index) % circle[2]) / circle[2]) * TWO_PI;
  t1 = ((float(min(index,next)) % circle[2]) / circle[2]) * TWO_PI;
  float angle = ((float(abs(next-index)) % circle[2]) / circle[2]) * TWO_PI; //println(t2-t1);
  //println(angle+ " :: "+t1+ " ---"+float(index)%circle + " " + float(next)%circle);
  translate(width/2, height/2);
  rotate(t1 + startAngle[2]);
  
  color colour = c[0];
  switch(colourMode){
    default:
    case -1:
      break;
    case 0:
      colour = lerpColor(c[0], c[1], r/endR);
      break;
    case 1:
      colour = lerpColor(c[0], c[1], t1/TWO_PI);
      break;
    case 2:
      //colour = (dir>0)?c[0]:c[1]; // doesn't really work like I wanted
      colour = lerpColor(c[0], c[1], angle/TWO_PI);
      break;
  }
  stroke(colour, alpha);
  noFill();
  arc(0, 0, r, r, 0, angle);
  numbers.add(next);
  sequence.add(next);
  index = next;
  count++;
  r += ri;
  popMatrix();
}

void keyPressed()
{
  if (keyCode==32) { // space
    String fn = "reca-"+hour()+"-"+minute()+"-"+second()+".png";
    saveFrame(fn);
    println("Saved image "+fn);
  }
  if (keyCode==10) { // enter
    setup();
    println("Initialising new state");
  }
}
