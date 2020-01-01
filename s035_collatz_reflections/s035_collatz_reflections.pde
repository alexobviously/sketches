// made by alex
// iamalexbaker@gmail.com
// dailygenerative.art.blog

// still a WIP - lots of things haven't been implemented yet

// raycast vars
float c_size = 15;
int show_boundaries = 0;
int[] num_walls = {1,15};

// collatz vars
float[] len = {14,18};
float[] angle = {-PI/2, PI/2, 0};
int[] start = {1000000, 2000000, 0};
int[] num = {100, 3000, 0};
float[] size = {1, 5, 0};
float[] weights = {1,0,0,0}; // probability of {line, circle, square, blank}
boolean drawHairs = false; // nice with either low numbers of lines, or long scale and wide len range
float[] hairScale = {1.2, 5.5, 0}; // multiple of the length of the main line (len variable)
int hairColourMode = 0; // 0 = white, 1 = c[0], 2 = c[1], 3 = cc (lerp), 4 = bgc

// colour vars
float[] hueRange = {0, TWO_PI};
float[] satRange = {0, 0.7};
float[] briRange = {0, 0.9};
float alpha = 10;
int nc = 2;
color[] c = new color[nc];
color fixedColour;
color bgc;
float hue, sat, bri;

boolean do_draw = true;
ArrayList<boundary> walls = new ArrayList<boundary>();
PVector origin;

boundary lastHit;

void setup(){
  size(800,800);
  do_draw = true;
  nnn = 0;
  lastHit = null;
  colorMode(HSB, TWO_PI, 1, 1);
  bgc = color(0, 0, 0.2); // * 0.2 and * 0.8 are both nice
  background(bgc);
  fixedColour = color(PI, PI, PI);
  hue = random(hueRange[0], hueRange[1]);
  sat = random(satRange[0], satRange[1]) * TWO_PI;
  bri = random(briRange[0], briRange[1]) * TWO_PI;
  for(int i = 0; i < nc; i++){
    c[i] = color(random(hueRange[0], hueRange[1]), random(satRange[0], satRange[1]) * TWO_PI, random(briRange[0], briRange[1]) * TWO_PI);
  }
  origin = new PVector(random(width-2)+1,random(height-2)+1);
  start[2] = int(random(start[0], start[1]));
  num[2] = int(random(num[0], num[1]));
  size[2] = random(size[0], size[1]);
  angle[2] = random(angle[0], angle[1]);
  walls.clear();
  
  // boundaries of screen
  walls.add(new boundary(0,0,width,0));
  walls.add(new boundary(0,0,0,height));
  walls.add(new boundary(0,height,width,height));
  walls.add(new boundary(width,0,width,height));
  
  //walls.add(new boundary(0,0,550,800));
  
  // generate boundaries
  float n_walls = random(num_walls[1]-num_walls[0])+num_walls[0];
  for (int i = 0; i < n_walls; i++) {
    walls.add(new boundary(random(width), random(height), random(width), random(height)));
  }
}

void draw(){
  if(!do_draw) return;
  background(bgc);
  if(show_boundaries == 1){
    for (boundary wall : walls) {
      wall.show();
    }
  }
  //ellipse(origin.x, origin.y, 10, 10);
  
  cycle(start[2], start[2]+num[2], angle[2], 0, origin);
  do_draw = false;
}

void cycle(int s, int e, float a, float r, PVector o)
{
  for (int i = s; i < e; i++) {
    LongList seq = new LongList();
    resetMatrix();
    long n = i;
    do {
      seq.append(n);
      n = collatz(n);
    } while (n != 1);
    seq.append(1);
    seq.reverse();
    float rot = r;
    PVector _pos = origin;
    for (int j = 0; j < seq.size(); j++)
    {
      
      fill(0,0.3,0.6);
      stroke(0,0.3,0.6);
      //line(_pos.x, _pos.y, _pos.x + PVector.fromAngle(rot).x * 110, _pos.y + PVector.fromAngle(rot).y * 110);
      
      float l = random(len[0], len[1]);
      color cc = lerpColor(c[0], c[1], float(j)/seq.size());
      
      if(drawHairs){
        color hc;
        switch(hairColourMode){
          default:
          case 0: hc = color(0, 0, 1); break;
          case 1: hc = c[0]; break;
          case 2: hc = c[1]; break;
          case 3: hc = cc; break;
          case 4: hc = bgc; break;
        }
        ray _r2 = new ray(_pos.x, _pos.y, PVector.fromAngle(rot), 1, 0.01, hc, 0);
        hit h2 = _r2.multicast(walls, l * random(hairScale[0], hairScale[1]));
        _r2.show(h2);
      }
      
      ray _ray = new ray(_pos.x, _pos.y, PVector.fromAngle(rot), 1, 0.01, cc, 0);
      //line(_ray.pos.x, _ray.pos.y, _ray.pos.x + _ray.dir.x * 80, _ray.pos.y + _ray.dir.y * 80);
      
      hit h = _ray.multicast(walls, l);
      if(h != null){
        _ray.show(h);
        _pos = h.p;
        if(h.realHit){
          rot = _ray.reflectionAngle(h);
          lastHit = h.b;
        }
        else{
          lastHit = null;
          long value = seq.get(j);
          if (value % 2 == 0) {
            rot += a;
          } else {
            rot -= a;
          }
        }
      }

      //int t = selectWeighted(weights);
      //switch(t){
      //  case 1:
      //    ellipse(0, 0, size[2], size[2]);
      //    break;
      //  case 2:
      //    rect(0, 0, size[2], size[2]);
      //    break;
      //  default:
      //  case 3:
      //    break;
      //  case 0:
      //    line(0, 0, 0, l);
      //    break;
      //}
      //translate(0, l);
    }
  }
}

