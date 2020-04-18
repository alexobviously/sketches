// made by alex
// iamalebaker@gmail.com
// dailygenerative.art.blog

boolean boundaries = true;
boolean demo = true;

color bgc;
color[] teamColour = new color[2];
PVector[] teamBase = new PVector[2];
Building[] teamBaseBuil = new Building[2];
ArrayList<ArrayList<Unit>> units;
ArrayList<Unit> removeUnits;
ArrayList<Building> buildings;
ArrayList<Building> removeBuildings;
ArrayList<Projectile> projectiles;
ArrayList<Projectile> removeProj;
ArrayList<Beam> beams;
ArrayList<Beam> removeBeams;
ArrayList<Pulse> pulses;
ArrayList<Pulse> removePulses;

enum unitType{
  none,
  fighter,
  sniper,
  swarm,
  shotgun,
  machinegun,
  bouncer,
  medic,
}

void setup(){
  size(1200,500);
  smooth(8);
  colorMode(HSB, TWO_PI, 1, 1);
  bgc = color(50);
  for(int i = 0; i < 2; i++){
    float h = random(TWO_PI);
    float s = random(0.7, 1.0);
    float b = 1;
    teamColour[i] = color(h,s,b);
  }
  teamBase[0] = new PVector(width/10, height/2);
  teamBase[1] = new PVector(9*width/10, height/2);
  units = new ArrayList<ArrayList<Unit>>();
  units.add(new ArrayList<Unit>());
  units.add(new ArrayList<Unit>());
  removeUnits = new ArrayList<Unit>();
  projectiles = new ArrayList<Projectile>();
  removeProj = new ArrayList<Projectile>();
  buildings = new ArrayList<Building>();
  removeBuildings = new ArrayList<Building>();
  beams = new ArrayList<Beam>();
  removeBeams = new ArrayList<Beam>();
  pulses = new ArrayList<Pulse>();
  removePulses = new ArrayList<Pulse>();
  teamBaseBuil[0] = new Building(0, teamBase[0], 50, 5000, 35, 325, 800, 4);
  teamBaseBuil[1] = new Building(1, teamBase[1], 50, 5000, 35, 325, 800, 4);
  buildings.add(teamBaseBuil[0]);
  buildings.add(teamBaseBuil[1]);
  buildings.add(new Building(0, new PVector(teamBase[0].x + 200, height/3), 20, 2500, 10, 180, 125, 2));
  buildings.add(new Building(0, new PVector(teamBase[0].x + 200, 2*height/3), 20, 2500, 10, 180, 125, 2));
  buildings.add(new Building(1, new PVector(teamBase[1].x - 200, height/3), 20, 2500, 10, 180, 125, 2));
  buildings.add(new Building(1, new PVector(teamBase[1].x - 200, 2*height/3), 20, 2500, 10, 180, 125, 2));
  buildings.add(new Building(0, new PVector(width/2, height/4), 15, 1500, 10, 180, 100, 2));
  buildings.add(new Building(1, new PVector(width/2, 3*height/4), 15, 1500, 10, 180, 100, 2));
}

void draw(){
  background(bgc);
  if(demo) demo_spawning();
  for(ArrayList<Unit> uu: units){
    for(Unit u: uu){
      u.tick();
      u.show();
    }
  }
  for(Building b: buildings){
    b.tick();
    b.show();
  }
  for(Projectile p: projectiles){
    p.tick();
    p.show();
  }
  for(Beam b: beams){
    b.tick();
    b.show();
  }
  for(Pulse p: pulses){
    p.tick();
    p.show();
  }
  
  for(Projectile p: removeProj){
    projectiles.remove(p);
  }
  removeProj.clear();
  for(Unit u: removeUnits){
    units.get(u.team).remove(u);
  }
  removeUnits.clear();
  for(Building b: removeBuildings){
    buildings.remove(b);
  }
  removeBuildings.clear();
  for(Beam b: removeBeams){
    beams.remove(b);
  }
  removeBeams.clear();
  for(Pulse p: removePulses){
    pulses.remove(p);
  }
  removePulses.clear();
  
  textSize(32);
  fill(teamColour[0]);
  textAlign(RIGHT, BOTTOM);
  text(units.get(0).size(), width/2 - 5, height-5);
  
  fill(teamColour[1]);
  textAlign(LEFT, BOTTOM);
  text(units.get(1).size(), width/2 + 5, height-5);
  
  strokeWeight(1);
  stroke(teamColour[0]);
  line(width/2, height-5, width/2 -40, height-5);
  stroke(teamColour[1]);
  line(width/2, height-5, width/2 +40, height-5);
  stroke(color(180));
  line(width/2 -40, height-3, width/2+40, height-3);
}

