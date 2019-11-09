float[] bgc = new float[3];
float ln = 1;
int nl = 10;
int ns = 10; // number of segments
float gap;
float sgap;
float r = 50;
float[][] ctrl = new float[ns][4];

void setup(){
  size(600,300);
  noFill();
  gap = height/(nl+1);
  sgap = width/(ns+1);
  for(int i=0;i<ns;i++){
    ctrl[i][0] = sgap*i;
    ctrl[i][1] = height-gap;
    ctrl[i][2] = sgap*i;
    ctrl[i][3] = height-gap;
  }
  randomBG();
  drawCurves();
}

void drawCurves(){
  for(int j =0;j<nl;j++){
    iStroke(256-(192/nl)*j);
    for(int i =0;i<ns;i++){
      float x1 = sgap*i;
      float x2 = sgap*(i+1);
      float y = height-(gap*j);
      for(int k=0;k<4;k++){
        ctrl[i][k] += random(r)-(r/2);
      }
      curve(ctrl[i][0],ctrl[i][1],x1,y,x2,y,ctrl[i][2],ctrl[i][3]);
    }
  }
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

void iStroke(float alpha){
  stroke(256-bgc[0],256-bgc[1],256-bgc[2],alpha);
}

void draw(){}

void mousePressed(){
  for(int i=0;i<ns;i++){
    ctrl[i][0] = sgap*i;
    ctrl[i][1] = height-gap;
    ctrl[i][2] = sgap*i;
    ctrl[i][3] = height-gap;
  }
  randomBG();
  drawCurves();
}
