// made by alex
// iamalexbaker@gmail.com

float[] bgc = new float[3];
int scan = 0;
int chance = 15;
int dir = 1;

void setup(){
  size(400,128);
  frameRate(180);
  randomBG();
}

void draw(){
  scan += dir;
  if(scan>width || scan<0){
    randomBG();
    chance = int(random(25))+5;
    dir = -dir;
  }
  if(random(100)<chance){
    hline(scan);
  }
}

void hline(float pos){
  strokeWeight(random(4));
  line(pos,0,pos,height);
}

void randomBG(){
  int i = 0;
  float x = random(256);
  for(i=0;i<3;i++){
    // constrain for dull colours
    float r = 32;
    bgc[i] = constrain(x + random(r) - r/2,0,256);
  }
  background(bgc[0],bgc[1],bgc[2]);
  stroke(256-bgc[0],256-bgc[1],256-bgc[2],256);
}