class boundary {
  PVector a, b;
  PVector[] normal;
  float m, c;

  boundary(float x1, float y1, float x2, float y2) {
    if(x1 < x2){
      a = new PVector(x1, y1);
      b = new PVector(x2, y2);
      m = (y2-y1)/(x2-x1);
    } else {
      b = new PVector(x1, y1);
      a = new PVector(x2, y2);
      m = (y1-y2)/(x1-x2);
    }
    c = y1 - m*x1;
    normal = new PVector[2];
    normal[0] = PVector.fromAngle(atan2(b.y - a.y, b.x - a.x)+PI/2);
    normal[1] = PVector.fromAngle(atan2(b.y - a.y, b.x - a.x)-PI/2);
  }
  
  boolean containsPoint(PVector pt){
    return (pt.y == m*pt.x + c);
  }

  void show() {
    fill(0, 1, 1);
    ellipse(a.x, a.y, 5, 5);
    fill(PI, 1, 1);
    ellipse(b.x, b.y, 5, 5);
    stroke(0,0,1);
    line(a.x, a.y, b.x, b.y);
    float xx = a.x + (b.x-a.x)/2;
    float yy = a.y + (b.y-a.y)/2;
    line(xx, yy, xx+normal[0].x*10, yy+normal[0].y*10);
    stroke(0, 0.5, 1);
    line(xx, yy, xx+normal[1].x*10, yy+normal[1].y*10);
  }
}

class ray {
  PVector pos, dir;
  float power;
  float power_drop;
  color colour;
  int show_mode = 0;
  ray(float x, float y, PVector d, float p, float pd, color cc, int mode) {
    pos = new PVector(x, y);
    dir = d;
    power = p;
    power_drop = pd;
    colour = cc;
    show_mode = mode;
  }
  void show(hit h) {
    if(show_mode == 0 || show_mode == 2){
      stroke(colour, alpha);
      line(pos.x, pos.y, h.p.x, h.p.y);
    }
    if(show_mode == 1 || show_mode == 2){
      noStroke();
      fill(colour, alpha);
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
  hit multicast(ArrayList<boundary> walls, float distanceLimit)
  {
    float record = Float.POSITIVE_INFINITY;
    PVector h;
    float d;
    PVector pt = new PVector(0,0);
    boundary b = walls.get(1);
    
    // find nearest boundary, so ray doesn't hit multiple walls
    for(boundary wall : walls){
      if(wall == lastHit) continue; // IMPORTANT - this stops the bug where rays can pass through walls
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
    if(record < distanceLimit){
      return new hit(pt, b, true);
    } else {
      pt.x = pos.x + dir.x * distanceLimit;
      pt.y = pos.y + dir.y * distanceLimit;
      return new hit(pt, b, false);
    }
  }
  void recursivecast(ArrayList<boundary> walls)
  {
    hit h = multicast(walls, Float.POSITIVE_INFINITY);
    if(h != null)
    {
      show(h); // show this ray
      // calculate reflection
      PVector ref = PVector.sub(dir, PVector.mult(h.b.normal[0], PVector.dot(dir, h.b.normal[0])*2));
      // reduce power, cast next ray (reflection) if it still has power
      // --currently unused
      if(power-power_drop > 0){
        ray r = new ray(h.p.x,h.p.y,ref,power-power_drop,power_drop, colour, show_mode);
        r.recursivecast(walls);
      }
    }
  }
  float reflectionAngle(hit h){
    float d = (h.p.x - h.b.a.x)*(h.b.b.y - h.b.a.y) - (h.p.y - h.b.a.y)*(h.b.b.x - h.b.a.x);
    //println(d);
    
    
    
    int normalIndex = 0;//(d < 0)?1:0;
    PVector refAngle = PVector.sub(dir, PVector.mult(h.b.normal[normalIndex], PVector.dot(dir, h.b.normal[normalIndex])*2));
    float rot = refAngle.heading();
    //stroke(0,0.5,0.5);
    //fill(0,0.5,0.5);
    
    //line(pos.x, pos.y, pos.x + dir.x * 100, pos.y + dir.y * 100);
    //text(nnn, pos.x + dir.x * 100, pos.y + dir.y * 100);
    //println(nnn+": "+degrees(dir.heading())+" -> "+degrees(rot)+" :: "+h.b.containsPoint(h.p));
    //ellipse(h.p.x, h.p.y, 5, 5);
    //fill(0,0,0);
    //stroke(0,0,0);
    //line(h.p.x, h.p.y, h.p.x + refAngle.x*100, h.p.y + refAngle.y*100);
    //text(nnn, h.p.x + refAngle.x*100, h.p.y + refAngle.y*100);
    
    nnn++;
    return rot;
  }
  void lookAt(float x, float y) {
    dir.x = x - pos.x;
    dir.y = y - pos.y;
    dir.normalize();
  }
}
int nnn = 0;
class hit{
  PVector p;
  boundary b;
  boolean realHit;
  
  hit(PVector pp, boundary bb, boolean rh){
    p = pp; b = bb; realHit = rh;
  }
}

long collatz(long n) {
  if (n % 2 == 0) {
    return n / 2;
  } else {
    return (3*n + 1) / 2;
  }
}

// function to randomly select an array index from an array of weights
int selectWeighted(float[] w){
  int total = 0;
  for(float ww: w) total += ww;
  float r = random(total);
  int n = 0;
  for(float ww: w){
    r -= ww;
    if(r <= 0) return n;
    n++;
  }
  return w.length;
}

void keyPressed()
{
  if (keyCode==32) { // press space to save 
    saveFrame("crfn-"+hour()+"-"+minute()+"-"+second()+".png");
  }
  if (keyCode==10) { // press enter to reset
    setup();
  }
}
