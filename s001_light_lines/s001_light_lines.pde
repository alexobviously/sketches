color light = color(255,255,255);
color shadow = color(0,0,0);
int intensity = 16;

boolean useShadow = false;

void setup(){
  size(400,400);
  background(192,64,0);
}
void draw(){
  int x;
  stroke(useShadow ? shadow : light, intensity);
  for(x=0;x<10;x++){
    line(random(width),random(height),mouseX,mouseY);
  }
}

void toggleStrokeColour(){
  useShadow = !useShadow;
}

void randomBackground(){
  background(random(256),random(256),random(256));
}

void changeIntensity(int amt){
  intensity += amt;
  intensity = constrain(intensity, 0, 255);
}

void mousePressed(){
  randomBackground();
}

void keyPressed(){
  println(keyCode);
  if(keyCode == 32) { // Space
    String fn = "ll-"+hour()+"-"+minute()+"-"+second()+".png";
    saveFrame(fn);
    println("Saved image: "+fn);
  }
  if(keyCode == 10) { // Enter
    randomBackground();
  }
  if(keyCode == 67) { // C
    toggleStrokeColour();
  }
  if(keyCode == 87) changeIntensity(1);  // W
  if(keyCode == 83) changeIntensity(-1); // S
}
