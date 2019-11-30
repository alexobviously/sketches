// made by alex
// iamalexbaker@gmail.com
// dailygenerative.art.blog

float r;

void setup() {
  size(800, 800);
  background(220);
  translate(width/2, height/2);
  
  // Initialize all values
  float a = random(100,width/2);
  float k = int(random(1,80))/8;
  float yo = random(2,6);
  float aa = random(0.5);
  float b = random(10);
  color c = dullColour(40,10,60);
  color cc = dullColour(80,50,100);
  float ff = random(0.01, 9);
  float fg = random(0.01, 0.07);
  float[] cons = {150, 250};
  
  for(float t = 0; t < 1000; t += 1){
    r = sin(t*ff)/4 * 600 + a*cos(t*k+yo) - fg*tan(t/yo);
    //r = constrain(cos(t)*ff + fg, 65, 640);
    float x = r * sin(t);
    float y = r * cos(r);
    ellipseMode(CENTER);
    noStroke();
    fill(lerpColor(c,cc,cos(t)/tan(t)),120);
    ellipse(x, y, 4, 4);
    pushMatrix();
    translate(x,y);
    for(float u = 0; u < 1000; u += 15){
      float rr = u * aa + b;
      float xx = (rr * tan(u)); 
      float yy = (rr*sin(u));
      ellipse(xx,yy,2,2);
      println(t+" "+u);
    }
    popMatrix();
  }
}

void draw() {
  
}

void keyPressed()
{
  if (keyCode==32) {
    saveFrame("rose-"+hour()+"-"+minute()+"-"+second()+".png");
  }
  if (keyCode==10) {
    setup();
  }
}
color dullColour(float spread, float min, float max)
{
  color col;
  float x = random(min, max);
  col = color(constrain(x + random(spread) - spread/2, 0, 255), constrain(x + random(spread) - spread/2, 0, 255), constrain(x + random(spread) - spread/2, 0, 255));
  return col;
}
