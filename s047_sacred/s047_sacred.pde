// made by alex
// iamalexbaker@gmail.com
// dailygenerative.art.blog

polygon poly;

float angle = PI;
float delta = 4;
float inc = 100;
float time1 = 3;
float time2 = 2;
float fr = 30;
float shape = 4;


float total = time1 * time2;
float phase = 0;
float phase2 = 0;
float p1, p2, timer;
int idx = 0;

boolean rec = false;

void setup(){
  size(800, 800);
  background(30);
  smooth(8);
  frameRate(fr);
  strokeWeight(1);
  println(frameRate);
  p1 = TWO_PI / (time1 * fr);
  p2 = TWO_PI / (time2 * fr);
  rec = false;
}

void draw(){
  background(30);
  for(float x = 0; x < width; x += inc){
    for(float y = 0; y < width; y += inc){
      square(x, y, inc);
    }
  }
  phase += p1;
  if(phase >= TWO_PI) phase = 0;
  angle = sin(phase) * PI/2 + PI/2 + PI/128;
  phase2 += p2;
  if(phase2 >= TWO_PI) phase2 = 0;
  delta = sin(phase2) * 10 + 11;
  //println(((angle%TWO_PI)/PI)+" "+delta);
  if(rec){
    saveFrame("fr-"+nf(idx, 4)+".png");
    idx++;
    println(timer);
    timer += 1 / fr;
    if(timer >= total){
      timer = 0;
      rec = false;
    }
  }
}

void square(float x, float y, float w){
  poly = new polygon();
  poly.addVertex(x, y);
  poly.addVertex(x+w, y);
  poly.addVertex(x+w, y+w);
  poly.addVertex(x, y+w);
  poly.close();
  poly.show();
}

class polygon{
  ArrayList<PVector> vertices;
  ArrayList<edge> edges;
  
  polygon(){
    vertices = new ArrayList<PVector>();
    edges = new ArrayList<edge>();
  }
  
  void addVertex(float x, float y){
    PVector a = new PVector(x, y);
    
    if(vertices.size() > 0){
      PVector prev = vertices.get(vertices.size()-1);
      edge e = new edge(prev, a, this);
      edges.add(e);
    }
    vertices.add(a);
  }
  
  void close(){
    edge e = new edge(vertices.get(vertices.size()-1), vertices.get(0), this);
    edges.add(e);
  }
  
  void show(){
    for(edge e: edges){
      e.show();
    }
  }
}

class edge{
  PVector a, b;
  hankin h1, h2;
  polygon parent;
  edge(PVector aa, PVector bb, polygon par){
    a = aa; b = bb; parent = par;
    hankin();
  }
  
  void hankin(){
    PVector mid = PVector.add(a, b);
    mid.mult(0.5);
    PVector v1 = PVector.sub(a, mid).setMag(delta);
    PVector v2 = PVector.sub(b, mid).setMag(delta);
    
    float elen = v1.mag() + delta;
    
    PVector off1 = PVector.sub(mid, v1);
    PVector off2 = PVector.sub(mid, v2);
    
    v1.normalize();
    v2.normalize();
    
    v1.rotate(-angle);
    v2.rotate(angle);
    
    float interior = ((shape - 2) * PI) / shape;
    float alpha = interior * 0.5;
    float beta = (PI - angle) - alpha;
    float hlen = (elen * sin(alpha)) / sin(beta);
    
    v1.setMag(hlen);
    v2.setMag(hlen);
    
    h1 = new hankin(off1, v1, this);
    h2 = new hankin(off2, v2, this);
  }
  
  void show(){
    stroke(255);
    //line(a.x, a.y, b.x, b.y);
    //h1.findEnd(parent);
    //h2.findEnd(parent);
    h1.show();
    h2.show();
    //ellipse(h1.end.x, h1.end.y, 5, 5);
  }
}

class hankin{
  PVector a, b, v, end;
  edge parent;
  hankin(PVector aa, PVector vv, edge par){
    a = aa; v = vv; parent = par;
    b = PVector.add(a, v);
  }
  
  PVector intersect(hankin h){
    float den = (h.v.y * v.x) - (h.v.x * v.y);
    float ua = ((h.v.x * ((a.y - h.a.y)) - (h.v.y *  (a.x - h.a.x)))) / den;
    float ub = ((v.x * ((a.y - h.a.y)) - (v.y *  (a.x - h.a.x)))) / den;
    float x = a.x + ua * v.x;
    float y = a.y + ua * v.y;
    if(ua > 0 && ub > 0)
      return new PVector(x, y);
     else return null;
  }
  
  void findEnd(polygon p){
    ArrayList<hankin> hankins = new ArrayList<hankin>();
    for(edge e: p.edges){
      if(e == parent) continue;
       hankins.add(e.h1);
       hankins.add(e.h2);
    }
    float record = Float.POSITIVE_INFINITY;
    PVector best = a;
    for(hankin h: hankins){
      PVector inter = intersect(h);
      if(inter == null) continue;
      float d1 = inter.dist(a);
      float d2 = inter.dist(h.a);
      if(abs(d1-d2) > 0.01) continue;
      float d = d1 + d2;
      if(d < record){
        record = d;
        best = inter;
      }
    }
    end = best;
  }
  
  void show(){
    stroke(map(a.x, 0, width, 0 , 255), map(a.y, 0, width, 0, 255), map(a.y, 0, width, 255, 0));
    //line(a.x, a.y, b.x, b.y);
    line(a.x, a.y, b.x, b.y);
  }
}

void keyPressed()
{
  if (keyCode==32) { // space - start recording
    if(!rec){
      rec = true;
      idx = 0;
      timer = 0;
    }
  }
}
