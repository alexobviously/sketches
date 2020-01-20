// made by alex
// iamalexbaker@gmail.com
// dailygenerative.art.blog

float c_size = 15;
boolean buggy_walls = false;
int[] num_walls = {1,15};
float power_start = 0.7;
float[] power_dec = {0.05,0.2};
boolean show_boundaries = true;
int split_count = 5;
int hit_mode = 1; // 0 = lines, 1 = circles, 2 = both

float[] hueRange = {0, TWO_PI};
float[] satRange = {0, 0.7};
float[] briRange = {0.4, 0.8};
float alpha = 255;
float strokeWeight = 1;
int nc = 3;
color[] c = new color[nc];
color bgc;
float hue, sat, bri;

boolean do_draw = true;
PVector origin;
ArrayList<boundary> walls = new ArrayList<boundary>();

class shape{
  float density;
  
}

class boundary {
  PVector a, b, normal;
  float r;
  boolean mode; // false = reflect, true = refract

  boundary(float x1, float y1, float x2, float y2, float _r, boolean m) {
    a = new PVector(x1, y1);
    b = new PVector(x2, y2);
    normal = PVector.fromAngle(atan2(b.y - a.y, b.x - a.x)-PI/2);
    r = _r; mode = m;
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
  int generation;
  float refr_angle;
  ray(float x, float y, PVector d, float p, float pd, color[] cc, int mode, int g, float ra) {
    pos = new PVector(x, y);
    dir = d;
    power = p;
    power_drop = pd;
    colour = cc;
    show_mode = mode;
    generation = g;
    refr_angle = ra;
  }
  void show(hit h) {
    if(show_mode == 0 || show_mode == 2){
      stroke(lerpColor(colour[0],colour[1],(refr_angle<0)?power:refr_angle), power*alpha);
      line(pos.x, pos.y, h.p.x, h.p.y);
    }
    if(show_mode == 1 || show_mode == 2){
      noStroke();
      fill(lerpColor(colour[0],colour[1],(refr_angle<0)?power:refr_angle), power*alpha);
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
    println("recursive cast generation: "+generation);
    hit h = multicast(walls, lastHit);
    if(h != null)
    {
      show(h); // show this ray
      int m = (h.b.mode == false)?2:-2;
      // calculate refraction max / reflection
      PVector ref = PVector.sub(dir, PVector.mult(h.b.normal, PVector.dot(dir, h.b.normal)*m)).normalize();
      // reduce power, cast next ray (reflection) if it still has power
      if(power-power_drop > 0){
        if(h.b.mode){
          for(int i = 0; i < split_count; i++){
            float ra = float(i) / 10;
            color[] colNew = {colour[0], colour[1]};
            if(ra >= 0.5){
              colNew[0] = lerpColor(colour[0], colour[1], ra);
            } else {
              colNew[1] = lerpColor(colour[0], colour[1], ra);
            }
            ray r = new ray(h.p.x, h.p.y, dir.lerp(ref, ra), power-power_drop, power_drop, colNew, show_mode, generation+1, ra);
            r.recursivecast(walls, h.b);
          }
        } else {
            ray r = new ray(h.p.x, h.p.y, ref, power-power_drop, power_drop, colour, show_mode, generation+1, -1);
            r.recursivecast(walls, h.b);
        }
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

void setup(){
  size(800, 800);
  do_draw = true;
  origin = new PVector(random(width-2)+1,random(height-2)+1);
  
  colorMode(HSB, TWO_PI, 1, 1);
  bgc = color(0, 0, 0.2);
  hue = random(hueRange[0], hueRange[1]);
  sat = random(satRange[0], satRange[1]) * TWO_PI;
  bri = random(briRange[0], briRange[1]) * TWO_PI;
  for(int i = 0; i < nc; i++){
    c[i] = color(random(hueRange[0], hueRange[1]), random(satRange[0], satRange[1]), random(briRange[0], briRange[1]));
  }
  
  // boundaries of screen
  walls.clear();
  walls.add(new boundary(0, 0, width, 0, 1, false));
  walls.add(new boundary(0, 0, 0, height, 1, false));
  walls.add(new boundary(0, height, width, height, 1, false));
  walls.add(new boundary(width, 0, width, height, 1, false));
  
  // generate boundaries
  float n_walls = random(num_walls[1]-num_walls[0])+num_walls[0];
  for (int i = 0; i < n_walls; i++) {
    walls.add(new boundary(random(width), random(height), random(width), random(height), 1.0, true));
  }
  
}

void draw(){
  if(!do_draw) return;
  
  background(bgc);
  if(show_boundaries){
    for (boundary wall : walls) {
      wall.show();
    }
  }
  
  color[] cc = {c[0], c[1]};
  float p_d = random(power_dec[1]-power_dec[0])+power_dec[0];
  ray r = new ray(origin.x, origin.y, PVector.random2D(), 0.8, p_d, cc, hit_mode, 0, -1);
  r.recursivecast(walls, null);
  
  do_draw = false;
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
