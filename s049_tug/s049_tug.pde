//
//
//

boolean boundaries = true;

color bgc;
color[] teamColour = new color[2];
PVector[] teamBase = new PVector[2];
ArrayList<ArrayList<Unit>> units;
ArrayList<Unit> removeUnits;
ArrayList<Building> buildings;
ArrayList<Building> removeBuildings;
ArrayList<Projectile> projectiles;
ArrayList<Projectile> removeProj;
ArrayList<Beam> beams;
ArrayList<Beam> removeBeams;

void setup(){
  size(1200,300);
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
  buildings.add(new Building(0, teamBase[0], 50, 5000, 35, 325, 800, 4));
  buildings.add(new Building(1, teamBase[1], 50, 5000, 35, 325, 800, 4));
  buildings.add(new Building(0, new PVector(teamBase[0].x + 200, height/4), 20, 2000, 5, 180, 125, 2));
  buildings.add(new Building(0, new PVector(teamBase[0].x + 200, 3*height/4), 20, 2000, 5, 180, 125, 2));
  buildings.add(new Building(1, new PVector(teamBase[1].x - 200, height/4), 20, 2000, 5, 180, 125, 2));
  buildings.add(new Building(1, new PVector(teamBase[1].x - 200, 3*height/4), 20, 2000, 5, 180, 125, 2));
  buildings.add(new Building(0, new PVector(width/2, height/6), 20, 2000, 5, 180, 125, 2));
  buildings.add(new Building(1, new PVector(width/2, 5*height/6), 20, 2000, 5, 180, 125, 2));
}

void draw(){
  background(bgc);
  if(random(100) > 97){
    newUnit(0);
  }
  if(random(1000) > 998){
    newBigUnit(0);
  }
  if(random(1000) > 999){
    newSwarm(0, 30);
  }
  if(random(100) > 97){
    newUnit(1);
  }
  if(random(1000) > 999){
    newBigUnit(1);
  }
  if(random(1000) > 998){
    newSwarm(1, 30);
  }
  if(random(1000) > 999){
    newShotgun(0);
  }
  if(random(1000) > 999){
    newShotgun(1);
  }
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

void newUnit(int team){
  Unit u = new Unit(team, new PVector(teamBase[team].x, teamBase[team].y + random(-50,50)), 100, 1.5, 10, 100, 2000, teamBase[1-team], 10, 1.25, false, 5, 1, 0, false);
  units.get(team).add(u);
}

void newBigUnit(int team){
  Unit u = new Unit(team, new PVector(teamBase[team].x, teamBase[team].y + random(-50,50)), 150, 0.8, 25, 175, 3500, teamBase[1-team], 25, 2.5, true, 15, 1, 0, false);
  units.get(team).add(u);
}

void newSwarm(int team, int num){
  PVector spawn = new PVector(teamBase[team].x, teamBase[team].y + random(-50,50));
  for(int i =0; i<num; i++){
    Unit u = new Unit(team, spawn, 10, 1.8, 3, 50, 200, teamBase[1-team], 3, 0.2, false, 2, 1, 0, false);
    units.get(team).add(u);
  }
}

void newShotgun(int team){
  Unit u = new Unit(team, new PVector(teamBase[team].x, teamBase[team].y + random(-50,50)), 110, 1.0, 7, 125, 4000, teamBase[1-team], 15, 0.2, false, 1, 10, 20, true);
  units.get(team).add(u);
}

class Shotgun extends Unit{
  Shotgun(int _team, PVector _pos, float _health, float _speed, float _aDamage, float _aRange, float _aRate, PVector _target,
       float _size, float _hitForce, boolean _pen, float _projSize, float _burstCount, float _spread, boolean _fill){
         //float __health = 110;
         super(_team, _pos, 110, _speed, _aDamage, _aRange, _aRate, _target, _size, _hitForce, _pen, _projSize, _burstCount, _spread, _fill);
   }
}

class Unit{
  int team;
  float health, maxHealth, maxSpeed, size;
  float attackDamage, attackRange, attackRate, hitForce, projSize, burstCount;
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
  
  Unit(int _team, PVector _pos, float _health, float _speed, float _aDamage, float _aRange, float _aRate, PVector _target,
       float _size, float _hitForce, boolean _pen, float _projSize, float _burstCount, float _spread, boolean _fill){
    team = _team; pos = new PVector(_pos.x, _pos.y); health = maxHealth = _health; maxSpeed = _speed;
    attackDamage = _aDamage; attackRange = _aRange; attackRate = _aRate; target = _target; size = _size;
    hitForce = _hitForce; penetrate = _pen; projSize = _projSize; burstCount = _burstCount; spread = _spread;
    fill = _fill;
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
    
    if(attackTarget != null && attackReady){
      attack(attackTarget.pos, false);
    }
    
    if(attackBuilding != null && attackReady){
      attack(attackBuilding.pos, false);
    }
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
    Projectile p = new Projectile(team, pos, direction, attackDamage, 3.5, hitForce, penetrate, projSize);
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
    PVector force = new PVector(pos.x - impact.x, pos.y - impact.y);
    force.setMag(forceMag);
    vel.add(force);
  }
  
  void die(){
    removeUnits.add(this);
  }
  
  void show(){
    stroke(teamColour[team], (health/maxHealth)*200 + 50);
    strokeWeight(3);
    if(size<10) strokeWeight(2);
    if(size<5) strokeWeight(1);
    if(fill) fill(teamColour[team], (health/maxHealth)*200 + 50);
    else noFill();
    ellipse(pos.x, pos.y, size, size);
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
    if(health <= 0) die();
  }
  
  void die(){
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
