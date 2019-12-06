// made by alex
// iamalexbaker@gmail.com
// dailygenerative.art.blog

int cols;
int rows;
float[][][] o;
float[][][] n;
float damping = 0.999;
float[] intensity = {1,5,1};
boolean invertAxes = false; // don't use this if width != height
boolean invertColours = false;
boolean randomise = false;

int nc = 2;
color[] col = new color[2];
color bgc;
float[] params = new float[6];

void setup(){
  size(800,800);
  cols = width;
  rows = height;
  o = new float[cols][rows][3];
  n = new float[cols][rows][3];
  intensity[2] = random(intensity[0], intensity[1]);
  colorMode(HSB, TWO_PI, 1, 1);
  for(int i = 0; i < nc; i++){
    col[i] = color(random(TWO_PI), random(0.5)+0.5, random(0.5)+0.5);
  }
  bgc = color(0,0,0.8);
  colorMode(RGB, 255, 255, 255);
  params[0] = random(3)+0.5;
  params[1] = random(2)+0.5;
  params[2] = random(3);
  params[3] = random(2)+0.5;
  params[4] = random(3);
  params[5] = random(2) + 0.5;
}

void impulse(boolean invert, float a, float b, float c, float d, float e, float f){
  // random curve
  for(float x = 0; x < width; x++){
    float xx = x/width;
    float y = ((pow((xx),a)*b + tan(xx*TWO_PI*c)*d  + sin(xx*TWO_PI*e)*f)) * height;
    if(y > height || y < 0) continue;
    color newColour = lerpColor(col[0], col[1], xx);
    float rr = newColour >> 16 & 0xFF;
    float gg = newColour >> 8 & 0xFF;
    float bb = newColour & 0xFF;
    if(!invert){
      o[int(x)][int(y)][0] = rr*intensity[2];
      o[int(x)][int(y)][1] = gg*intensity[2];
      o[int(x)][int(y)][2] = bb*intensity[2];
    }
    else{
      o[int(y)][int(x)][0] = rr*intensity[2];
      o[int(y)][int(x)][1] = gg*intensity[2];
      o[int(y)][int(x)][2] = bb*intensity[2];
    }
  }
}

void mouseDragged(){
  if(mouseX<0||mouseX>width||mouseY<0||mouseY>height) return;
  o[mouseX][mouseY][0] = random(500);
  o[mouseX][mouseY][1] = random(500);
  o[mouseX][mouseY][2] = random(500);
}

void draw(){
  //println(frameRate);
  background(230);
  loadPixels();
  for(int i = 1; i < cols - 1; i++){
    for(int j = 1; j < rows - 1; j++){
      for(int k = 0; k < 3; k++){
        n[i][j][k] = (o[i-1][j][k] + o[i+1][j][k] + o[i][j-1][k] + o[i][j+1][k]) / 2 - n[i][j][k];
        n[i][j][k] = n[i][j][k] * damping;
      }
      int index = i + j * cols;
      if(invertColours){
        pixels[index] = color(255-n[i][j][0], 255-n[i][j][1], 255-n[i][j][2]);
      } else {
        pixels[index] = color(n[i][j][0], n[i][j][1], n[i][j][2]);
      }
    }
  }
  updatePixels();
  float[][][] temp = o;
  o = n;
  n = temp;
}

void keyPressed()
{
  if (keyCode==32) { // space
    saveFrame("ripple"+hour()+"-"+minute()+"-"+second()+".png");
  }
  if (keyCode==10) { // enter
    setup();
  }
  if(keyCode==90) { // Z
    if(randomise){
      impulse(invertAxes, random(3)+0.5, random(2)+0.5, random(3), random(2)+0.5, random(3), random(2)+0.5);
    } else {
      impulse(invertAxes, params[0], params[1], params[2], params[3], params[4], params[5]);
    }
  }
}
