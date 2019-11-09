// made by alex
// iamalexbaker@gmail.com

float x1 = 300;
float x2 = 50000;
float y1 = 300;
float y2 = 50000;

float adj = 8000;
void setup(){
  size(500,500);
  background(230);
  stroke(50);
  longline(x1,y1,x2,y2);
  /*if(x2>width){
    float x3 = -max(0,width-x1);
    float x4 = x3 + (x2-x1);
    float y3 = -max(0,height-y1);
    float y4 = y3 + (y2-y1);
    line(x3,y1,x4,y2);
  }*/
  
}

void draw(){
  println("");
  background(230);
  x2 += random(adj)-(adj/2);
  y2 += random(adj)-(adj/2);
  longline(x1,y1,x2,y2);
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
  
  print(a+", "+xc+", "+yc+" ("+x1+","+y1+") -> ("+x2+","+y2+")\n");
  
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
