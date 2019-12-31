// made by alex
// iamalexbaker@gmail.com
// dailygenerative.art.blog

ArrayList<particle> particles;
ArrayList<zone> zones;
ArrayList<PVector> traces;

float drag = 0.995; // set to 1 for no drag
float gravity = 0;
float powerRange = 0.02; // for zones
float[] sizeRange = {50, 100}; // for zones
float circleRadius = 100;
float circleAngle = PI/128;
float[] initialImpulse = {0.01, 0.02, 0};
boolean randomImpulses = true; // if true, each particle has a different starting velocity
float startDirection = 1; // +1: fly away from circle, -1: fly into it
int numParticles = 2000;
int numZones = 200;
int numTicks = 1000;
int currentTick = 0;

boolean showZones = false;
boolean do_draw = true;

float[] hueRange = {0, TWO_PI};
float[] satRange = {0, 0.7};
float[] briRange = {0, 0.9};
float alpha = 10;
int nc = 2;
color[] c = new color[nc];
color bgc;
float hue, sat, bri;

void setup(){
  size(800, 800);
  colorMode(HSB, TWO_PI, 1, 1);
  bgc = color(0, 0, 0.2);
  background(bgc);
  hue = random(hueRange[0], hueRange[1]);
  sat = random(satRange[0], satRange[1]) * TWO_PI;
  bri = random(briRange[0], briRange[1]) * TWO_PI;
  for(int i = 0; i < nc; i++){
    c[i] = color(random(hueRange[0], hueRange[1]), random(satRange[0], satRange[1]) * TWO_PI, random(briRange[0], briRange[1]) * TWO_PI);
  }
  
  currentTick = 0;
  initialImpulse[2] = random(initialImpulse[0], initialImpulse[1]);
  particles = new ArrayList<particle>();
  zones = new ArrayList<zone>();
  traces = new ArrayList<PVector>();
  PVector origin = new PVector(width/2, height/2);
  for(int i = 0; i < numParticles; i++){
    float r = circleAngle * i;
    float xp = circleRadius * cos(r);
    float yp = circleRadius * sin(r);
    if(randomImpulses) initialImpulse[2] = random(initialImpulse[0], initialImpulse[1]);
    particles.add(new particle(origin.x+xp, origin.y+yp, xp * initialImpulse[2] * startDirection, yp * initialImpulse[2] * startDirection));
  }
  for(int j = 0; j < numZones; j++){
    zones.add(new zone(random(width),random(height),random(-powerRange/2,powerRange/2),random(-powerRange/2,powerRange/2),random(sizeRange[0], sizeRange[1])));
  }
  do_draw = true;
  
}

void draw(){
  if(!do_draw) return;
  for(int k = 0; k < numTicks; k++){
    for(zone z: zones){
      z.tick();
    }
    for(particle p: particles){
      p.tick();
      //p.show();
    }
    currentTick++;
  }
  noStroke();
  //ellipse(400,400,200,200);
  //println(traces.size());
  for(PVector t: traces){
    fill(lerpColor(c[0], c[1], t.z), alpha);
    ellipse(t.x, t.y, 3, 3);
  }
  do_draw = false;
}

class particle{
  PVector pos, vel;
  
  particle(float x, float y, float vx, float vy){
    pos = new PVector(x, y); vel = new PVector(vx, vy);
  }
  
  void tick(){
    pos.x += vel.x;
    pos.y += vel.y + gravity;
    if(pos.x < 0 || pos.x > width) vel.x = -vel.x;
    if(pos.y < 0 || pos.y > height) vel.y = -vel.y;
    vel.mult(drag);
    traces.add(new PVector(pos.x, pos.y, float(currentTick)/numTicks));
  }
  
  void show(){
    stroke(50, 150);
    noFill();
    ellipse(pos.x, pos.y, 3, 3);
  }
}

class zone{
  PVector pos, force;
  float radius;
  zone(float x, float y, float fx, float fy, float r){
    pos = new PVector(x, y); force = new PVector(fx, fy); radius = r;
  }
  
  void tick(){
    pushParticles();
  }
  
  void show(){
    stroke(50, 100);
    line(pos.x, pos.y, pos.x + force.x*500, pos.y + force.y * 500);
    fill(50,80,200, 50);
    noStroke();
    ellipse(pos.x, pos.y, radius/2, radius/2);
    
  }
  
  void pushParticles(){
    for(particle p: particles){
      if(pos.dist(p.pos)<=radius){
        p.vel.add(force);
      }
    }
  }
}

void keyPressed()
{
  if (keyCode==32) { // space
    saveFrame("p-"+hour()+"-"+minute()+"-"+second()+".png");
  }
  if (keyCode==10) { // enter
    setup();
  }
  if(keyCode==90) { // Z
    showZones = !showZones;
  }
}
