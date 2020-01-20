// made by alex
// iamalexbaker@gmail.com
// dailygenerative.art.blog

int len = 8;
int numLines = 80;
boolean realTime = false;

float[] hueRange = {0, TWO_PI};
float[] satRange = {0, 0.7};
float[] briRange = {0.4, 0.8};
float alpha = 255;
float strokeWeight = 1;
int nc = 3;
color[] c = new color[nc];
color bgc;
float hue, sat, bri;

PVector origin;
int generation = 0;
ArrayList<toothpick> picks;
ArrayList<toothpick> checkpicks;
boolean finished = false;

class toothpick{
  PVector a, b;
  int dir, gen, contacts;
  boolean is_new, activated;
  toothpick parent;
  toothpick(float x, float y, int d, int g, toothpick prnt){
    dir = d; is_new = true; gen = g; contacts = 0; parent = prnt;
    if(dir==1){//horiz
      a = new PVector(x - len/2, y);
      b = new PVector(x + len/2, y);
    }else{
      a = new PVector(x, y - len/2);
      b = new PVector(x, y + len/2);
    }
  }
  
  boolean intersects(PVector p){
    if( (a.x == p.x && a.y == p.y) || (b.x == p.x && b.y == p.y) ){
      contacts++;
      if(contacts==2) checkpicks.remove(this);
      return true;
    }
    else return false;
  }
  
  toothpick create(ArrayList<toothpick> others, int which_pt){
    PVector pt;
    if(which_pt == 0) pt = a;
    else pt = b;
    if(pt.x < 0 || pt.x > width || pt.y < 0 || pt.y > height){contacts++; return null;}
    for(toothpick other: others){
      if(other != this && other.intersects(pt)) return null;
    }
    return new toothpick(pt.x, pt.y, -dir, generation, this);
  }
  
  void show(){
    if(activated){
      stroke(c[2], alpha);
    } else {
      stroke(lerpColor(c[0], c[1], float(gen) / generation), alpha);
    }
    strokeWeight(strokeWeight);
    line(a.x, a.y, b.x, b.y);
  }
  
  void activateLine(){
    activated = true;
    if(parent != null) parent.activateLine();
  }
}

void setup(){
  size(800,800);
  colorMode(HSB, TWO_PI, 1, 1);
  bgc = color(0, 0, 0.2);
  finished = false;
  generation = 0;
  hue = random(hueRange[0], hueRange[1]);
  sat = random(satRange[0], satRange[1]) * TWO_PI;
  bri = random(briRange[0], briRange[1]) * TWO_PI;
  for(int i = 0; i < nc; i++){
    c[i] = color(random(hueRange[0], hueRange[1]), random(satRange[0], satRange[1]), random(briRange[0], briRange[1]));
  }
  origin = new PVector(int(random(width)), int(random(height)));
  picks = new ArrayList<toothpick>();
  checkpicks = new ArrayList<toothpick>();
  picks.add(new toothpick(origin.x, origin.y, (round(random(1))==0)?1:-1, generation, null));
  picks.add(new toothpick(origin.x + len*int(random(-30,30)), origin.y + len*int(random(-30,30)), 1, generation, null));
  
}

void draw(){
  background(bgc);
  if(realTime) tick();
  else{
    while(!finished){
      tick();
    }
    
  }
  for(toothpick t: picks){
    t.show();
  }
}

void tick(){
  generation++;
  
  ArrayList<toothpick> next = new ArrayList<toothpick>();
  for(toothpick t: picks){
    //t.show();
    if(t.is_new){
      toothpick na = t.create(checkpicks, 0);
      toothpick nb = t.create(checkpicks, 1);
      if(na != null) next.add(na);
      if(nb != null) next.add(nb);
      t.is_new = false;
    }
  }
  picks.addAll(next);
  checkpicks.addAll(next);
  if(next.size() == 0){ println("end "+generation); finished = true; }
  else{ println("gen: "+generation+", picks: "+picks.size()+", check: "+checkpicks.size());}
  if(finished){
      for(int i = 0; i < numLines; i++){
        picks.get(int(random(picks.size()))).activateLine();
      }
    }
}

void keyPressed()
{
  if (keyCode==32) { // space
    String fn = "tp-"+hour()+"-"+minute()+"-"+second()+".png";
    saveFrame(fn);
    println("Saved image "+fn);
  }
  if (keyCode==10) { // enter
    setup();
    println("Initialising new state");
  }
}
