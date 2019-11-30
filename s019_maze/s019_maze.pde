// made by alex
// iamalexbaker@gmail.corm

int num_lines = 8;
int shape = 3; // 3 = triangle, 4 = square, 5 = pentagon, etc
float gap = 15;
float pad = 10;
float offset_angle;
color bg = color(220);
float colourSpread = 80;
color lineColour;
boolean start_cross = false; // it sets randomly in setup() - comment it if you want it stable

boolean do_draw;
PVector origin;
ArrayList<ray> rays = new ArrayList<ray>();
ArrayList<boundary> lines = new ArrayList<boundary>();
float shape_angle;
int active_rays;
int rotation_dir;

class boundary {
  boolean wall;
  PVector a, b;

  boundary(float x1, float y1, float x2, float y2, boolean w) {
    a = new PVector(x1, y1); 
    b = new PVector(x2, y2); 
    wall = w;
  }

  void show() {
    stroke(lineColour, 255);
    line(a.x, a.y, b.x, b.y);
  }
}

class ray {
  PVector pos, dir;
  color colour;
  float angle;
  boolean active;
  ArrayList<boundary> bb;
  int _step = 1;
  int id;

  ray(PVector p, float a, color c, ArrayList<boundary> b) {
    active = true; 
    pos = new PVector(p.x, p.y); 
    colour = c; 
    angle = a; 
    dir = PVector.fromAngle(a); 
    bb = b; 
    id = int(random(1000));
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
    //line(pos.x, pos.y, pos.x + dir.x*150, pos.y + dir.y*150);
    //ellipse(pos.x + dir.x*150, pos.y + dir.y*150, 10,8);
    //text(_step, pos.x + dir.x*150, pos.y + dir.y*150);

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

  hit multicast(ArrayList<boundary> walls)
  {
    float record = Float.POSITIVE_INFINITY;
    PVector h;
    float d;
    PVector pt = new PVector(0, 0);
    boundary b = walls.get(1);
    // find nearest boundary, so ray doesn't hit multiple walls
    for (boundary wall : walls) {
      h = cast(wall);
      boolean cond = start_cross ? (h != null && (wall.wall || _step > 1)) : h != null;
      if (cond) {
        //noStroke();
        //ellipse(h.x, h.y, 20,20);
        d = pos.dist(h);
        if (d < record) {
          record = d;
          pt = h;
          b = wall;
        }
      }
    }
    if (record < Float.POSITIVE_INFINITY) {
      return new hit(pt, b);
    } else return null;
  }

  void step() {
    println(" --- step --- "+_step+" id "+id);
    boolean valid = false;
    float distance = 0;
    hit h = null;
    float o_angle = angle;
    float rot_dir = (rotation_dir==0) ? int(random(2))*2 - 1 : rotation_dir; // pick - 1 or 1 if dir is 0
    for (int i = 0; i < shape; i ++) {
      angle = (angle + rot_dir * shape_angle) % TWO_PI;
      if ((angle + PI) % TWO_PI == o_angle) { 
        println("OH"); 
        continue;
      }
      dir = PVector.fromAngle(angle);
      h = multicast(bb);
      distance = pos.dist(h.p);
      if (distance > gap + pad)
      {
        valid = true;
        break;
      }
    }

    if (!valid) {
      stroke(0, 255, 0);
      //line(pos.x,pos.y,h.p.x,h.p.y);
      //ellipse(h.p.x, h.p.y, 5, 5);
      println("deactivate on step "+_step+" "+h.b.wall+", pos: "+pos+", h.p: "+h.p);
      //ellipse(h.p.x,h.p.y,10,10);
      active = false;
      active_rays--;
    } else {
      color cc = color(random(255), random(255), random(255));
      stroke(cc);
      fill(cc);
      pushMatrix();
      translate(pos.x, pos.y);
      rotate(angle-PI/2);
      translate(0, distance - gap);
      PVector v = getMatrix().mult(new PVector(0, 0), null);
      popMatrix();
      println("num boundaries: "+lines.size());
      lines.add(new boundary(pos.x, pos.y, v.x, v.y, false));
      pos.x = v.x;
      pos.y = v.y;
      println("v "+v);
      println("angle: "+angle+", dir: "+dir);
      pushMatrix();
      translate(width/2, height/2);
      //line(0,0,dir.x*30,dir.y*30);
      popMatrix();
      _step++;
    }
  }
}

class hit {
  PVector p;
  boundary b;

  hit(PVector pp, boundary bb) {
    p = pp; 
    b = bb;
  }
}

void setup() {
  size(800, 800);
  background(bg);
  strokeWeight(4);
  do_draw = true;
  shape_angle = TWO_PI/shape;
  offset_angle = random(TWO_PI);
  start_cross = parseBoolean(int(random(2)));
  println("shape_angle: "+shape_angle);
  rays.clear();
  lines.clear();

  origin = new PVector(random(width), random(height));
  rotation_dir = int(random(3))- 1;
  lineColour = dullColour(colourSpread);

  // boundaries of screen
  lines.add(new boundary(0, 0, width, 0, true));
  lines.add(new boundary(0, 0, 0, height, true));
  lines.add(new boundary(0, height, width, height, true));
  lines.add(new boundary(width, 0, width, height, true));

  active_rays = num_lines;

  for (int i = 0; i < num_lines; i++)
  {
    pushMatrix();
    translate(width/2, height/2);
    rotate(shape_angle*i - PI/2);
    stroke(100*(i+1), 0, 0);
    //line(0,0,0,200);
    popMatrix();
    rays.add(new ray(new PVector(random(width), random(height)), shape_angle*i + offset_angle, lineColour, lines));
  }
  println(lines.size());
}

void draw() {
  do {
    for (ray r : rays) {
      //println("ray "+r.pos);
      if (r.active) {
        r.step();
      }
    }
  } while (active_rays > 0);
  if (do_draw) {
    for (boundary l : lines) {
      println("line: "+l.a+" - "+l.b);
      if (!l.wall) {
        l.show();
      }
    }
    do_draw = false;
  }
}

void keyPressed()
{
  if (keyCode==32) {
    saveFrame("maze-"+hour()+"-"+minute()+"-"+second()+".png");
  }
  if (keyCode==10) {
    setup();
  }
}

color dullColour(float spread)
{
  color col;
  float x = random(255);
  col = color(constrain(x + random(spread) - spread/2, 0, 255), constrain(x + random(spread) - spread/2, 0, 255), constrain(x + random(spread) - spread/2, 0, 255));
  return col;
}
