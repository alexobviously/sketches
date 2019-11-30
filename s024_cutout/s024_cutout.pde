int segments = 64;

float seg_angle;

void setup(){
  size(800,800);
  background(30);
  noStroke();
  colorMode(HSB,360,100,100);
  seg_angle = TWO_PI/segments;
  
  PGraphics pg;
  PImage mask, img;
  pg = createGraphics(width,height);
  pg.beginDraw();
  //pg.background(50); < - interesting
  float w = random(width/4, width);
  fill(255);
  for(int j = 0; j < segments; j++){
    w = constrain(w + random(-width/20, width/20),width/4, width);
    pg.arc(width/2,height/2,w,w,j*seg_angle,(j+1)*seg_angle);
  }
  pg.endDraw();
  mask = pg.get();
  pg.beginDraw();
  pg.background(50);
  pg.colorMode(HSB,360,100,100);
  for(int i = 0; i < 15000; i++){
    pg.fill(random(360),random(50),random(50));
    pg.ellipse(random(width), random(height), 5,5);
  }
  pg.endDraw();
  img = pg.get();
  img.mask(mask);
  fill(240,30,30);
  ellipse(width/2,height/2,width*1.05,height*1.05);
  for(int k = 0; k < segments; k++){
    fill((360/segments) * k,30,30);
    arc(width/2, height/2, width, height, k * seg_angle, (k+1)*seg_angle);
  }
  
  image(img,0,0);
  
}

void draw(){}
