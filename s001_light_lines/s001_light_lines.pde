void setup(){
  size(400,400);
  background(192,64,0);
  stroke(255,255,255,16);
  line(150,25,270,350);
}
void draw(){
  int x;
  for(x=0;x<10;x++){
    line(random(width),random(height),mouseX,mouseY);
  }
}

void mousePressed(){
  background(random(256),random(256),random(256));
}
