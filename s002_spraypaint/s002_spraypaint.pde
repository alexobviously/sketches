float[] bgc = new float[3];
float d = 30;
int n = 20;
int mode = 0;
void setup(){
  size(400,400);
  randomBG();
  noStroke();
}
void draw(){
  float x = random(20);
  int i = 0;
  float xp;
  float yp;
  
  for(i=0;i<n;i++){
    xp = mouseX + random(d) - d/2;
    yp = mouseY + random(d) - d/2;
    if(mode==0){
      inverseEllipse(x,xp,yp);
    }
    else{
      colourEllipse(x,xp,yp);
    }
  }
}

void mousePressed(){
  if(mouseButton==LEFT) randomBG();
  if(mouseButton==RIGHT) mode = 1-mode;
}

void randomBG(){
  int i = 0;
  for(i=0;i<3;i++){
    bgc[i] = random(256);
  }
  background(bgc[0],bgc[1],bgc[2]);
  fill(256-bgc[0],256-bgc[1],256-bgc[2],16);
}

void colourEllipse(float size,float xp, float yp){
  fill(random(256),random(256),random(256),16);
  ellipse(xp,yp,size,size);
}
void inverseEllipse(float size, float xp, float yp){
  //fill(256-bgc[0],256-bgc[1],256-bgc[2],16);
  ellipse(xp,yp,size,size);
}
