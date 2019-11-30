// made by alex
// iamalexbaker@gmail.com

float colour_spread = 100;
float circle_size = 1;
float dens = 5;
int segments = 5;
color[] c = new color[segments*2];
int lines = 3;

void setup()
{
  size(800,800);
  background(20);
  noStroke();
  int circles = 64;
  int total_lines = lines * segments;
  int cur_line = 0;
  fill(255,255,255,255/circles);
  //fill(0,0,0,255/circles);
  for(int i = 0; i < circles; i++)
  {
    circle(width/2, height/2, (width/circles)*i*1.1);
  }
  for(int i = 0; i < c.length; i++) 
  {
    float cc = random(255);
    c[i] = color(constrain(cc+random(colour_spread)-colour_spread/2,0,255),constrain(cc+random(colour_spread)-colour_spread/2,0,255),constrain(cc+random(colour_spread)-colour_spread/2,0,255));
  }
  for(int i = 0; i < segments; i++)
  {
    for(int j = 0; j < lines; j++)
    {
      spiral(cur_line * (TWO_PI/total_lines), dens, c[i], c[i+1]);
      cur_line++;
    }
  }
  /*for(int i = 0; i < 18; i++)
  {
    spiral((i*10)*PI/180, dens, c[0], c[1]);
  }
  for(int i = 18; i < 36; i++)
  {
    spiral((i*10)*PI/180, dens+5, c[2], c[3]);
  }*/
}

void spiral(float offset, float density, color c1, color c2)
{
  float angle = TWO_PI/(width/2)*(random(4)+2);
  for(int i = 0; i < width*density; i++)
  {
    float xp = width/2+(i*sin((angle*i) + offset))*(1/density);
    float yp = height/2+(i*cos((angle*i) + offset))*(1/density);
    fill(lerpColor(c1,c2,float(i)/(width/2)));
    circle(xp,yp,circle_size);//
  }
}

void draw(){};

void keyPressed()
{
  if(keyCode==32){
    saveFrame("output-######.png");
  }
  if(keyCode==10){
     setup();
  }
}