void newUnits(int team, unitType uType, int num, Building b){
  PVector spawn;
  if(b == null) spawn = new PVector(teamBase[team].x, teamBase[team].y + random(-50,50));
  else spawn = new PVector(b.pos.x, b.pos.y);
  for(int i = 0; i < num; i++){
    Unit u;
    PVector target = teamBase[1-team];
    
    switch(uType){
      default:
      case fighter:
        u = new Fighter(team, spawn, target);
        break;
      case sniper:
        u = new Sniper(team, spawn, target);
        break;
      case swarm:
        u = new Swarm(team, spawn, target);
        break;
      case shotgun:
        u = new Shotgun(team, spawn, target);
        break;
      case machinegun:
        u = new Machinegun(team, spawn, target);
        break;
      case bouncer:
        u = new Bouncer(team, spawn, target);
        break;
      case medic:
        u = new Medic(team, spawn, target);
        break;
    }
    units.get(team).add(u);
  }
}

class Fighter extends Unit{
  Fighter(int _team, PVector _pos, PVector _target){
         super(_team, _pos, _target);
         health = maxHealth = 80;
         maxSpeed = 1.5;
         attackDamage = 10;
         attackRange = 100;
         attackRate = 2000;
         size = 10;
         hitForce = 1.25;
         penetrate = false;
         projSize = 5;
         burstCount = 1;
         spread = 0;
         fill = false;
   }
}

class Sniper extends Unit{
  Sniper(int _team, PVector _pos, PVector _target){
         super(_team, _pos, _target);
         health = maxHealth = 110;
         maxSpeed = 0.8;
         attackDamage = 25;
         attackRange = 175;
         attackRate = 3500;
         size = 20;
         hitForce = 2.5;
         penetrate = true;
         projSize = 15;
         burstCount = 1;
         spread = 0;
         fill = false;
         projSpeed = 5;
         pushResistance = 0.4;
   }
}

class Shotgun extends Unit{
  Shotgun(int _team, PVector _pos, PVector _target){
         super(_team, _pos, _target);
         health = maxHealth = 200;
         maxSpeed = 1.0;
         attackDamage = 7;
         attackRange = 125;
         attackRate = 3000;
         size = 15;
         hitForce = 0.2;
         penetrate = false;
         projSize = 1;
         burstCount = 12;
         spread = 20;
         fill = true;
         projSpeed = 2;
   }
}

class Swarm extends Unit{
  Swarm(int _team, PVector _pos, PVector _target){
         super(_team, _pos, _target);
         health = maxHealth = 10;
         maxSpeed = 1.65;
         attackDamage = 3;
         attackRange = 60;
         attackRate = 200;
         size = 3;
         hitForce = 0.2;
         penetrate = false;
         projSize = 2;
         burstCount = 0;
         spread = 10;
         fill = false;
         strokeWeight = 1;
   }
}

class Machinegun extends Unit{
  Machinegun(int _team, PVector _pos, PVector _target){
    super(_team, _pos, _target);
    health = maxHealth = 150;
    maxSpeed = 0.6;
    attackDamage = 6;
    attackRange = 150;
    attackRate = 50;
    size = 25;
    hitForce = 0.05;
    penetrate = false;
    projSize = 3;
    fill = true;
    spread = 10;
    projSpeed = 4;
    pushResistance = 0.5;
  }
}

class Bouncer extends Unit{
  Bouncer(int _team, PVector _pos, PVector _target){
    super(_team, _pos, _target);
    health = maxHealth = 450;
    maxSpeed = 1.6;
    attackDamage = 11;
    attackRange = 30;
    attackRate = 1000;
    size = 8;
    hitForce = 10;
    projSize = 1;
    fill = true;
    projSpeed = 5;
    pushResistance = 1.0;
  }
}

class Medic extends Unit{
  Medic(int _team, PVector _pos, PVector _target){
    super(_team, _pos, _target);
    health = maxHealth = 100;
    maxSpeed = 1.4;
    canAttack = false;
    canHeal = true;
    healRadius = 100;
    size = 15;
    hasInner = true;
    innerSize = 7;
    attackRate = 3500;
    healAmount = 5;
    healEffectSpeed = 5;
    healEffectDecay = 10;
    healEffectThickness = 10;
  }
}

