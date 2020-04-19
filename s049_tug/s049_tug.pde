// made by alex
// iamalexbaker@gmail.com
// dailygenerative.art.blog

boolean boundaries = true;
boolean demo = false;
boolean debug = false;
boolean cheat = false;

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
ArrayList<ArrayList<Spawner>> spawners;

float[] money = new float[2];
float[] income = new float[2];
int spawnerBaseCost = 50;
float spawnerCostMult = 1.4;
int mouseOver = 0;
int selected = 0;
float incomeTime = 1000;
float lastIncome = -10000;
float startIncome = 5;
int[] nextSpawnerCost = new int[2];
float AISaveTarget = 0;

enum unitType{
  none,
  fighter,
  sniper,
  swarm,
  shotgun,
  machinegun,
  bouncer,
  medic,
  bomber,
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
  spawners = new ArrayList<ArrayList<Spawner>>();
  spawners.add(new ArrayList<Spawner>());
  spawners.add(new ArrayList<Spawner>());
  spawners.get(0).add(new Spawner(0, 1.0));
  spawners.get(1).add(new Spawner(1, 1.0));
  teamBaseBuil[0] = new Building(0, teamBase[0], 50, 5000, 35, 325, 800, 4);
  teamBaseBuil[1] = new Building(1, teamBase[1], 50, 5000, 35, 325, 800, 4);
  buildings.add(teamBaseBuil[0]);
  buildings.add(teamBaseBuil[1]);
  buildings.add(new Building(0, new PVector(teamBase[0].x + 200, height/3), 20, 2500, 10, 180, 125, 2));
  buildings.add(new Building(0, new PVector(teamBase[0].x + 200, 2*height/3), 20, 2500, 10, 180, 125, 2));
  buildings.add(new Building(1, new PVector(teamBase[1].x - 200, height/3), 20, 2500, 10, 180, 125, 2));
  buildings.add(new Building(1, new PVector(teamBase[1].x - 200, 2*height/3), 20, 2500, 10, 180, 125, 2));
  //buildings.add(new Building(0, new PVector(width/2, height/4), 15, 1500, 10, 180, 100, 2));
  //buildings.add(new Building(1, new PVector(width/2, 3*height/4), 15, 1500, 10, 180, 100, 2));
  income[0] = startIncome;
  income[1] = startIncome;
  nextSpawnerCost[0] = spawnerBaseCost;
  nextSpawnerCost[1] = spawnerBaseCost;
  if(cheat) money[0] = 10000;
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
  
  for(int i = 0; i < 2; i++){
    if(teamBaseBuil[i].alive){
      for(Spawner s: spawners.get(i)){
        s.tick();
      }
    }
  }
  
  income();
  handleInput();
  drawUI();
  if(random(10) > 9) AI();
  
  if(!teamBaseBuil[0].alive){
    drawResultText(false);
  } else if (!teamBaseBuil[1].alive) {
    drawResultText(true);
  }
}

// AI basically just buys random stuff at the moment
void AI(){
  if(money[1] >= nextSpawnerCost[1]){
    if(nextSpawnerCost[1] >= AISaveTarget){
      if(debug) println("AI bought spawner number "+(spawners.get(1).size()+1)+" for "+nextSpawnerCost[1]);
      newSpawner(1);
      AISaveTarget = 0;
    }
  } else if(AISaveTarget == 0 && random(1000)>995){
      AISaveTarget = nextSpawnerCost[1];
      if(debug) println("AI Save Target set to "+nextSpawnerCost[1]);
  }
  for(int i = 0; i < spawners.get(1).size(); i++){
    Spawner sp = spawners.get(1).get(i);
    if(i < 2 || sp.uType != unitType.fighter)
    {
      for(UpgradeOption up: sp.upOpt){
        if(up.upType == upgradeType.unit) continue;
        if(money[1] >= up.cost){
          if(up.cost >= AISaveTarget){
            if(debug) println("AI bought upgrade "+up.upType+" level "+(up.level+1)+" for "+up.cost);
            upgrade(sp, up);
            AISaveTarget = 0;
            i = spawners.get(1).size(); // break out of loop
            break;
          }
        } else if(AISaveTarget == 0 && random(1000)>995){
          AISaveTarget = up.cost;
          if(debug) println("AI Save Target set to "+up.cost);
        }
      }
    }else{
      for(UpgradeOption up: sp.upOpt){
        if(up.upType != upgradeType.unit) continue;
        if(money[1] >= up.cost && random(5) > 4){
          if(up.cost >= AISaveTarget){
            if(debug) println("AI bought upgrade "+up.upType+" level "+(up.level+1)+" for "+up.cost);
            upgrade(sp, up);
            AISaveTarget = 0;
            i = spawners.get(1).size();
            break;
          }
        } else if(AISaveTarget == 0 && random(100)>99){
            AISaveTarget = up.cost;
            if(debug) println("AI Save Target set to "+up.cost);
        }
      }
    }
  }
}

