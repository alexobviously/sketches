
float dist = 3;
int np = 5;
int rate = 500;
int wrap = 1;
float[][] pts = new float[np][2];
float[][] colours = new float[np][3];

void setup(){
  size(800,800);
  frameRate(300);
  background(224,224,224);
  stroke(255,255,255,64);
  circle(400,400,5);
  for(int i=0;i<np;i++){
    setRandomColour(i);
    float xp = (width/2)-dist+random(dist*2);
    float yp = (height/2)-dist+random(dist*2);
    line(width/2,height/2,xp,yp);
    pts[i][0] = xp;
    pts[i][1] = yp;
  }
}

void draw(){
  for(int x=0;x<rate;x++){
  for(int i=0;i<np;i++){
    float xx = pts[i][0];
    float yy = pts[i][1];
    float xp = xx;
    float yp = yy;
    stroke(colours[i][0],colours[i][1],colours[i][2],128);
    if(wrap == 0){
      xp = constrain((xx)-dist+random(dist*2),0,width);
      yp = constrain((yy)-dist+random(dist*2),0,height);
      line(xx,yy,xp,yp);
    }
    else{
      xp = xx-dist+random(dist*2);
      yp = yy-dist+random(dist*2);
      longline(xx,yy,xp,yp);
    }
    
    
    pts[i][0] = xp;
    pts[i][1] = yp;
  }}
}

void setRandomColour(int idx){
  float r,g,b;
  r = random(256);
  g = random(256);
  b = random(256);
  colours[idx][0] = r;
  colours[idx][1] = g;
  colours[idx][2] = b;
}

void keyPressed()
{
  if(keyCode==32){
    saveFrame("output-######.png");
  }
  if(keyCode==10){
     setup();
  }
}

void longline(float x1, float y1, float x2, float y2)
{
  int a = 0;
  int xc = 0;
  int yc = 0;
  
  line(x1,y1,x2,y2);
  
  if(x2<0){ xc = -1; a++;}
  if(x2>width){ xc = 1; a++;}
  if(y2<0){ yc = -1; a++;}
  if(y2>height){ yc = 1; a++;}
  
  //print(a+", "+xc+", "+yc+" ("+x1+","+y1+") -> ("+x2+","+y2+")\n");
  
  // if line crosses both axes, find out which one it crosses first
  if(a>1)
  {
    float xi = 0; // x intercept
    if(xc==1) xi = width;
    float m = (y2-y1)/(x2-x1); // y = mx+b, find line equation
    float b = y1 - (m*x1);
    float yi = (m*xi) + b;
    if(yi>height || yi<0) xc = 0;
    else yc = 0;
    a--;
  }
  
  // line crosses one axis or we've decided which axis to cross first
  if(a==1)
  {
    if(xc==1)
    {
      float x3 = -(width-x1);
      float x4 = x3 + (x2-x1);
      longline(x3,y1,x4,y2);
    }
    if(xc==-1)
    {
      float x3 = width + x1;
      float x4 = width + x2;
      longline(x3,y1,x4,y2);
    }
    if(yc==1)
    {
      float y3 = -(height-y1);
      float y4 = y3 + (y2-y1);
      longline(x1,y3,x2,y4);
    }
    if(yc==-1)
    {
      float y3 = height + y1;
      float y4 = height + y2;
      longline(x1,y3,x2,y4);
    }
  }
}
