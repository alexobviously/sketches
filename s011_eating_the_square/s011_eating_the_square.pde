// made by alex
// iamalexbaker@gmail.com

color c1;
color c2;
color c3;
color[] c = new color[6];
int finalColour = 2;

int rate = 75;
int rate_t = 1;

float threshold = 0.8;

int stage = 0;
int transitioning = 0;

int t_grid = 20;
float t_time = 8.0;
int t_frames = 0;
int t_step = 0;

int intensity = 0;
int[] intensity_rate = {50,1,30,3};
int[][] intensity_limits = {{10,8000},{30,100},{100,3000}};

int n_circles = 8;
int n_rings = 3;
float angle_offset = 0;
float[] radius = {1,1,1};
float circle_size;
float circle_size_initial = 0.02;
int ring_active[] = new int[n_rings];

int[] stage_cycles = {0,4,4,3};
int cycle = 0;

int iteration = 0;

void setup()
{
  size(600,600);
  noStroke();
  stage = 0;
  transitioning = 0;
  t_step = 0;
  if(iteration==0) rate_t = 0;
  //float fr = frameRate;
  //t_frames = (t_time * fr);// / pow(t_grid,2);
  intensity = 0;
  intensity_rate[0] = 50;
  intensity_rate[1] = 2;
  angle_offset = 0;
  c[0] = c[2];
  c[1] = c[4];
  for(int i = (iteration==0)?0:2; i<c.length; i++)
  {
    c[i] = color(random(255),random(255),random(255));
  }
  background(c[0]);
  fill(c[1]);
  rect(width/4,height/4,width/2,height/2);
  iteration++;
}

void draw()
{
  float s;
  float x;
  float y;
  int gx;
  int gy;
  
  color cc;
  
  // STAGE 0 - 3
  float r = (stage==4)?exp(-intensity*0.01):rate_t;
  if(rate_t < rate) rate_t ++;
  for(int i = 0; i < r; i++)
  {
    s = random(10);
    x = random(width);
    y = random(height);
    if(x>=width/4 && x<=(3*width)/4 && y>=height/4 && y<=(3*height)/4)
    {
      fill(c[0]);
    }
    else
    {
      fill(c[1]);
    }
    ellipse(x,y,s,s);
  }
  
  // STAGE 0
  if(stage==0)
  {
    if(checkColour(20,4,c[1])>threshold){
      println("STAGE "+(stage+1));
      stage = 1;
      intensity = intensity_limits[0][0];
      cycle = 0;
    }
  }
  
  // STAGE 1 & 3
  if(stage == 1 || stage == 3)
  {
    if(stage == 1 || cycle < stage_cycles[3] - 1)
      intensity += intensity_rate[stage-1];
    else
      intensity -= abs(intensity_rate[stage-1])*2; // decrease it rapidly for the last cycle of stage 3
    if(intensity < intensity_limits[stage-1][0] || intensity > intensity_limits[stage-1][1]){
      intensity_rate[stage-1] *= -1;
      if(stage == 1) cycle++;
    }
    for(int i=0;i<intensity;i++)
    {
      x = (randomGaussian() * width * 0.2) + width/2;
      y = (randomGaussian() * height * 0.2) + height/2;
      set(int(x),int(y),c[2]);
    }
    if(cycle>stage_cycles[1] && stage == 1)
    {
      println("STAGE "+(stage+1));
      cycle = 0;
      stage = 2;
      intensity = intensity_limits[1][0];
      radius[0] = 1;
      radius[1] = width/3;
      radius[2] = 2*(width/3);
      angle_offset = 0;
      circle_size = circle_size_initial;
      for(int i = 0; i < n_rings; i++) ring_active[i] = 1;
    }
  }
  
  // STAGE 2 AND 3
  if(stage == 2 || stage == 3)
  {
    intensity += intensity_rate[1];
    if(intensity < intensity_limits[1][0] || intensity > intensity_limits[1][1]){
      intensity_rate[1] *= -1;
    }
    float angle;
    for(int k = 0; k < n_rings; k++)
    {
      if(ring_active[k] == 0) continue;
      for(int i = 0; i < n_circles; i++)
      {
        for(int j = 0; j < intensity; j++)
        {
          angle = (TWO_PI/n_circles)*i + angle_offset;
          x = (randomGaussian() * width * circle_size) + (width/2+(radius[k]*sin(angle)));
          y = (randomGaussian() * height * circle_size) + (height/2+(radius[k]*cos(angle)));
          set(int(x),int(y),lerpColor(c[3],c[4],(1/stage_cycles[3])*cycle));
        }
      }
      radius[k]++;
      if(radius[k] > width * 1.2){
        if(ring_active[k] == 1)
        {
          radius[k] = 1;
          if(stage == 3 && cycle > stage_cycles[stage] - 2) ring_active[k] = 0;
          cycle++;
        }
        println("cycle: "+cycle);
      }
    }
    angle_offset++;
    if(cycle>stage_cycles[stage])
    {
      circle_size = circle_size_initial;
      if(stage==3)
      {
        intensity = 1;
        for(int i = 0; i < n_rings; i++) ring_active[i] = 1;
      }
      cycle = 0;
      println("STAGE "+(stage+1));
      stage++;
    }
  }
  
  // STAGE 4
  if(stage == 4)
  {
    intensity += abs(intensity_rate[3]) * 2;
    for(int i = 0; i < intensity; i++)
    {
      x = random(width);
      y = random(height);
      
      if(x>=width/4 && x<=(3*width)/4 && y>=height/4 && y<=(3*height)/4)
      {
        cc = c[4];
      }
      else
      {
        cc = c[2];
      }
      set(int(x),int(y),cc);
    }
    if(checkColour(200,4,c[finalColour])>0.9 && transitioning == 0) 
    {
      t_step = 0;
      transitioning = 1;
    }
  }
  
  // TRANSITION STAGE (UNIVERSAL WHEN TRIGGERED)
  if(transitioning == 1)
  {
    for(int i = 0; i < t_step; i++)
    {
      gx = (i%t_grid);
      gy = floor(i/t_grid);
      x = gx*(width/t_grid);
      y = gy*(height/t_grid);
      if(gx>=t_grid/4 && gx<(3*t_grid)/4 && gy>=t_grid/4 && gy<(3*t_grid)/4)
      {
        cc = c[4];
      }
      else
      {
        cc = c[2];
      }
      fill(cc);
      rect(x,y,(width/t_grid),(height/t_grid));
    }
    t_step++;
    if(t_step > pow(t_grid,2)) setup();
  }
}

void mousePressed()
{
  transitioning = 1;
  //setup();
}

float checkColour(int n, float d, color col)
{
  int changed = 0;
  color cc;
  for(int i=0;i<n;i++)
  {
    int xx = int(random(width/d));
    int yy = int(random(height/d));
    cc = get(xx,yy);
    if(cc==col) changed++;
    //set(xx,yy,color(255,0,0)); // debug
  }
  return float(changed)/float(n);
}
