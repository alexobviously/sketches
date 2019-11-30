float noiseScale = 0.02;
int div = 40;
float dist;
float angle;
float phase = 0;
float m = 2;
color[] = new color[2];

void setup(){
  size(800,800);
  dist = width/div;
  angle = random(TWO_PI);
  m = random(2) + 1;

}
void draw(){
  background(230);
  translate(width/2,height/2);
  rotate(angle);
  translate(-width/2,-height/2);
  stroke(230);
  strokeWeight(3);
  //line(-dist,-dist,width+dist,-dist);
  //line(-dist,-dist,-dist,height+dist);
  //line(width+dist,-dist,width+dist,height+dist);
  //line(-dist,height+dist,width+dist,height+dist);
  fill(40,40,50);
  noStroke();

  for(int i = -div/4; i < div + div/4; i++){
    for(int j = -div/4; j < div + div/4; j++){
      float nv = noise(lerp(i,i*m, sin(phase)),lerp(j,j*m, sin(phase)));
      fill(
      ellipse(i*dist, j*dist, nv*50, nv*50);
    }
  }
  phase += 0.001;
}
void keyPressed()
{
  if(keyCode==32){
    saveFrame("reflections-"+hour()+"-"+minute()+"-"+second()+".png");
  }
  if(keyCode==10){
     setup();
  }
}
