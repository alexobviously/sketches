//
//
//

float[] windRange = {-.5, 0.5};
float[] wind = {0., 0.};
boolean randomWind = true;
boolean boundaries = true;
boolean onlyRenderPaired = true;
float prox = 10;
ArrayList<particle> paired;
ArrayList<particle> unpaired;
ArrayList<particle> particles;
ArrayList<PVector> traces;
int numParticles = 150;
float[] initialImpulse = {-2., 2.0, 0};
int staticTicks = 1500;
int realTimeTicks = 1;
int numTicks = 0;
boolean realTime = false;
float alpha = 150;
int currentTick = 0;
float particleSize = 1;
boolean do_draw = true;
int aloneTime = 300;
boolean debug = false;
float turnRate = 0.05;

color bgc;
int nc = 2;
color[] c = new color[nc];
float[] hueRange = {0, TWO_PI};
float[] satRange = {0., 1.0};
float[] briRange = {0.4, 1.};

void setup(){
  size(800, 800);
  noStroke();
  smooth(8);
  colorMode(HSB, TWO_PI, 1, 1);
  bgc = color(0, 0, 0.2);
  background(bgc);
  for(int i = 0; i < nc; i++){
    c[i] = color(random(hueRange[0], hueRange[1]), random(satRange[0], satRange[1]), random(briRange[0], briRange[1]));
  }
  
  do_draw = true;
  currentTick = 0;
  paired = new ArrayList<particle>();
  unpaired = new ArrayList<particle>();
  particles = new ArrayList<particle>();
  traces = new ArrayList<PVector>();
  for(int i = 0; i < numParticles; i++){
    particle p = new particle(random(width),random(height),random(initialImpulse[0],initialImpulse[1]),random(initialImpulse[0],initialImpulse[1]));
    particles.add(p);
    unpaired.add(p);
  }
  
  if(randomWind){
    wind[0] = random(windRange[0], windRange[1]);
    wind[1] = random(windRange[0], windRange[1]);
  }
  println(wind[0]+" "+wind[1]);
}

void draw(){
  if(realTime){
    background(bgc);
    traces = new ArrayList<PVector>();
    numTicks = realTimeTicks;
    do_draw = true;
  } else numTicks = staticTicks;
  if(!do_draw) return;
  for(int k = 0; k < numTicks; k++){
    for(particle p: particles){
      p.tick();
    }
    currentTick++;
  }
  for(PVector t: traces){
    fill(lerpColor(c[0], c[1], t.z), alpha);
    ellipse(t.x, t.y, particleSize, particleSize);
  }
  do_draw = false;
}

particle find_partner(particle A){
  if(unpaired.size() < 2) return null;
  for(particle p: unpaired){
    if(A == p) continue;
    if(A.lastPartner == p) continue;
    return p;
  }
  return null;
}

void pair(particle A, particle B){
  unpaired.remove(A);
  unpaired.remove(B);
  paired.add(A);
  paired.add(B);
  A.partner = B;
  B.partner = A;
}

void unpair(particle A){
  particle B = A.partner;
  A.lastPartner = B;
  A.partner = null;
  B.lastPartner = A;
  B.partner = null;
  paired.remove(A);
  paired.remove(B);
  A.aloneTimer = aloneTime;
  B.aloneTimer = aloneTime;
  //unpaired.add(A);
  //unpaired.add(B);
}

void add_to_unpaired(particle A){
  unpaired.add(A);
}

class particle{
  PVector pos, vel;
  int aloneTimer = 0;
  particle partner, lastPartner;
  particle(float x, float y, float fx, float fy){
    pos = new PVector(x,y); vel = new PVector(fx, fy);
  }
  void tick(){
    if(partner == null && aloneTimer <= 0){
      particle p = find_partner(this);
      if(p != null) pair(this, p);
    }
    pos.x += vel.x + wind[0];
    pos.y += vel.y + wind[1];
    if(boundaries){
      if(pos.x < 0) vel.x = abs(vel.x);
      if(pos.x > width) vel.x = -abs(vel.x);
      if(pos.y < 0) vel.y = abs(vel.y);
      if(pos.y > height) vel.y = -abs(vel.y);
    }
    if(partner != null){
      PVector facing = new PVector(partner.pos.x - pos.x, partner.pos.y - pos.y).normalize();
      float velMag = vel.mag();
      vel.normalize();
      vel.lerp(facing, turnRate);
      vel.setMag(velMag);
      if(sqd(pos, partner.pos) <= prox*prox){
        unpair(this);
      }
    }
    else{
      if(aloneTimer <= 0){
        unpaired.add(this);
        aloneTimer = 0;
      }else{
        aloneTimer--;
      }
    }
    if(!onlyRenderPaired || partner != null){
      if(debug) traces.add(new PVector(pos.x, pos.y, float(aloneTimer)/aloneTime));
      else traces.add(new PVector(pos.x, pos.y, float(currentTick)/numTicks));
    }
  }
  void show(){
    stroke(c[0], 150);
    noFill();
    ellipse(pos.x, pos.y, 3, 3);
  }
}

float sqd(PVector a, PVector b){
  float dx = a.x - b.x;
  float dy = a.y - b.y;
  return dx*dx + dy*dy;
}

void keyPressed()
{
  if (keyCode==32) { // space
    String fn = "pair-"+hour()+"-"+minute()+"-"+second()+".png";
    saveFrame(fn);
    println("Saved image "+fn);
  }
  if (keyCode==10) { // enter
    setup();
    println("Initialising new state");
  }
}
