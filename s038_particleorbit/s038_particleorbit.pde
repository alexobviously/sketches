// made by alex
// iamalexbaker@gmail.com
// dailygenerative.art.blog

// KEY COMMANDS
// ENTER - Start everything again (new setup)
// Space - save screenshot
// Z     - show zones/planets (for debugging)
// F     - freeze all particles
// P     - enable/disable planets
// A     - give all particles a velocity boost
// T     - enable/disable real time mode
// R     - make all particles return to centre
// V     - manually toggle recording
// X     - enable/disable smart recording - if this is on, recording will auto start with you press enter and auto start when particles return

import com.hamoid.*; // using Video Export library
boolean recording = false;
VideoExport videoExport;
boolean smartRecording = false;

// System State
float drag = 1;//0.999; // set to 1 for no drag
float[] wind = {0.05, 0.1}; // formerly gravity
boolean randomWind = true;
float circleRadius = 200;
float[] endRadius = {200, 250, 0};
float circleAngle = PI/128;
int initialiseMode = 3; // 0: random, 1: circle, 2: polar rose, 3: n-gon
int endMode = 3; // -1: return to start pos, 0: random, 1: circle, 2: polar rose, 3: n-gon
float startDirection = -1; // +1: fly away from circle, -1: fly into it
float shape = 6;
float endShape = 6;
float systemPull = 1.3;
int systemPullMode = 2; // 0 to drag into centre or 2 to pull into orbit
float systemCentre = 1.0;
boolean boundaries = false; // stop things going off the edge of the screen

// Visual Settings
boolean realTime = false;
int numTicks = 1000;
int staticTicks = 1000;
int realTimeTicks = 3;
boolean realTimeColour = true;
float[] hueRange = {0, TWO_PI};
float[] satRange = {0., 1.0};
float[] briRange = {0., .6};
float alpha = 15;
float particleSize = 1;

// Particle Options
int numParticles = 5000;
float returnTurnRate = 0.2;
float returnAccel = 1.0008;
float returnSnapDistance = 5;
int returnAfterTicks = 300; // for static-time, returns to position after this many ticks *SET TO ZERO FOR NORMAL BEHAVIOUR*
boolean stopAfterReturn = true; // stops rendering new ticks after all particles have returned (using tolerance)
float returnTolerance = 0.9;
boolean dontRenderAfterReturn = true;
boolean dissipate = false; // this doesn't really work as intended, I was trying to reacreate a cool looking bug
float freezeRate = 0.05;
float accelAmt = 1.1;
boolean particlesAttract = true;
float[] particleMass = {0.01, .05}; // for attraction
float[] particleAttractRadius = {5, 20};
int particleAttractMode = 0; // 0: attract, 1: repel, 2: orbit
int particleAttractDelay = 50; // in ticks

// Zone/Planet Options
int numZones = 50;
int numPlanets = 5;
float powerRange = 0.02; // for zones
float[] sizeRange = {100, 400}; // for zones/planets
float[] planetMass = {1.0, 2.5};
float[] zoneStrength = {0.01, 0.1};

float[] initialImpulse = {0.001, 0.01, 0}; // good range: 0.01 - 0.035
boolean randomImpulses = false; // if true, each particle has a different starting velocity - false will give a smooth effect and true will make it 'hairy'

float[] startAngle = {0, TWO_PI, 0};
float[] endStartAngle = {-PI/4, PI/4, 0}; // this is added to start angle, so set it to 0, 0 to sync the two shapes



boolean showZones = false;
boolean do_draw = true;

boolean clearScreen = true; // if true, clears the screen each time the system is reset (press enter). (non realtime mode only)


int nc = 2;
color[] c = new color[nc];
color bgc;
float hue, sat, bri;

ArrayList<particle> particles;
ArrayList<zone> zones;
ArrayList<planet> planets;
ArrayList<PVector> traces;
int currentTick, currentTickRT;
boolean returning, frozen = false;
boolean enablePlanets = true;
boolean particlesAttracting = false;