void income(){
  if(millis() - lastIncome >= incomeTime){
    money[0] += income[0];
    money[1] += income[1];
    lastIncome = millis();
  }
}

void handleInput(){
  if(selected==0){
    int numBoxes = spawners.get(0).size() + 1;
    if(mouseY >= 10 && mouseY <= 60 && mouseX >= 10 && mouseX <= 10 + 50*numBoxes){
      mouseOver = floor((mouseX - 10) / 50) + 1;
    }
    else mouseOver = 0;
  } else{
    int numBoxes = spawners.get(0).get(selected-1).upOpt.size();
    int leftBox = max(0, (selected-1) - floor(numBoxes/2));
    if(mouseY >= 60 && mouseY <= 110 && mouseX >= 10 + leftBox*50 && mouseX <= 10 + (numBoxes+leftBox)*50){
      mouseOver = floor((mouseX - 10) / 50) + 1 - leftBox;
    } else mouseOver = 0;
  }
}

void mousePressed(){
  if(selected==0){
    int numBoxes = spawners.get(0).size() + 1;
    if(mouseY >= 10 && mouseY <= 60 && mouseX >= 10 && mouseX <= 10 + 50*numBoxes){
      selected = floor((mouseX - 10) / 50) + 1;
      if(selected == spawners.get(0).size() + 1){
        newSpawner(0);
        selected = 0;
      }
    }
    else selected = 0;
  } else{
    int numBoxes = spawners.get(0).get(selected-1).upOpt.size();
    int leftBox = max(0, (selected-1) - floor(numBoxes/2));
    if(mouseY >= 60 && mouseY <= 110 && mouseX >= 10 + leftBox*50 && mouseX <= 10 + (numBoxes+leftBox)*50){
      int selOpt = floor((mouseX - (leftBox*50 + 10)) / 50);
      upgrade(0, selected-1, selOpt);
    }
    selected = 0;
  }
}

void drawResultText(boolean victory){
  fill(0,0,0,120);
  rectMode(CENTER);
  noStroke();
  rect(width/2, height/2, width/2, height/2);
  textSize(96);
  textAlign(CENTER);
  fill(teamColour[victory?0:1], 200);
  text(victory?"Victory!":"Defeat", width/2, height/2 + 30);
}

void drawUI(){
  drawUnitCounts();
  drawMoney();
  drawSpawners();
}

void drawMoney(){
  textSize(32);
  textAlign(RIGHT, TOP);
  fill(teamColour[0]);
  text(int(money[0]), width-20, 10);
  textSize(10);
  text("+"+int(income[0]), width-5, 2);
  if(debug){
    textSize(32);
    textAlign(RIGHT, TOP);
    fill(teamColour[1]);
    text(int(money[1]), width-20, 50);
    textSize(10);
    text("+"+int(income[1]), width-5, 42);
  }
}

