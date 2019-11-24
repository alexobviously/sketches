class boundary {
  PVector a, b, normal;

  boundary(float x1, float y1, float x2, float y2) {
    a = new PVector(x1, y1);
    b = new PVector(x2, y2);
    //normal = new PVector(-(y2-y1), (x2-x1));
    //normal.normalize();
    normal = PVector.fromAngle(atan2(b.y - a.y, b.x - a.x)-PI/2);
  }

  void show() {
    stroke(255);
    line(a.x, a.y, b.x, b.y);
    float xx = a.x + (b.x-a.x)/2;
    float yy = a.y + (b.y-a.y)/2;
    line(xx,yy,xx+normal.x*10,yy+normal.y*10);
  }
}

class ray {
  PVector pos, dir;
  float a;
  ray(float x, float y, float angle) {
    pos = new PVector(x, y);
    dir = PVector.fromAngle(angle);
    a = angle;
  }
  void update() {
    stroke(255);
    push();
    translate(pos.x, pos.y);
    line(0, 0, dir.x*10, dir.y*10);
    pop();
  }

  PVector cast(boundary b) {
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
  hit multicast(ArrayList<boundary> walls)
  {
    float record = Float.POSITIVE_INFINITY;
    PVector h;
    float d;
    PVector pt = new PVector(0,0);;
    boundary b = walls.get(1);
    for(boundary wall : walls){
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
      //PVector n = 
      return new hit(pt, b);
    } else return null;
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
PVector centre;

void setup() {
  size(600, 600);
  centre = new PVector(width/2,height/2);
  walls.add(new boundary(0,0,width,0));
  walls.add(new boundary(0,0,0,height));
  walls.add(new boundary(0,height,width,height));
  walls.add(new boundary(width,0,width,height));
  for (int i = 0; i < 1; i++) {
    walls.add(new boundary(random(width), random(height), random(width), random(height)));
  }
  for (int i = 0; i < 360; i+=1)
  {
    rays.add(new ray(width/2, height/2, radians(i)));
  }
}

void draw() {
  hit h;
  background(30);
  
  for (boundary wall : walls) {
    wall.show();
  }
  
  stroke(180,100);
  for (ray r : rays) {
    h = r.multicast(walls);
    if (h != null){
      stroke(180,200);
      line(h.p.x, h.p.y, width/2, height/2);
      stroke(180,20,20,100);
      PVector B = PVector.sub(r.dir, PVector.mult(h.b.normal, PVector.dot(r.dir, h.b.normal)*2));
      line(h.p.x,h.p.y,h.p.x+B.x*100,h.p.y+B.y*100);
      //println(degrees(PVector.angleBetween(r.dir,h.b.normal)));
      /*PVector ref = r.dir.sub(h.b.normal.mult(2 * r.dir.dot(h.b.normal)));
      println(ref);
      if(ref.x>-1000){
        line(h.p.x,h.p.y,h.p.x+ref.x*10,h.p.y+ref.y*10);}*/
    }
  }
  //ellipse(width/2,height/2,20,20);
}