boolean initialised = false;

void setup(){
  size(800, 800, P2D);
  smooth(8);
  if(!initialised){
    videoExport = new VideoExport(this);
    videoExport.setDebugging(false);
    
    colorMode(HSB, TWO_PI, 1, 1);
    bgc = color(0, 0, 0.8);
    background(bgc);
    initialised = true;
  }
  
  if(clearScreen) background(bgc);
  
  hue = random(hueRange[0], hueRange[1]);
  sat = random(satRange[0], satRange[1]);
  bri = random(briRange[0], briRange[1]);
  for(int i = 0; i < nc; i++){
    c[i] = color(random(hueRange[0], hueRange[1]), random(satRange[0], satRange[1]), random(briRange[0], briRange[1]));
  }
  
  currentTick = 0;
  returning = false;
  frozen = false;
  particlesAttracting = (particlesAttract && particleAttractDelay == 0)?true:false;
  initialImpulse[2] = random(initialImpulse[0], initialImpulse[1]);
  startAngle[2] = random(startAngle[0], startAngle[1]);
  endStartAngle[2] = startAngle[2] + random(endStartAngle[0], endStartAngle[1]);
  endRadius[2] = random(endRadius[0], endRadius[1]);
  wind[0] = random(-wind[0], wind[0]); // actually this is wrong!
  wind[1] = random(-wind[1], wind[1]); // didn't realise
  particles = new ArrayList<particle>();
  zones = new ArrayList<zone>();
  planets = new ArrayList<planet>();
  traces = new ArrayList<PVector>();
  PVector origin = new PVector(width/2, height/2);
  
  float bigt = TWO_PI / shape;
  float crd2 = sin(bigt / 2);
  float bigtE = TWO_PI / endShape;
  float crd2E = sin(bigtE / 2);
  float n = TWO_PI / numParticles;
  circleAngle = n;
  
  for(int i = 0; i < numParticles; i++){
    float xp, yp, xi, yi, xt, yt, r, xx, yy, t, tt;
    switch(initialiseMode){
      default:
      case 0: // random
        xp = random(width);
        yp = random(height);
        PVector force = PVector.random2D().mult(initialImpulse[2]);
        xi = force.x * 50;
        yi = force.y * 50;
        break;
      case 1: //circle
        r = startAngle[2] + circleAngle * i;
        xx = circleRadius * cos(r);
        yy = circleRadius * sin(r);
        xp = origin.x + xx;
        yp = origin.y + yy;
        xi = xx * initialImpulse[2] * startDirection;
        yi = yy * initialImpulse[2] * startDirection;
        break;
      case 2: // polar rose
        t = startAngle[2] + n * i;
        r = cos(shape * t) * circleRadius;
        xx = r * cos(t);
        yy = r * sin(t);
        xp = origin.x + xx;
        yp = origin.y + yy;
        xi = xx * initialImpulse[2] * startDirection;
        yi = yy * initialImpulse[2] * startDirection;
        break;
      case 3: // n-gon
        t = startAngle[2] + n * i;
        tt = (startAngle[2] + t) % bigt;
        r = crd2 / (tan(abs(bigt/2)) * cos(abs(bigt/2 - tt)));
        xx = circleRadius * r * cos(t);
        yy = circleRadius * r * sin(t);
        xp = origin.x + xx;
        yp = origin.y + yy;
        xi = xx * initialImpulse[2] * startDirection;
        yi = yy * initialImpulse[2] * startDirection;
        break;
    }
    switch(endMode){
      default:
      case -1:
        xt = xp;
        yt = yp;
        break;
      case 0:
        xt = random(width);
        yt = random(height);
        break;
      case 1: // circle
        r = endStartAngle[2] + circleAngle * i;
        xx = endRadius[2] * cos(r);
        yy = endRadius[2] * sin(r);
        xt = origin.x + xx;
        yt = origin.y + yy;
        break;
      case 2: // polar rose
        t = endStartAngle[2] + n * i;
        r = cos(endShape * t) * endRadius[2];
        xx = r * cos(t);
        yy = r * sin(t);
        xt = origin.x + xx;
        yt = origin.y + yy;
        break;
      case 3: // n-gon
        t = endStartAngle[2] + n * i;
        tt = (endStartAngle[2] + t) % bigtE;
        r = crd2E / (tan(abs(bigtE/2)) * cos(abs(bigtE/2 - tt)));
        xx = endRadius[2] * r * cos(t);
        yy = endRadius[2] * r * sin(t);
        xt = origin.x + xx;
        yt = origin.y + yy;
        break;
    }
    if(randomImpulses) initialImpulse[2] = random(initialImpulse[0], initialImpulse[1]);
    particles.add(new particle(xp, yp, xi, yi, xt, yt, particlesAttract, random(particleMass[0], particleMass[1]), particleAttractMode, random(particleAttractRadius[0], particleAttractRadius[1])));
  }
  
  if(systemCentre > 0) planets.add(new planet(origin.x, origin.y, systemCentre, 5, 1));
  if(systemPull > 0) planets.add(new planet(origin.x, origin.y, width, systemPull, systemPullMode));
  for(int j = 0; j < numPlanets; j++){
    planets.add(new planet(random(width),random(height),random(sizeRange[0], sizeRange[1]),random(planetMass[0], planetMass[1]),2));
  }
  for(int k = 0; k < numZones; k++){
    zones.add(new zone(random(width),random(height),random(-powerRange/2,powerRange/2),random(-powerRange/2,powerRange/2),random(sizeRange[0], sizeRange[1]),true, random(zoneStrength[0], zoneStrength[1])));
  }
  do_draw = true;
  
  if(smartRecording && !recording) setRecording(true); 
}

