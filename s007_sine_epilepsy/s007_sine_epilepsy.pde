float x = 25;
float amp = 150;
float a = 0.0;

float counter = 0;
float maxc = 10;

float r = 255;
float g = 255;
float b = 255;
float rgbchange = 12;
float rgbch = rgbchange/2 + 1;
void setup(){
  size(600,300);
  background(255);
}

void draw(){
  //a = 0;
  background(r,g,b);
  stroke(255-r,255-g,255-b);
  for(int i=0;i<width;i=i+4){
    line(i,height/2,i,(sin(a)*amp)+height/2);
    a += TWO_PI/x;
  }
  counter++;
  if(counter>maxc){
    x++;
    counter = 0;
    randombg();
  }
}

void randombg(){
  r = constrain(r + (random(rgbchange)-rgbch),0,255);
  g = constrain(g + (random(rgbchange)-rgbch),0,255);
  b = constrain(b + (random(rgbchange)-rgbch),0,255);
  if(r<10 && g<10 && b<10){
    rgbch = rgbchange/2 - 1;
  }
  if(r>245 && g>245 && b>245){
    rgbch = rgbchange/2 + 1;
  }
}
