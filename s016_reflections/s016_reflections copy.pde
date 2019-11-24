class boundary {
  PVector a, b;

  boundary(float x1, float y1, float x2, float y2) {
    a = new PVector(x1, y1);
    b = new PVector(x2, y2);
  }

  void update() {
    stroke(255);
    line(a.x, a.y, b.x, b.y);
  }
}

class ray {
  PVector pos, dir;
  ray(float x, float y) {
    pos = new PVector(x, y);
    dir = new PVector(1, 0);
  }
  void update() {
    stroke(255);
    push();
    translate(pos.x, pos.y);
    line(0, 0, dir.x*10, dir.y*10);
    pop();
  }
  
  PVector cast(boundary b){
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
    if(d==0) return null;
    
    t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / d;
    u = - ((x1 - x2) * (y1 - y3) - (y1 - y2) * (x1 - x3)) / d;
    
    if(t > 0 && t < 1 && u > 0){
      hx = x1 + t * (x2-x1);
      hy = y1 + t * (y2-y1);
      return new PVector(hx,hy);
    }
    else return null;
  }
  void lookAt(float x, float y){
    dir.x = x - pos.x;
    dir.y = y - pos.y;
    dir.normalize();
  }
}

boundary bb;
ray r;

void setup() {
  size(600, 600);
  bb = new boundary(300, 100, 300, 300);
  r = new ray(100, 200);
}

void draw() {
  background(30);
  bb.update();
  r.lookAt(mouseX,mouseY);
  r.update();
  PVector h = r.cast(bb);
  if(h != null) ellipse(h.x,h.y,8,8);
}