void drawSpawners(){
  rectMode(CORNER);
  for(int i = 0; i < spawners.get(0).size() + 1; i++){
    if(mouseOver==i+1 && selected == 0) fill(0,0,0.2);
    else if(selected==i+1) fill(0,0,0.4);
    else noFill();
    stroke(0,0,.8); // white-ish
    strokeWeight(2);
    rect(10 + i*50, 10, 50, 50);
    textAlign(CENTER);
    fill(0,0,.8);
    textSize(10);
    text(i+1, 35 + i *50, 55);
    if(i < spawners.get(0).size()){
      Spawner sp = spawners.get(0).get(i);
      text(sp.uType.toString(), 35 + i*50, 40);
    }
    else{
      fill(teamColour[0]);
      textSize(16);
      text(nextSpawnerCost[0], 35 + i*50, 40);
    }
  }
  if(selected != 0) drawOptions(selected);
}

void drawOptions(int spawner){
  if(spawner < spawners.get(0).size()+1)
  {
    Spawner sp = spawners.get(0).get(spawner-1);
    int numOpt = sp.upOpt.size();
    int leftBox = max(0, (spawner-1) - floor(numOpt/2));
    for(int i = leftBox; i < leftBox + numOpt; i++){
      if(mouseOver==(i-leftBox)+1) fill(0,0,0.2);
      else noFill();
      stroke(0,0,.8); // white-ish
      strokeWeight(2);
      rect(10 + i*50, 60, 50, 50);
      textAlign(CENTER);
      UpgradeOption opt = sp.upOpt.get(i-leftBox);
      fill(0, 0, 0.8);
      textSize(10);
      String msg = "";
      switch(opt.upType){
        default:
          break;
        case unit:
          msg = opt.uType.toString();
          break;
        case number:
          msg = opt.upType.toString();
          break;
      }
      text(msg, 35+ i*50, 85);
      fill(teamColour[0]);
      textSize(10);
      text(int(opt.cost), 35 + i *50, 105);
    }
  }
}

void drawUnitCounts(){
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

void newSpawner(int team){
  if(money[team] >= nextSpawnerCost[team]){
    money[team] -= nextSpawnerCost[team];
    nextSpawnerCost[team] = int(nextSpawnerCost[team]*spawnerCostMult);
    spawners.get(team).add(new Spawner(team, pow(spawnerCostMult, spawners.get(team).size())));
  }
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
      case bomber:
        u = new Bomber(team, spawn, target);
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
         buildingDamageMult = 1.25;
         size = 10;
         hitForce = 1.25;
         penetrate = false;
         projSize = 5;
         burstCount = 1;
         spread = 0;
         fill = false;
         bounty = 1;
   }
}

class Sniper extends Unit{
  Sniper(int _team, PVector _pos, PVector _target){
         super(_team, _pos, _target);
         health = maxHealth = 110;
         maxSpeed = 0.8;
         attackDamage = 22;
         attackRange = 175;
         attackRate = 3500;
         buildingDamageMult = 0.75;
         size = 18;
         hitForce = 2.5;
         penetrate = true;
         projSize = 15;
         burstCount = 1;
         spread = 0;
         fill = false;
         projSpeed = 5;
         pushResistance = 0.4;
         bounty = 10;
   }
}

class Shotgun extends Unit{
  Shotgun(int _team, PVector _pos, PVector _target){
         super(_team, _pos, _target);
         health = maxHealth = 200;
         maxSpeed = 1.0;
         attackDamage = 7;
         attackRange = 125;
         attackRate = 2400;
         buildingDamageMult = 0.75;
         size = 15;
         hitForce = 0.2;
         penetrate = false;
         projSize = 1;
         burstCount = 12;
         spread = 20;
         fill = true;
         projSpeed = 2;
         bounty = 8;
   }
}

class Swarm extends Unit{
  Swarm(int _team, PVector _pos, PVector _target){
         super(_team, _pos, _target);
         health = maxHealth = 12;
         maxSpeed = 1.65;
         attackDamage = 4;
         attackRange = 60;
         attackRate = 200;
         buildingDamageMult = 0.3;
         size = 3;
         hitForce = 0.2;
         penetrate = false;
         projSize = 2;
         burstCount = 0;
         spread = 10;
         fill = false;
         strokeWeight = 1;
         bounty = 0.1;
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
    buildingDamageMult = 0.5;
    size = 25;
    hitForce = 0.05;
    penetrate = false;
    projSize = 3;
    fill = true;
    spread = 10;
    projSpeed = 4;
    pushResistance = 0.5;
    bounty = 12;
  }
}

