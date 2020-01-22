// made by alex
// iamalexbaker@gmail.com
// dailygenerative.art.blog

color bgc;
color foodColour;
float alpha = 0.05;

boolean do_draw = true;
boolean realtime = true;
int staticTicks = 10000;

int nGenes = 40;
int numCreaturesInit = 500;
int maxFood = 100;

ArrayList<creature> creatures;
ArrayList<creature> removal;
ArrayList<creature> babies;
ArrayList<food> foods;
ArrayList<food> removefood;

enum cState{
  foraging,
  mating,
  resting
}

void setup(){
  size(800, 800);
  rectMode(CENTER);
  colorMode(HSB, 1., 1., 1., 1.);
  bgc = color(0, 0, 0.8);
  foodColour = color(0, 0, 0);
  
  do_draw = true;
  
  creatures = new ArrayList<creature>();
  removal = new ArrayList<creature>();
  babies = new ArrayList<creature>();
  foods = new ArrayList<food>();
  removefood = new ArrayList<food>();
  
  for(int k = 0; k < maxFood; k++){
    foods.add(new food(random(50, width-50), random(50, height-50), 20));
  }
  
  for(int j = 0; j < numCreaturesInit; j++){
    float[] g = new float[nGenes];
    for(int i = 0; i < nGenes; i++){
      g[i] = random(1);
    }
    creatures.add(new creature(random(0, width), random(0, height), g, g));
  }
}
void draw(){
  if(!do_draw) return;
  background(bgc);
  if(realtime){
    tick();
  }else{
    do_draw = false;
    for(int i = 0; i < staticTicks; i++){
      tick();
    }
  }
}

void tick(){
  for(creature c: creatures){
    c.tick();
    c.show();
  }
  for(creature c: removal){
    creatures.remove(c);
  }
  removal.clear();
  for(creature c: babies){
    creatures.add(c);
  }
  babies.clear();
  if(realtime){
    for(food f: foods){
      f.show();
    }
  }
  for(food f: removefood){
    foods.remove(f);
  }
  removefood.clear();
  if(foods.size() < maxFood){
    foods.add(new food(random(10, width-10), random(10, height-10), random(10)+2));
  }
}

class creature{
  cState state;
  float[] genes;
  PVector pos, target, vel, acc;
  boolean alive;
  float life, maxLife, energy, maxEnergy, restEnergy, size, speed, accel, age, maxAge, existenceCost, moveCost;
  float repTimer, repTime, repEnergyCost, reassessmentChance, fGravity; 
  boolean fertile;
  color colour;
  food foodTarget;
  creature mateTarget;
  creature(float x, float y, float[] mum, float[] dad){
    combineGenes(mum, dad);
    pos = new PVector(x, y);
    state = cState.foraging;
    alive = true;
    age = 0;
    maxLife = genes[0] * 50 + genes[1] * 200 + 50; life = maxLife;
    size = genes[1] * 16 + genes[11] * 4 + 5;
    speed = max(genes[4] - genes[1]*0.7, 0) * 7 + 1;
    accel = constrain(genes[4] - (genes[1]*0.5), 0.1, 1);
    colour = color(genes[2], genes[3], genes[5]);
    maxAge = genes[6] * 50 + genes[1] * 30 + 20;
    maxEnergy = constrain(genes[7] - (1-genes[1]), 0, 1) * 100 + 20; energy = maxEnergy;
    repEnergyCost = maxEnergy * (0.3 + genes[1]*0.4);
    repTime = genes[8] * 100 + genes[1] * 700;
    repTimer = 0; fertile = false;
    reassessmentChance = genes[9]*0.02 + 0.98;
    existenceCost = (1-genes[1]) * 0.05 + 0.01;
    moveCost = genes[1] * 0.15;
    restEnergy = repEnergyCost + genes[10] * maxEnergy * 0.3;
    //println(maxEnergy+" "+repEnergyCost+" "+restEnergy);
    fGravity = constrain(genes[1] - genes[4]*0.5, 0.2, 1.0) - 0.2;
    target = new PVector(random(0, width), random(0,height));
    vel = new PVector();
  }
  
  void findMate(){
    if(creatures.size() > 1){
      float bestDist = 999999;
      creature bestMate = null;
      for(creature m: creatures){
        if(m == this) continue;
        float d = pos.dist(m.pos);
        if(d < bestDist){
          bestDist = d;
          bestMate = m;
        }
      }
      mateTarget = bestMate;
      state = cState.mating;
    }
  }
  
