// made by alex
// iamalexbaker@gmail.com
// dailygenerative.art.blog

int cols;
int rows;
float[][] o;
float[][] n;
float damping = 0.995;
color col;
color bgc;

void setup(){
  size(600,600);
  cols = width;
  rows = height;
  o = new float[cols][rows];
  n = new float[cols][rows];
  colorMode(HSB, TWO_PI, 1, 1);
  col = color(random(TWO_PI), random(0.5)+0.5, random(0.5)+0.5);
  bgc = color(0,0,0.2);
}

void mouseDragged(){
  o[mouseX][mouseY] = 50;
}

void draw(){
  println(frameRate);
  background(230);
  loadPixels();
  for(int i = 1; i < cols - 1; i++){
    for(int j = 1; j < rows - 1; j++){
      n[i][j] = (o[i-1][j] + o[i+1][j] + o[i][j-1] + o[i][j+1]) / 2 - n[i][j];
      n[i][j] = n[i][j] * damping;
      int index = i + j * cols;
      pixels[index] = lerpColor(bgc, col, n[i][j]);
    }
  }
  updatePixels();
  float[][] temp = o;
  o = n;
  n = temp;
}