class Bouncer extends Unit{
  Bouncer(int _team, PVector _pos, PVector _target){
    super(_team, _pos, _target);
    health = maxHealth = 450;
    maxSpeed = 1.6;
    attackDamage = 17;
    attackRange = 30;
    attackRate = 1000;
    size = 8;
    hitForce = 12;
    projSize = 1;
    fill = true;
    projSpeed = 5;
    pushResistance = 1.0;
    bounty = 8;
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
    bounty = 8;
  }
}

class Bomber extends Unit{
  Bomber(int _team, PVector _pos, PVector _target){
    super(_team, _pos, _target);
    health = maxHealth = 140;
    maxSpeed = 1.3;
    size = 20;
    strokeWeight = 5;
    hasInner = true;
    innerSize = 6;
    attackRate = 3500;
    attackDamage = 45;
    attackRange = 150;
    buildingDamageMult = 2.5;
    hitForce = 6.0;
    projSize = 6;
    circleProj = true;
    explosive = true;
    explosionRadius = 70;
    pushResistance = 0.5;
    projSpeed = 4;
    bounty = 12;
  }
}

class Spawner{
  int team;
  float costMult = 1.0;
  unitType uType = unitType.fighter;
  int numUnits = 1;
  float spawnTime = 5000;
  float lastSpawn = -1000;
  boolean canSpawn = false;
  ArrayList<UpgradeOption> upOpt;
  
  Spawner(int _team, float _costMult){
    team = _team; costMult = _costMult;
    upOpt = new ArrayList<UpgradeOption>();
    BasicUpgrades();
    FighterUpgrades();
  }
  void BasicUpgrades(){
    upOpt.add(new UpgradeOption((uType==unitType.fighter)?50:150, upgradeType.number, (uType==unitType.swarm)?10:1));
  }
  void FighterUpgrades(){
    upOpt.add(new UpgradeOption(250, unitType.sniper, 1, 15000));
    upOpt.add(new UpgradeOption(200, unitType.shotgun, 1, 15000));
    upOpt.add(new UpgradeOption(100, unitType.swarm, 10, 10000));
    upOpt.add(new UpgradeOption(300, unitType.machinegun, 1, 15000));
    upOpt.add(new UpgradeOption(150, unitType.bouncer, 1, 10000));
    upOpt.add(new UpgradeOption(150, unitType.medic, 1, 15000));
    upOpt.add(new UpgradeOption(300, unitType.bomber, 1, 15000));
  }
  void RemoveFighterUpgrades(){
    ArrayList<UpgradeOption> remove = new ArrayList<UpgradeOption>();
    for(UpgradeOption opt: upOpt){
      if(opt.upType == upgradeType.unit) remove.add(opt);
    }
    upOpt.removeAll(remove);
  }
  void tick(){
    if(millis() - lastSpawn >= spawnTime) canSpawn = true;
    if(canSpawn) spawn(false);
  }
  void spawn(boolean bonus){
    newUnits(team, uType, numUnits, null);
    if(!bonus){
      canSpawn = false;
      lastSpawn = millis();
    }
  }
  void upgrade(UpgradeOption up){
    if(up.upType != upgradeType.unit){
      up.cost = int(up.cost * up.costMultipler);
      up.level++;
      if(uType == unitType.fighter) RemoveFighterUpgrades();
    }
    switch(up.upType){
      default:
      case number:
        numUnits += int(up.value);
        break;
      case unit:
          uType = up.uType;
          numUnits = up.numUnits;
          spawnTime = up.time;
          upOpt.clear();
          BasicUpgrades();
        break;
    }
  }
}

enum upgradeType{
  none,
  unit,
  number,
  time,
  damage,
  range,
}

