// made by alex
// iamalexbaker@gmail.com

float[] bgc = new float[3];
float csize = 2;
int m = 2;
int num_points = 180;
void setup(){
  size(600,600);
  //rectMode(CENTER);
  textSize(24);
  randomBG(1);
  //pointCircle(190,num_points);
  frameRate(20);
  strokeWeight(3);
}

void draw(){
  resetBG();
  pointCircle((width/2)-10,num_points);
  text(m,10,30);
  m++;
}

void pointCircle(float radius, int np){
  noStroke();
  float angle = TWO_PI/(float)np;
  for(int i=0;i<np;i++){
    float xp = width/2+(radius*sin(angle*i));
    float yp = height/2+(radius*cos(angle*i));
    iFill(0);
    circle(xp,yp,csize);
    iFill(1);
    //text(i,xp-4,yp+2);
  }
  
  for(int i=0;i<np;i++){
    int dest = (i*(m-1)) % num_points;
    float sx = width/2+(radius*sin(angle*i));
    float sy = height/2+(radius*cos(angle*i));
    float ex = width/2+(radius*sin(angle*dest));
    float ey = height/2+(radius*cos(angle*dest));
    iFill(2);
    line(sx,sy,ex,ey);
  }
  
  for(int i=0;i<np;i++){
    int dest = (i*m) % num_points;
    float sx = width/2+(radius*sin(angle*i));
    float sy = height/2+(radius*cos(angle*i));
    float ex = width/2+(radius*sin(angle*dest));
    float ey = height/2+(radius*cos(angle*dest));
    iFill(0);
    line(sx,sy,ex,ey);
  }
}

void randomBG(int set){
  int i = 0;
  float x = random(256);
  for(i=0;i<3;i++){
    // constrain for dull colours
    float r = 32;
    bgc[i] = constrain(x + random(r) - r/2,0,256);
  }
  if(set>0){
    background(bgc[0],bgc[1],bgc[2]);
  }
}
void resetBG(){
  background(bgc[0],bgc[1],bgc[2]);
}
void iFill(int mode){
  if(mode==0){//inverse
    strokeWeight(3);
    stroke(256-bgc[0],256-bgc[1],256-bgc[2],128);
    fill(256-bgc[0],256-bgc[1],256-bgc[2],192);
  }
  else if(mode==1){//bg colour
    strokeWeight(3);
    stroke(bgc[0],bgc[1],bgc[2],128);
    fill(bgc[0],bgc[1],bgc[2],192);
  }
  else if(mode==2){//inverse but weaker
    strokeWeight(2);
    stroke(256-bgc[0],256-bgc[1],256-bgc[2],64);
    fill(256-bgc[0],256-bgc[1],256-bgc[2],128);
  }
}

void mousePressed(){
  randomBG(0);
}