void draw(){
  if(realTime){
    background(bgc);
    traces = new ArrayList<PVector>();
    numTicks = realTimeTicks;
    if(!realTimeColour) currentTick = 0;
    do_draw = true;
  } else numTicks = staticTicks;
  if(!do_draw) return;
  for(int k = 0; k < numTicks; k++){
    if(returnAfterTicks > 0 && currentTick == returnAfterTicks){
      returning = true;
      startReturn();
    }
    if(!particlesAttracting && currentTick == particleAttractDelay && particlesAttract) particlesAttracting = true;
    if(enablePlanets){
      for(planet pl: planets){
        pl.tick();
        if(showZones) pl.show();
      }
      for(zone z: zones){
        z.tick();
        if(showZones) z.show();
      }
    }
    for(particle p: particles){
      p.tick();
    }
    if(k % 50 == 0 && !realTime){
      println(k+" / "+numTicks+" ticks calculated...");
    }
    if(!realTime && returning && stopAfterReturn){
      int h = 0;
      for(particle p: particles){
        if(p.home) h++;
      }
      if(h >= particles.size() * returnTolerance){
        if(!realTime) println("Stopped returning after "+k+" ticks.");
        k = numTicks;
      }
    }
    currentTick++;
  }
  noStroke();
  //ellipse(400,400,200,200);
  //println(traces.size());
  if(!realTime) println("Rendering "+traces.size()+" traces..");
  for(PVector t: traces){
    fill(lerpColor(c[0], c[1], t.z), alpha);
    ellipse(t.x, t.y, particleSize, particleSize);
  }
  do_draw = false;
  
  if (recording) {
    videoExport.saveFrame();
  }
  
  if(returning && smartRecording && recording){
    int h = 0;
    for(particle p: particles){
      if(p.home) h++;
    }
    if(h >= particles.size()) setRecording(false);
  }
}

class particle{
  PVector initial, pos, vel;
  boolean home, attract;
  float radius, mass;
  int attractMode; // 0: black hole, 1: push away, 2: orbit
  
  particle(float x, float y, float vx, float vy, float tx, float ty, boolean a, float m, int am, float ar){
    pos = new PVector(x, y); initial = new PVector(tx, ty); vel = new PVector(vx, vy); home = false; radius = ar; attractMode = am; mass = m; attract = a;
  }
  