void upgrade(Spawner sp, UpgradeOption upOpt){
  int team = sp.team;
  if(money[team] >= upOpt.cost){
    money[team] -= upOpt.cost;
    sp.upgrade(upOpt);
  }
}

void upgrade(int team, int spawner, int upOpt){
  Spawner sp = spawners.get(team).get(spawner);
  UpgradeOption opt = sp.upOpt.get(upOpt);
  upgrade(sp, opt);
}

class UpgradeOption{
  float cost = 1000;
  unitType uType = unitType.none;
  upgradeType upType = upgradeType.none;
  float value = 1.0;
  int numUnits = 1;
  float time = 5000.0;
  int level = 0;
  float costMultipler = 1.3;
  
  UpgradeOption(float _cost, unitType _uType, int _numUnits, float _time){
    cost = _cost; uType = _uType; upType = upgradeType.unit; numUnits = _numUnits; time = _time;
  }
  
  UpgradeOption(float _cost, upgradeType _upType, float _value){
    cost = _cost; upType = _upType; value = _value;
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
  float bounty = 0;
  boolean alive = true;
  boolean circleProj = false;
  boolean explosive = false;
  float explosionRadius;
  float buildingDamageMult = 1.0;
  
  Unit(int _team, PVector _pos, PVector _target){
    team = _team; pos = new PVector(_pos.x, _pos.y); target = _target;
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
    Projectile p = new Projectile(team, pos, direction, attackDamage, projSpeed, hitForce, penetrate, circleProj, projSize, explosive, explosionRadius, buildingDamageMult);
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
    if(health <= 0 && alive) die();
    if(pushResistance > 0) forceMag -= pushResistance;
    if(forceMag > 0){
      PVector force = new PVector(pos.x - impact.x, pos.y - impact.y);
      force.setMag(forceMag);
      vel.add(force);
    }
  }
  
  void die(){
    if(bounty > 0) money[1-team] += bounty;
    alive = false;
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
  boolean circular = false;
  boolean explosive = false;
  float explosionRadius;
  float buildingDamageMult = 1.0;
  
  Projectile(int _team, PVector _pos, PVector _dir, float _damage, float _speed, float _hitForce, boolean _pen, boolean _circular, float _size, boolean _expl, float _explR, float _builDamMult){
    team = _team; pos = new PVector(_pos.x, _pos.y); dir = _dir; damage = _damage; speed = _speed; size = _size;
    hitForce = _hitForce; penetrate = _pen; circular = _circular; explosive = _expl; explosionRadius = _explR; buildingDamageMult = _builDamMult;
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
          if(explosive) explode();
          else u.takeDamage(this.pos, damage, hitForce);
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
          b.takeDamage(pos, damage*buildingDamageMult);
          if(explosive) explode();
          removeProj.add(this);
        }
      }
    }
  }
  
  void explode(){
    for(Unit u: units.get(1-team)){
      float d = PVector.dist(pos, u.pos);
      if(d <= explosionRadius){
        float ratio = d/explosionRadius;
        u.takeDamage(pos, damage * ratio, hitForce*ratio);
      }
    }
    pulses.add(new Pulse(team, pos, explosionRadius, 15, 25, 15)); // last three are speed, decay, thickness
  }
  
  void show(){
    if(circular){
      noStroke();
      fill(teamColour[team]);
      ellipse(pos.x, pos.y, size, size);
    }
    else{
      stroke(teamColour[team]);
      strokeWeight(2);
      noFill();
      line(pos.x, pos.y, pos.x - dir.x*size, pos.y - dir.y*size);
    }
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
    noFill();
    strokeWeight(1);
    for(int i = 0; i < thickness; i++){
      stroke(teamColour[team], alpha - max(decay,((thickness-i)*(alpha/thickness))));
      ellipse(pos.x, pos.y, (radius*2)+i, (radius*2)+i);
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
  if (keyCode==10 && (debug||demo)) { // enter
    setup();
    println("Initialising new state");
  }
}
