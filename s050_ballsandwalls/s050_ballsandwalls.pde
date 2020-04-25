int numWalls = 10;
ArrayList<boundary> walls;

int numBalls = 1500;
ArrayList<ball> balls;
float maxBallVel = 5f;

boolean drawPoints = false;
boolean randomStarts = false;

void setup(){
  size(800, 800);
  walls = new ArrayList<boundary>();
  walls.add(new boundary(0,0,width,0));
  walls.add(new boundary(0,0,0,height));
  walls.add(new boundary(0,height,width,height));
  walls.add(new boundary(width,0,width,height));
  for(int i = 0; i < numWalls; i++){
    walls.add(new boundary(random(width), random(height), random(width), random(height)));
  }
  PVector startpos = new PVector(random(width), random(height));
  balls = new ArrayList<ball>();
  for(int i = 0; i < numBalls; i++){
    if(randomStarts) startpos = new PVector(random(width), random(height));
    balls.add(new ball(startpos, new PVector(random(-maxBallVel, maxBallVel), random(-maxBallVel, maxBallVel)), color(random(0,150), random(0,150), random(0,150)), random(5,20)));
  }
}

void draw(){
  background(220);
  for(boundary b: walls){
    b.show();
  }
  for(ball b: balls){
    b.tick();
    b.show();
  }
  println(frameRate);
}

class ball{
  PVector pos, vel;
  color colour;
  float size;
  boundary lastHit = null;
  
  ball(PVector _pos, PVector _vel, color _c, float _s){
    pos = new PVector(_pos.x, _pos.y); vel = new PVector(_vel.x, _vel.y); colour = _c; size = _s;
  }
  
  void tick(){
    // http://www.jeffreythompson.org/collision-detection/line-circle.php
    for(boundary b: walls){
      if(b == lastHit) continue;
      float dot = ( ((pos.x-b.a.x)*(b.b.x-b.a.x)) + ((pos.y-b.a.y)*(b.b.y-b.a.y)) ) / (b.len * b.len);
      float closestX = b.a.x + (dot * (b.b.x-b.a.x));
      float closestY = b.a.y + (dot * (b.b.y-b.a.y));
      if(!linePoint(new PVector(closestX, closestY), b)) continue;
      if(drawPoints){
        stroke(colour);
        noFill();
        rectMode(CENTER);
        rect(closestX, closestY, 10, 10);
      }
      float distX = closestX - pos.x;
      float distY = closestY - pos.y;
      float d2 = (distX * distX) + (distY * distY);
      if(d2 <= size){
        PVector ref = PVector.sub(vel, PVector.mult(b.normal, PVector.dot(vel, b.normal)*2));
        vel = ref;
        lastHit = b;
        break;
      }
    }
    
    pos.add(vel);
  }
  void show(){
    noStroke();
    fill(colour);
    ellipse(pos.x, pos.y, size, size);
  }
}

class boundary{
  PVector a, b, normal;
  float len;
  
  boundary(float x1, float y1, float x2, float y2){
    a = new PVector(x1, y1); b = new PVector(x2, y2);
    len = PVector.dist(a, b);
    normal = PVector.fromAngle(atan2(b.y - a.y, b.x - a.x)-PI/2);
  }
  
  void show(){
    stroke(30);
    strokeWeight(1);
    line(a.x, a.y, b.x, b.y);
  }
}

boolean linePoint(PVector p, boundary b) {

  float x1 = b.a.x;
  float x2 = b.b.x;
  float y1 = b.a.y;
  float y2 = b.b.y;
  float px = p.x;
  float py = p.y;
  // get distance from the point to the two ends of the line
  float d1 = dist(px,py, x1,y1);
  float d2 = dist(px,py, x2,y2);

  // get the length of the line
  float lineLen = dist(x1,y1, x2,y2);

  // since floats are so minutely accurate, add
  // a little buffer zone that will give collision
  float buffer = 0.1;    // higher # = less accurate

  // if the two distances are equal to the line's
  // length, the point is on the line!
  // note we use the buffer here to give a range,
  // rather than one #
  if (d1+d2 >= lineLen-buffer && d1+d2 <= lineLen+buffer) {
    return true;
  }
  return false;
}