  void tick(){
    pos.x += vel.x + wind[1]; 
    pos.y += vel.y + wind[0];
    if(boundaries){
      if(pos.x < 0 || pos.x > width) vel.x = -vel.x;
      if(pos.y < 0 || pos.y > height) vel.y = -vel.y;
    }
    if(!returning) vel.mult(drag);
    else goHome();
    if(frozen) freeze();
    boolean render = true;
    if(!realTime && dontRenderAfterReturn && home) render = false;
    if(render) traces.add(new PVector(pos.x, pos.y, float(currentTick)/staticTicks));
    if(attract && particlesAttracting && !returning) attractParticles();
  }
  
  void goHome(){
    if(pos.dist(initial) > returnSnapDistance || dissipate){
      PVector rV = new PVector(initial.x - pos.x, initial.y - pos.y).normalize();
      float mag = vel.mag();
      vel.normalize();
      vel.lerp(rV, returnTurnRate);
      vel.setMag(mag*returnAccel);
      //drawVector(pos, vel, 5, #FF0000);
      //drawVector(pos, rV, 5, #FFFFFF);
    }
    if(pos.dist(initial) < returnSnapDistance){
      pos.x = initial.x;
      pos.y = initial.y;
      home = true;
    }
    
  }
  
  void freeze(){
    PVector rV = new PVector(0, 0);
    vel.lerp(rV, freezeRate);
  }
  
  void randomVelocity(){
    if(randomImpulses) initialImpulse[2] = random(initialImpulse[0], initialImpulse[1]);
    vel = PVector.random2D().mult(initialImpulse[2]*50);
  }
  void attractParticles(){
    for(particle p: particles){
      if(p == this) continue;
      float r2 = radius/2;
      if(sqd(pos, p.pos) <= r2*r2){ // more efficient than "pos.dist(p.pos) <= radius/2"
        PVector facingPlanet = new PVector(pos.x - p.pos.x , pos.y - p.pos.y).normalize();
        float velMag = p.vel.mag();
        p.vel.normalize();
        switch(attractMode){
          case 0:
            p.vel.lerp(facingPlanet, mass*0.1);
            break;
          case 1:
          facingPlanet.mult(-1);
            p.vel.lerp(facingPlanet, mass*0.1);
            break;
          case 2:
            PVector tangent = new PVector(facingPlanet.x, facingPlanet.y).rotate(PI/(2*mass));
            p.vel.lerp(tangent, mass*0.03);
            break;
        }
        p.vel.setMag(velMag);
      }
    }
  }
  
  void show(){
    stroke(50, 150);
    noFill();
    ellipse(pos.x, pos.y, particleSize, particleSize);
  }
}

class planet{
  PVector pos;
  float radius, mass;
  int mode; // 0: black hole, 1: push away, 2: orbit
  planet(float x, float y, float r, float m, int mm){
    pos = new PVector(x, y); radius = r; mass = m; mode = mm;
  }
  
  void tick(){
    attractParticles();
  }
    
  void show(){
    noStroke();
    fill(3*PI/2, 0.7, 0.7, 100);
    ellipse(pos.x, pos.y, radius/2, radius/2);
  }
  