class Unit{
  int team;
  float health, maxHealth, maxSpeed, size;
  float attackDamage, attackRange, attackRate, hitForce, projSize, burstCount;
  float healRadius, healAmount, healEffectSpeed, healEffectDecay, healEffectThickness;
  PVector pos, vel, target;
  float speed = 0;
  float decel = 0.9;
  float accel = 0.05;
  boolean attackReady = true;
  float lastAttack = -10000;
  boolean penetrate = false;
  float burstRemaining = 0;
  boolean instantBurst = false;
  float spread = 0;
  PVector lastTarget;
  boolean fill;
  float projSpeed = 3.5;
  float pushResistance = 0;
  boolean canAttack = true;
  boolean canHeal = false;
  boolean hasCross, hasInner;
  float strokeWeight = 3;
  float innerSize;
  
  Unit(int _team, PVector _pos, PVector _target){
    team = _team; pos = new PVector(_pos.x, _pos.y); target = _target;
    //health = maxHealth = _health; maxSpeed = _speed;
    //attackDamage = _aDamage; attackRange = _aRange; attackRate = _aRate; target = _target; size = _size;
    //hitForce = _hitForce; penetrate = _pen; projSize = _projSize; burstCount = _burstCount; spread = _spread;
    //fill = _fill;
    vel = new PVector();
  }
  
  void tick(){
    if(boundaries){
      if(pos.x < 0 || pos.x > width) vel.x = -vel.x;
      if(pos.y < 0 || pos.y > height) vel.y = -vel.y;
    }
    boolean moving = true;
    Unit attackTarget = null;
    Building attackBuilding = null;
    if(canAttack){
      float bestDist = 10000;
      for(Unit u: units.get(1-team)){
        float d = PVector.dist(pos, u.pos);
        if(d <= attackRange){
          if(d < bestDist){
            bestDist = d;
            attackTarget = u;
          }
        }
      }
      for(Building b: buildings){
        if(b.team == team) continue;
        float d = PVector.dist(pos, b.pos) - b.size/2;
        if(d <= attackRange){
          if(d < bestDist){
            bestDist = d;
            attackTarget = null;
            attackBuilding = b;
          }
        }
      }
      if(attackTarget != null || attackBuilding != null || PVector.dist(pos, target) <= attackRange)
      {
        moving = false;
      }
    }
    ArrayList<Unit> healUnits = new ArrayList();
    if(canHeal){
       for(Unit u: units.get(team)){
         if(u.canHeal) continue;
         if(u.health >= u.maxHealth) continue;
         if(PVector.dist(pos, u.pos) <= healRadius){
           healUnits.add(u);
         }
       }
       if(healUnits.size() > 0) moving = false;
    }
    if(moving){
      speed = min(speed + accel, maxSpeed);
      PVector tVel = new PVector(target.x - pos.x, target.y - pos.y);
      tVel.normalize();
      tVel.mult(speed);
      vel.lerp(tVel, 0.1);
      
    }
    else{
      vel.mult(decel);
      speed = 0;
    }
    //separation
    for(Unit u: units.get(team)){
      if(PVector.dist(pos, u.pos) <= size/2 + u.size/2){
        PVector away = new PVector(pos.x - u.pos.x, pos.y - u.pos.y);
        away.normalize();
        pos.add(away);
      }
    }
    
    pos.add(vel);
    
    if(burstRemaining > 0){
      attack(lastTarget, true);
    }
    
    if(!attackReady){
      if(millis() - lastAttack >= attackRate){
        attackReady = true;
      }
    }
    
    if(healUnits.size() > 0 && attackReady){
      heal(healUnits);
    }
    
    if(attackTarget != null && attackReady){
      attack(attackTarget.pos, false);
    }
    
    if(attackBuilding != null && attackReady){
      attack(attackBuilding.pos, false);
    }
  }
  
  void heal(ArrayList<Unit> healUnits){
    for(Unit u: healUnits){
        u.health = min(u.health + healAmount, u.maxHealth);
    }
    attackReady = false;
    lastAttack = millis();
    Pulse p = new Pulse(team, pos, healRadius, healEffectSpeed, healEffectDecay, healEffectThickness);
    pulses.add(p);
  }
  
  void attack(PVector target, boolean burst){
    PVector _target = new PVector(target.x, target.y);
    if(!burst && burstCount > 0){
      lastTarget = new PVector(target.x, target.y);
      burstRemaining = burstCount;
    }
    if(spread > 0){
      PVector s = new PVector(random(-spread/2, spread/2), random(-spread/2, spread/2));
      _target.add(s);
    }
    PVector direction = new PVector(_target.x - pos.x, _target.y - pos.y);
    direction.normalize();
    Projectile p = new Projectile(team, pos, direction, attackDamage, projSpeed, hitForce, penetrate, projSize);
    projectiles.add(p);
    attackReady = false;
    lastAttack = millis();
    if(burstCount > 0){
      burstRemaining--;
      if(instantBurst && burstRemaining > 0) attack(target, true);
    }
  }
  
