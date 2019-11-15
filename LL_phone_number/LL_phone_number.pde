void setup()
{
  //size(800,600);
  fullScreen(P2D, 2);
  background(230);
  stroke(40);
  noStroke();
  fill(40);
  textSize(96);
  textAlign(CENTER,CENTER);
}

void draw(){}

void newNumber(){
  String nn = "0";
  nn = nn + int(random(9)+1);
  for(int i = 0; i < 9; i++) nn = nn + int(random(10));
  background(230);
  fill(random(20)+200,128);
  rect(0,height/2 - 85,width,200);
  fill(40);
  text(nn, width/2, height/2);
}

void mousePressed(){
  newNumber();
}

void keyPressed(){
  if(keyCode==32){
    newNumber();
  }
}