  void attractParticles(){
    for(particle p: particles){
      float r2 = radius/2;
      if(sqd(pos, p.pos) <= r2*r2){
        PVector facingPlanet = new PVector(pos.x - p.pos.x , pos.y - p.pos.y).normalize();
        float velMag = p.vel.mag();
        p.vel.normalize();
        switch(mode){
          case 0:
            
            //stroke(0,0,1,100);
            //line(p.pos.x, p.pos.y, p.pos.x + p.vel.x*100, p.pos.y + p.vel.y*100);
            //stroke(PI/4,0.5,1,100);
            //line(p.pos.x, p.pos.y, p.pos.x + facingPlanet.x*100, p.pos.y + facingPlanet.y*100);
            p.vel.lerp(facingPlanet, mass*0.1);
            break;
          case 1:
          facingPlanet.mult(-1);
            p.vel.lerp(facingPlanet, mass*0.1);
            break;
          case 2:
            PVector tangent = new PVector(facingPlanet.x, facingPlanet.y).rotate(PI/(2*mass));
            //stroke(0,0,1,100);
            //line(p.pos.x, p.pos.y, p.pos.x + p.vel.x*50, p.pos.y + p.vel.y*50);
            //stroke(PI/4,0.9,1,100);
            //line(p.pos.x, p.pos.y, p.pos.x + tangent.x*50, p.pos.y + tangent.y*50);
            p.vel.lerp(tangent, mass*0.03);
            break;
        }
        p.vel.setMag(velMag);
      }
    }
  }
}

class zone{
  PVector pos, force;
  float radius;
  boolean mode; // false = apply force, true = lerp to direction
  float strength;
  zone(float x, float y, float fx, float fy, float r, boolean m, float s){
    pos = new PVector(x, y); force = new PVector(fx, fy); radius = r; mode = m; if(mode) force = PVector.random2D(); strength = s;
  }
  
  void tick(){
    pushParticles();
  }
  
  void show(){
    stroke(PI, 100);
    line(pos.x, pos.y, pos.x + force.x*500, pos.y + force.y * 500);
    fill(50,80,200, 50);
    noStroke();
    ellipse(pos.x, pos.y, radius/2, radius/2);
    
  }
  
  void pushParticles(){
    for(particle p: particles){
      float r2 = radius/2;
      if(sqd(pos, p.pos) <= r2*r2){
        if(mode){
          float mag = p.vel.mag();
          p.vel.normalize().lerp(force, strength).setMag(mag);
        }else{
          p.vel.add(force);
        }
      }
    }
  }
}

float sqd(PVector a, PVector b){
  float dx = a.x - b.x;
  float dy = a.y - b.y;
  return dx*dx + dy*dy;
}

void drawVector(PVector pt, PVector v, float m, color col){
  stroke(col);
  line(pt.x, pt.y, pt.x + v.x*m, pt.y + v.y*m);
}

void setRecording(boolean rec){
  recording = rec;
  if(recording == true){
    videoExport.setMovieFileName(hour()+"-"+minute()+"-"+second() + ".mp4");
    videoExport.startMovie();
    println("Started recording");
  }
  else{
    println("Finished recording");
    videoExport.endMovie();
  }
}

void startReturn(){
  if(!returning){
    for(particle p: particles){
      p.home = false;
    }
  }
}

void keyPressed()
{
  if (keyCode==32) { // space
    String fn = "pg-"+hour()+"-"+minute()+"-"+second()+".png";
    saveFrame(fn);
    println("Saved image "+fn);
  }
  if (keyCode==10) { // enter
    setup();
    println("Initialising new state");
  }
  if(keyCode==90) { // Z
    showZones = !showZones;
    println("Show Zones: "+showZones);
  }
  if(keyCode==82) { // R
    returning = !returning;
    println("Returning: "+returning);
    startReturn();
  }
  if(keyCode==70) { // F
    frozen = !frozen;
    println("Frozen: "+frozen);
    if(!frozen){
      initialImpulse[2] = random(initialImpulse[0], initialImpulse[1]);
      for(particle p: particles){
        p.randomVelocity();
      }
    }
  }
  if(keyCode==80) { // P
    enablePlanets = !enablePlanets;
    println("Enable planets: "+enablePlanets);
  }
  if(keyCode==65) { // A
    for(particle p: particles){
      p.vel.mult(accelAmt);
    }
  }
  if(keyCode==86){ // V
    setRecording(!recording);
  }
  if(keyCode==88){ // X
    smartRecording = !smartRecording;
    println("Smart Recording: "+smartRecording);
  }
  if(keyCode==84) // T
  {
    realTime = !realTime;
    println("Real Time Mode: "+realTime);
  }
}