  void takeDamage(PVector impact, float damage, float forceMag){
    health -= damage;
    if(health <= 0) die();
    if(pushResistance > 0) forceMag -= pushResistance;
    if(forceMag > 0){
      PVector force = new PVector(pos.x - impact.x, pos.y - impact.y);
      force.setMag(forceMag);
      vel.add(force);
    }
  }
  
  void die(){
    removeUnits.add(this);
  }
  
  void show(){
    
    if(fill){
      noStroke();
      fill(teamColour[team], (health/maxHealth)*200 + 50);
    }
    else{
      stroke(teamColour[team], (health/maxHealth)*200 + 50);
      strokeWeight(strokeWeight);
      noFill();
      if(hasCross){
        line(pos.x-size/2 + strokeWeight, pos.y, pos.x - strokeWeight, pos.y);
        line(pos.x + strokeWeight, pos.y, pos.x+size/2 - strokeWeight, pos.y);
        line(pos.x, pos.y-size/2 + strokeWeight, pos.x, pos.y - strokeWeight);
        line(pos.x, pos.y + strokeWeight, pos.x, pos.y+size/2 - strokeWeight);
        rectMode(CENTER);
        rect(pos.x, pos.y, strokeWeight/4, strokeWeight/4);
      }
    }
    ellipse(pos.x, pos.y, size, size);
    if(hasInner){
        noStroke();
        fill(teamColour[team], (health/maxHealth)*200 + 50);
        ellipse(pos.x, pos.y, innerSize, innerSize);
      }
  }
}

class Projectile{
  int team;
  PVector pos, dir;
  float speed, damage, hitForce;
  float size = 5;
  boolean penetrate = false;
  ArrayList<Unit> hitList;
  
  Projectile(int _team, PVector _pos, PVector _dir, float _damage, float _speed, float _hitForce, boolean _pen, float _size){
    team = _team; pos = new PVector(_pos.x, _pos.y); dir = _dir; damage = _damage; speed = _speed; size = _size;
    hitForce = _hitForce; penetrate = _pen;
    hitList = new ArrayList<Unit>();
  }
  
  void tick(){
    pos.x += dir.x * speed;
    pos.y += dir.y * speed;
    
    if(boundaries){
      if(pos.x < 0 || pos.x > width || pos.y < 0 || pos.y > height) removeProj.add(this);
    }
    
    boolean hit = false;
    
    for(Unit u: units.get(1-team)){
      if(PVector.dist(pos, u.pos) <= u.size){
        
        if(!penetrate){
          u.takeDamage(this.pos, damage, hitForce);
          removeProj.add(this);
          hit = true;
          break;
        }
        else{
          if(!hitList.contains(u)) u.takeDamage(this.pos, damage, hitForce);
          hitList.add(u);
        }
      }
    }
    if(!hit){
      for(Building b: buildings){
        if(b.team == team) continue;
        if(b.checkCollision(pos)){
          b.takeDamage(pos, damage);
          removeProj.add(this);
        }
      }
    }
  }
  
  void show(){
    stroke(teamColour[team]);
    strokeWeight(2);
    noFill();
    line(pos.x, pos.y, pos.x - dir.x*size, pos.y - dir.y*size);
  }
}

class Building{
  int team;
  PVector pos;
  float health, maxHealth, attackDamage, attackRange, attackRate;
  boolean attackReady;
  float lastAttack = -10000;
  float size, beamWidth;
  boolean alive = true;
  Unit lastTarget;
  
  Building(int _team, PVector _pos, float _size, float _health, float _aDamage, float _aRange, float _aRate, float _beamWidth){
    team = _team; pos = new PVector(_pos.x, _pos.y); size = _size; health = maxHealth = _health;
    attackDamage = _aDamage; attackRange = _aRange; attackRate = _aRate; beamWidth = _beamWidth;
  }
  
  void tick(){
    Unit attackTarget = null;
    if(lastTarget != null){
      if(lastTarget.health > 0 && PVector.dist(pos, lastTarget.pos) <= attackRange){
        attackTarget = lastTarget;
      }
    }
    if(attackTarget == null){
      float bestDist = 10000;
      for(Unit u: units.get(1-team)){
        float d = PVector.dist(pos, u.pos);
        if(d <= attackRange){
          if(d < bestDist){
            bestDist = d;
            attackTarget = u;
          }
        }
      }
    }
    
    if(!attackReady){
      if(millis() - lastAttack >= attackRate){
        attackReady = true;
      }
    }
    
    if(attackTarget != null && attackReady){
      attack(attackTarget);
    }
  }
  
