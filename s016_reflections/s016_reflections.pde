// made by alex
// iamalexbaker@gmail.com

class boundary {
  PVector a, b, normal;

  boundary(float x1, float y1, float x2, float y2) {
    a = new PVector(x1, y1);
    b = new PVector(x2, y2);
    normal = PVector.fromAngle(atan2(b.y - a.y, b.x - a.x)-PI/2);
  }

  void show() {
    stroke(255);
    line(a.x, a.y, b.x, b.y);
    float xx = a.x + (b.x-a.x)/2;
    float yy = a.y + (b.y-a.y)/2;
    //line(xx,yy,xx+normal.x*10,yy+normal.y*10);
  }
}

class ray {
  PVector pos, dir;
  float power;
  float power_drop;
  color[] colour;
  int show_mode = 0;
  ray(float x, float y, PVector d, float p, float pd, color[] cc, int mode) {
    pos = new PVector(x, y);
    dir = d;
    power = p;
    power_drop = pd;
    colour = cc;
    show_mode = mode;
  }
  void show(hit h) {
    if(show_mode == 0 || show_mode == 2){
      stroke(lerpColor(colour[0],colour[1],power), power*255);
      line(pos.x, pos.y, h.p.x, h.p.y);
    }
    if(show_mode == 1 || show_mode == 2){
      noStroke();
      fill(lerpColor(colour[0],colour[1],power), power*255);
      ellipse(h.p.x, h.p.y, c_size*power, c_size*power);
    }
  }

  PVector cast(boundary b) {
    // https://en.wikipedia.org/wiki/Line–line_intersection
    float x1, x2, x3, x4, y1, y2, y3, y4, d, t, u, hx, hy;
    x1 = b.a.x;
    y1 = b.a.y;
    x2 = b.b.x;
    y2 = b.b.y;
    x3 = pos.x;
    y3 = pos.y;
    x4 = pos.x + dir.x;
    y4 = pos.y + dir.y;

    d = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);
    if (d==0) return null;

    t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / d;
    u = - ((x1 - x2) * (y1 - y3) - (y1 - y2) * (x1 - x3)) / d;

    if (t > 0 && t < 1 && u > 0) {
      hx = x1 + t * (x2-x1);
      hy = y1 + t * (y2-y1);
      return new PVector(hx, hy);
    } else return null;
  }
  hit multicast(ArrayList<boundary> walls, boundary lastHit)
  {
    float record = Float.POSITIVE_INFINITY;
    PVector h;
    float d;
    PVector pt = new PVector(0,0);;
    boundary b = walls.get(1);
    // find nearest boundary, so ray doesn't hit multiple walls
    for(boundary wall : walls){
      if(wall == lastHit && !buggy_walls) continue; // IMPORTANT - this stops the bug where rays can pass through walls
      h = cast(wall);
      if(h != null){
        d = pos.dist(h);
        if(d < record){
          record = d;
          pt = h;
          b = wall;
        }
      }
    }
    if(record < Float.POSITIVE_INFINITY){
      return new hit(pt, b);
    } else return null;
  }
  void recursivecast(ArrayList<boundary> walls, boundary lastHit)
  {
    hit h = multicast(walls, lastHit);
    if(h != null)
    {
      show(h); // show this ray
      // calculate reflection
      PVector ref = PVector.sub(dir, PVector.mult(h.b.normal, PVector.dot(dir, h.b.normal)*2));
      // reduce power, cast next ray (reflection) if it still has power
      if(power-power_drop > 0){
        ray r = new ray(h.p.x,h.p.y,ref,power-power_drop,power_drop, colour, show_mode);
        r.recursivecast(walls, h.b);
      }
    }
  }
  void lookAt(float x, float y) {
    dir.x = x - pos.x;
    dir.y = y - pos.y;
    dir.normalize();
  }
}

class hit{
  PVector p;
  boundary b;
  
  hit(PVector pp, boundary bb){
    p = pp; b = bb;
  }
}

boundary bb;
ray r;
ArrayList<boundary> walls = new ArrayList<boundary>();
ArrayList<ray> rays = new ArrayList<ray>();
int do_draw = 1;
color c, c2;
PVector origin;
float[] start_angle = {0,360}; // all parameters with a range get a random value each run
float[] finish_angle = {0,360};
float[] angle_inc = {0.1,3.0};
int[] num_walls = {1,20};
float power_start = 0.7;
float[] power_dec = {0.01,0.08};
int colour_mode = 3; // 0 = one random colour for all rays, 1 = one random colour for each ray, 2 = two colours, fade through rotation, 3 = two colours for all rays, lerp based on power
int show_boundaries = 0;
int hit_mode = 2; // 0 = lines, 1 = circles, 2 = both
float circle_size[] = {4,15};
float c_size = 15;
boolean buggy_walls = false;

void setup() {
  size(800, 800);
  do_draw = 1;
  origin = new PVector(random(width-2)+1,random(height-2)+1);
  walls.clear();
  rays.clear();
  
  // boundaries of screen
  walls.add(new boundary(0,0,width,0));
  walls.add(new boundary(0,0,0,height));
  walls.add(new boundary(0,height,width,height));
  walls.add(new boundary(width,0,width,height));
  c = color(random(255),random(255),random(255));
  c2 = color(random(255),random(255),random(255));
  
  // generate boundaries
  float n_walls = random(num_walls[1]-num_walls[0])+num_walls[0];
  for (int i = 0; i < n_walls; i++) {
    walls.add(new boundary(random(width), random(height), random(width), random(height)));
  }
  
  // set random variables in defined ranges
  float start = random(start_angle[1]-start_angle[0])+start_angle[0];
  float finish = random(finish_angle[1]-finish_angle[0])+finish_angle[0];
  float ang_inc = random(angle_inc[1]-angle_inc[0])+angle_inc[0];
  float p_d = random(power_dec[1]-power_dec[0])+power_dec[0];
  float c_size = random(circle_size[1]-circle_size[0])+circle_size[0];
  
  // if finish < start, swap values
  if(finish<=start){
    float t = start;
    start = finish;
    finish = t;
  }
  
  // rotate through range and generate initial rays
  for (float i = start; i < finish; i+=ang_inc)
  {
    color[] cc = {c,c};
    switch(colour_mode){
      case 1:
        cc[0] = color(random(255),random(255),random(255));
        cc[1] = cc[0];
        break;
      case 2:
        float j = (i-start) / (finish-start);
        cc[0] = lerpColor(c,c2,j);
        cc[1] = cc[0];
        break;
      case 3:
        cc[0] = c;
        cc[1] = c2;
        break;
    }
    rays.add(new ray(origin.x, origin.y, PVector.fromAngle(radians(i)), power_start, p_d, cc, hit_mode));
  }
}

void draw() {
  if(do_draw==0) return;
  background(50);
  if(show_boundaries == 1){
    for (boundary wall : walls) {
      wall.show();
    }
  }
  
  for (ray r : rays) {
    r.recursivecast(walls, null);
  }
  do_draw = 0;
}
void mousePressed()
{
  setup();
}
void keyPressed()
{
  if(keyCode==32){
    saveFrame("reflections-"+hour()+"-"+minute()+"-"+second()+".png");
  }
  if(keyCode==10){
     setup();
  }
}
