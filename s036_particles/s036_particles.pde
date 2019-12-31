ArrayList<particle> particles;
ArrayList<zone> zones;

float drag = 0.99;
float gravity = 0;

boolean showZones = false;

void setup(){
  size(800, 800);
  background(230);
  noFill();
  stroke(50);
  particles = new ArrayList<particle>();
  zones = new ArrayList<zone>();
  PVector origin = new PVector(random(width),random(height));
  for(int i = 0; i < 5000; i++){
    particles.add(new particle(origin.x,origin.y,random(-2,2),random(-2,2)));
  }
  for(int j = 0; j < 50; j++){
    zones.add(new zone(random(width),random(height),random(-0.05,0.05),random(-0.05,0.05),random(50)+100));
  }
}

void draw(){
  background(230);
  for(zone z: zones){
    z.tick();
    if(showZones) z.show();
  }
  for(particle p: particles){
    p.tick();
    p.show();
  }
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
