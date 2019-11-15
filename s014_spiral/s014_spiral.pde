color[] c = new color[6];
float colour_spread = 40;
float circle_size = 1;

void setup()
{
  size(800,800);
  background(20);
  noStroke();
  int circles = 32;
  fill(255,255,255,255/circles);
  for(int i = 0; i < circles; i++)
  {
    circle(width/2, height/2, (width/circles-2)*i);
  }
  for(int i = 0; i < 6; i++) 
  {
    float cc = random(255);
    c[i] = color(constrain(cc+random(colour_spread)-colour_spread/2,0,255),constrain(cc+random(colour_spread)-colour_spread/2,0,255),constrain(cc+random(colour_spread)-colour_spread/2,0,255));
  }
  for(int i = 0; i < 18; i++)
  {
    spiral((i*10)*PI/180, c[0], c[1]);
  }
  for(int i = 18; i < 36; i++)
  {
    spiral((i*10)*PI/180, c[2], c[3]);
  }
}

void spiral(float offset, color c1, color c2)
{
  float angle = TWO_PI/(width/2)*(random(4)+2);
  for(int i = 0; i < width/2; i++)
  {
    float xp = width/2+(i*sin((angle*i) + offset));
    float yp = height/2+(i*cos((angle*i) + offset));
    println(float(i)/(width/2));
    fill(lerpColor(c1,c2,float(i)/(width/2)));
    circle(xp,yp,circle_size);//
  }
}

void draw(){};

void keyPressed()
{
  if(keyCode==10){
    println("enter");
     setup();
  }
}
