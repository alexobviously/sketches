// made by alex
// iamalexbaker@gmail.com

class unit{
  PVector pos;
  color col;
  PVector size;
  float mass;
  unit base;
  float roof;
  ArrayList<unit> children = new ArrayList<unit>();
  boolean dead = false;
  ArrayList<unit> parentArray;
  boolean newBase = false;
  
  unit(PVector p, color c, PVector s, float m, unit b, ArrayList<unit> pa){
    pos = p; col = c; size = s; mass = m; base = b; parentArray = pa;
    if(b == null){
      roof = -size.y;
      if(mass < 0) newBase = true;
    }
    else{
      roof = b.roof;
    }
  }
  
  void update(float xp, float zp){
    //println(pos);
    pushMatrix();
    translate(pos.x + xp,pos.y,pos.z + zp);
    if(!dead){
      fill(col, 100);
      box(size.x, size.y, size.z);
    }
    popMatrix();
    if(mass > 0){
      pos.y += mass;
      if(pos.y >= base.roof){
        pos.y = base.roof;
        base.roof -= size.y;
        base.children.add(this);
        mass = 0;
        if(base.children.size() >= maxChildren) base.release();
      }
    if(base != null){
      if(base.mass < 0){
        mass = -gravity;
      }
    }
    }
    if(mass < 0){
        pos.y += mass;
        if(newBase && pos.y <= 0){
          newBase = false;
          pos.y = 0;
          mass = 0;
        }
        if(pos.y < deathCeiling){
          dead = true;
          //parentArray.remove(this);
        }
      }
  }
  
  void release(){
    //println("release "+children.size());
    //println("contains "+bases.contains(this));
    for(int i = children.size() - 1; i >= 0; i--){
      children.get(i).mass = -((i+2)*0.8)*gravity;
      //println("child "+base.children.get(i).mass);
    }
    mass = -gravity;
  }
}

// -----------
// PARAMETERS
// -----------
float uw = 50;
float ul = 40;
int rows = 20;
float xpan = -200;
float zpan = -500;
float gravity = 2;
float dropsPerSecond = 128;
float spawnHeight = -500;
int maxChildren = 7;
float deathCeiling = -700;
float panRate = 1.5;
float fullness = 12;
float colourVariance = 4;
float colourDepth = 0.2;
color bgc = color(230);
// -----------

ArrayList<unit> bases = new ArrayList<unit>();
ArrayList<unit> units = new ArrayList<unit>();
PVector shape;
float timer = 0;
float dropTime = 100000;
ArrayList<unit> toRemove = new ArrayList<unit>();
float columnX;
color[] col = new color[2];
int maxUnits = 1;

void setup(){
  size(800,800, P3D);
  
  shape = new PVector(random(80,120),random(2,10),random(80,120));
  timer = 0;
  dropTime = frameRate/dropsPerSecond;
  stroke(0);
  strokeWeight(3);
  //noStroke();
  //noFill();
  units.clear();
  bases.clear();
  maxUnits = 1;
  for(int cc = 0; cc < col.length; cc++) col[cc] = dullColour(200,0,255);
  float xp = 0;
  float zp = 0;
  
  for(int i = 0; i < 200; i++){
    //println(xp+" "+zp);
    bases.add(new unit(new PVector(xp, -spawnHeight, zp), lerpColor(col[0],col[1],random(1)), shape, -random(gravity,gravity*2), null, bases));
    zp += shape.z;
    if(i%rows == rows-1){
      zp -= shape.z * rows;
      xp += shape.x;
    }
  }
  columnX = xp;
}

void draw(){
  background(bgc);
  do{
    timer -= dropTime;
    newdrop();
  }while(timer > dropTime);
  translate(width/2,width/2,100);
  rotateY(0.3);
  rotateX(-PI/4);
  rotateZ(PI/16);
  toRemove.clear();
  for(unit u: bases){
    u.update(xpan, zpan);
    if(u.dead || u.pos.x<xpan-width) toRemove.add(u);
  }
  bases.removeAll(toRemove);
  toRemove.clear();
  for(unit u: units){
    u.update(xpan, zpan);
    if(u.dead || u.pos.x<xpan-width) toRemove.add(u);
  }
  units.removeAll(toRemove);
  int n = bases.size();
  float rateMult = 1 / (n / (rows*fullness));
  float rm2 = pow((columnX - (-xpan))/width, 2);
  if(units.size()>maxUnits) maxUnits = units.size();
  if(float(units.size())/maxUnits<0.5) maxUnits--;
  if(maxUnits==0) maxUnits = 1;
  println(bases.size()+" "+units.size()+" "+rateMult+" "+rm2+" "+(float(units.size())/maxUnits));
  xpan -= panRate * rm2;
  timer += 1;
  if(random(1000)>=(999-(rateMult*10))){
    newColumn(pow(float(units.size())/maxUnits,colourVariance));
  }
}

void newColumn(float cLevel){
  for(int i = 0; i < rows; i++){
    float colour = constrain(cLevel + (float(i)/rows)*colourDepth - colourDepth/2, 0.0, 1.0);;
    bases.add(new unit(new PVector(columnX, -spawnHeight, shape.z * i), lerpColor(col[0],col[1],colour), shape, -random(gravity,gravity*2), null, bases));
  }
  columnX += shape.x;
}

void newdrop(){
  unit b = bases.get(int(random(bases.size())));
  if(b.children.size()>=maxChildren) return;
  PVector spawnPos = new PVector(b.pos.x, spawnHeight, b.pos.z);
  unit u = new unit(spawnPos, b.col, shape, gravity, b, units);
  units.add(u);
}

color dullColour(float spread, float min, float max)
{
  color col;
  float x = random(min, max);
  col = color(constrain(x + random(spread) - spread/2, 0, 255), constrain(x + random(spread) - spread/2, 0, 255), constrain(x + random(spread) - spread/2, 0, 255));
  return col;
}

void keyPressed()
{
  if (keyCode==32) {
    saveFrame("city-"+hour()+"-"+minute()+"-"+second()+".png");
  }
  if (keyCode==10) {
    setup();
  }
}