  void show(){
    rectMode(CENTER);
    stroke(teamColour[team], (health/maxHealth)*200 + 50);
    strokeWeight(4);
    noFill();
    rect(pos.x, pos.y, size, size);
  }
  
  void attack(Unit u){
    Beam b = new Beam(team, pos, u.pos, 10, beamWidth);
    beams.add(b);
    u.takeDamage(pos, attackDamage, 3.0);
    attackReady = false;
    lastAttack = millis();
    lastTarget = u;
  }
  
  void takeDamage(PVector impact, float damage){
    health -= damage;
    if(health <= 0 && alive) die();
  }
  
  void die(){
    alive = false;
    newUnits(team, unitType.fighter, 15, this);
    newUnits(team, unitType.shotgun, 5, this);
    newUnits(team, unitType.medic, 2, this);
    newUnits(team, unitType.bouncer, 5, this);
    newUnits(team, unitType.swarm, 50, this);
    removeBuildings.add(this);
  }
  
  boolean checkCollision(PVector other){
    if(other.x >= pos.x - size/2 && other.x <= pos.x + size/2 && other.y >= pos.y - size/2 && other.y <= pos.y + size/2) return true;
    else return false;
  }
}

class Beam{
  int team;
  PVector start, end;
  float alpha = 255;
  float decay = 10;
  float weight = 2;
  
  Beam(int _team, PVector _start, PVector _end, float _decay, float _weight){
    team = _team; start = new PVector(_start.x, _start.y); end = new PVector(_end.x, _end.y); decay = _decay; weight = _weight;
    alpha = 255;
  }
  
  void tick(){
    alpha -= decay;
    if(alpha<=0) removeBeams.add(this);
  }
  
  void show(){
    stroke(teamColour[team], alpha);
    strokeWeight(weight);
    line(start.x, start.y, end.x, end.y);
  }
}

class Pulse{
  int team;
  PVector pos;
  float radius, endRadius;
  float speed = 1;
  float alpha = 255;
  float decay = 5;
  float thickness = 5;
  
  Pulse(int _team, PVector _pos, float _radius, float _speed, float _decay, float _thickness){
    team = _team; pos = new PVector(_pos.x, _pos.y); endRadius = _radius; speed = _speed; radius = 1; decay = _decay; thickness = _thickness;
  }
  
  void tick(){
    alpha -= decay;
    radius += speed;
    if(alpha <= 0 || radius >= endRadius) removePulses.add(this);
  }
  
  void show(){
    strokeWeight(1);
    for(int i = 0; i < thickness; i++){
      stroke(teamColour[team], alpha - max(decay,((thickness-i)*(alpha/thickness))));
      ellipse(pos.x, pos.y, radius+i, radius+i);
    }
  }
}

void demo_spawning(){
  if(teamBaseBuil[0].health > 0){
    if(random(100) > 99){
      newUnits(0, unitType.fighter, 4, null);
    }
    if(random(1000) > 998){
      newUnits(0, unitType.sniper, 1, null);
    }
    if(random(1000) > 999){
      newUnits(0, unitType.swarm, 30, null);
    }
    if(random(1000) > 999){
      newUnits(0, unitType.shotgun, 1, null);
    }
    if(random(10000) > 9995){
      newUnits(0, unitType.machinegun, 1, null);
    }
    if(random(1000) > 998){
      newUnits(0, unitType.bouncer, 1, null);
    }
    if(random(1000) > 999){
      newUnits(0, unitType.medic, 1, null);
    }
  }
  if(teamBaseBuil[1].health > 0){
    if(random(100) > 99){
      newUnits(1, unitType.fighter, 4, null);
    }
    if(random(1000) > 999){
      newUnits(1, unitType.sniper, 1, null);
    }
    if(random(1000) > 998){
      newUnits(1, unitType.swarm, 30, null);
    }
    if(random(1000) > 998){
      newUnits(1, unitType.shotgun, 1, null);
    }
    if(random(10000) > 9995){
      newUnits(1, unitType.machinegun, 1, null);
    }
    if(random(1000) > 998){
      newUnits(1, unitType.bouncer, 1, null);
    }
    if(random(1000) > 999){
      newUnits(1, unitType.medic, 1, null);
    }
  }
}

void keyPressed()
{
  if (keyCode==32) { // space
    String fn = "pair-"+hour()+"-"+minute()+"-"+second()+".png";
    saveFrame(fn);
    println("Saved image "+fn);
  }
  if (keyCode==10 && demo) { // enter
    setup();
    println("Initialising new state");
  }
}