  void findFood(){
    if(foods.size() == 0){
      foodTarget = null;
      target = pos;
    }
    else{
      float bestDist = 999999;
      food bestFood = null;
      for(food f: foods){
        float d = pos.dist(f.pos);
        if(d < bestDist){
          bestDist = d;
          bestFood = f;
        }
      }
      foodTarget = bestFood;
      target = foodTarget.pos;
      state = cState.foraging;
    }
  }
  
  void combineGenes(float[] mum, float[] dad){
    genes = new float[nGenes];
    for(int i = 0; i < nGenes; i++){
      if(random(1) > 0.5) genes[i] = mum[i];
      else genes[i] = dad[i];
    }
    if(random(1) > 0.9){
      genes[int(random(nGenes))] = random(1);
    }
  }
  
  void reproduce(creature m){
    if(energy < repEnergyCost){
      state = cState.foraging; 
      return;
    }
    babies.add(new creature(pos.x, pos.y, genes, m.genes));
    repTimer = 0;
    fertile = false;
    energy -= repEnergyCost;
    state = cState.foraging;
  }
  
  void eatFood(food f){
    energy = constrain(energy+f.energy, 0, maxEnergy);
    f.available = false;
    removefood.add(f);
  }
  
  void attractFood(){
    for(food f: foods){
      float d = pos.dist(f.pos);
      if(d < size*1.5){
        if(d < 10) eatFood(f);
        else{
          PVector mv = PVector.sub(pos, f.pos);
          f.pos.add(mv.setMag(fGravity));
        }
      }
    }
  }
  
  void tick(){
    age++;
    repTimer++;
    if(repTimer >= repTime) fertile = true;
    energy -= existenceCost;
    life = constrain(life + ((maxEnergy/energy) * 0.02) - (age/maxAge) * 0.01, 0, maxLife);
    if(life <= 0 || energy <= 0) die();
    
    if(fGravity > 0) attractFood();
    
    if((state == cState.foraging || state == cState.mating) && energy > maxEnergy*0.8 && fertile){
      findMate();
    }
    if(state == cState.mating){
      if(!mateTarget.alive) findMate();
      if(energy < repEnergyCost) state = cState.foraging;
      if(pos.dist(target) <= 10.0){
        reproduce(mateTarget);
      }
    }
    if(state == cState.resting){
      //println(energy+" / "+maxEnergy+" -> "+restEnergy);
      if(fertile){
        findMate();
      }
      else if(energy < restEnergy){
        findFood();
      }
    }
    if(state == cState.foraging){
      if(energy >= restEnergy){
        state = cState.resting;
      }else{
        if(foodTarget == null || random(1) > reassessmentChance){
          findFood();
        } else if(!foodTarget.available) findFood();
        if(pos.dist(target) <= 10){
          if(foodTarget != null){
            if(foodTarget.available){
              //println(energy+" ->> "+constrain(energy+foodTarget.energy, 0, maxEnergy)+" || "+maxEnergy);
              eatFood(foodTarget);
            }
          }
          //target = new PVector(random(0, width), random(0,height));
        }
      }
    }
    
    
    move();
  }
  
  void move(){
    if(pos.x < 0 || pos.x > width || pos.y < 0 || pos.y > height) vel.mult(-1);
    if(state != cState.resting){
      acc = PVector.sub(target,pos).setMag(accel);
      vel.add(acc).limit(speed);
    } else { 
      vel.mult(0.9);
    }
    pos.add(vel);
    energy -= vel.mag() * moveCost;
  }
  
  void die(){
    removal.add(this);
    alive = false;
  }
  
  void show(){
    noStroke();
    fill(colour, (realtime)?life/maxLife:alpha);
    ellipse(pos.x, pos.y, size, size);
    //text(life+", "+energy, pos.x, pos.y);
  }
}

class food{
  PVector pos;
  float energy;
  boolean available;
  
  food(float x, float y, float e){
    pos = new PVector(x, y); energy = e; available = true;
  }
  
  void show(){
    noFill();
    stroke(foodColour, alpha);
    rect(pos.x, pos.y, energy, energy);
  }
}

void keyPressed()
{
  if (keyCode==32) { // space
    String fn = "gen-"+hour()+"-"+minute()+"-"+second()+".png";
    saveFrame(fn);
    println("Saved image "+fn);
  }
  if (keyCode==10) { // enter
    setup();
    println("Initialising new state");
  }
}
