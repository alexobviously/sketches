// made by alex
// iamalexbaker@gmail.com
// dailygenerative.art.blog

int maxCogs = 30;
boolean debug = false;
color bgc = color(230);
color lc = color(0);
float alpha = 255;
float strokeWeight = 4;
float[] cogWidth = {10, 100};
float[] toothDepth = {0.05, 0.2}; // percentage of cog width
int[] teeth = {4,10};
int perseverence = 500;

int nc = 2;
color[] c = new color[nc];
ArrayList<cog> cogs = new ArrayList<cog>();

class cog{
  PVector pos;
  float radius;
  cog(float x, float y, float r){
    pos = new PVector(x, y); radius = r;
  }
  
  boolean inRadius(PVector pt, float otherR){
    if(pos.dist(pt) < (radius + otherR)){
      if(debug){
        strokeWeight(1);
        stroke(hue(c[0])+PI,0.5,0.8,100);
        noFill();
        ellipse(pt.x,pt.y,otherR*2,otherR*2);
        stroke(hue(c[1])+PI,0.5,0.8,100);
        ellipse(pos.x,pos.y,radius+otherR,radius+otherR);
      }
      return true;
    } else {
      return false;
    }
  }
}

void setup(){
  size(800,800);
  background(bgc);
  cogs.clear();
  colorMode(HSB, TWO_PI, 1, 1);
  stroke(lc);
  strokeWeight(strokeWeight);
  for (int i = 0; i < nc; i++) {
    c[i] = color(random(TWO_PI), random(0.8), random(0.8));
  }
  PVector pos = new PVector(random(width/2) + width/4, random(height/2) + height/4);
  float cw = random(cogWidth[0], cogWidth[1]);
  float td = cw * random(toothDepth[0], toothDepth[1]);
  for(int i = 0; i < maxCogs; i++){
    
    cog(pos.x, pos.y, cw, random(TWO_PI), td, int(random(teeth[0],teeth[1])), random(cw*1.5), lerpColor(c[0],c[1],float(i)/maxCogs),0);
    boolean foundSpace = false;
    float cwn = 0;
    float tdn = 0;
    PVector npos = new PVector(0,0);
    for(int j = 0; j < perseverence; j++)
    {
      cwn = random(cogWidth[0], cogWidth[1]);
      tdn = cwn * random(toothDepth[0], toothDepth[1]);
      PVector next = PVector.random2D().mult(cw+cwn+5);
      npos = new PVector(pos.x, pos.y).add(next);
      boolean collided = false;
      if(npos.x < cwn || npos.x > width-cwn || npos.y < cwn || npos.y > height-cwn) collided = true;
      for(cog c: cogs){
        if(c.inRadius(npos, cwn)){
          collided = true;
          
          break;
        }
      }
      if(collided == false){
        foundSpace = true;
        break;
      }
    }
    if(!foundSpace) break;
    pos = npos;
    cw = cwn;
    td = tdn;
  }
}

void draw(){}

void cog(float xp, float yp, float radius, float startAngle, float toothDepth, int teeth, float centreHole, color colour, float damage){
  pushMatrix();
  translate(xp, yp);
  strokeWeight(strokeWeight);
  stroke(lc);
  float tradius = radius - toothDepth;
  float arcAngle = TWO_PI/float(teeth*2);
  rotate(startAngle);
  fill(colour, alpha);
  for(int i = 0; i < teeth*2; i++){
    if(i % 2 == 0){
      arc(0, 0, radius*2, radius*2, 0, arcAngle);
    }
    else{
      arc(0, 0, tradius*2, tradius*2, 0, arcAngle);
    }
    rotate(arcAngle);
    line(tradius, 0, radius, 0);
  }
  noStroke();
  ellipse(0, 0, tradius*2, tradius*2);
  stroke(lc);
  strokeWeight(strokeWeight);
  fill(bgc);
  if(centreHole > 0){
    ellipse(0, 0, centreHole, centreHole);
    //cog(0, 0, tradius/2, 0, random(tradius/8), int(random(4)) + 6, 0);
  }
  float dspace = tradius - (centreHole/2);
  while(damage > 0){
    //strokeWeight(1);
    rotate(random(PI/16));
    float sp = centreHole/2 + random(dspace/2);
    float ep = sp + random(dspace/8);
    stroke(0,0,1,30);
    line(sp,random(-5,5),ep,random(-5,5));
    damage -= 0.01;
  }
  popMatrix();
  cogs.add(new cog(xp, yp, radius));
}

void keyPressed()
{
  if (keyCode==32) {
    saveFrame("cog-"+hour()+"-"+minute()+"-"+second()+".png");
  }
  if (keyCode==10) {
    setup();
  }
}
