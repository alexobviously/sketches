// made by alex
// iamalexbaker@gmail.com
// dailygenerative.art.blog

float dA = 1.2; // 1.0
float dB = 0.3; // 0.5
float feed = 0.075; // 0.055
float k = 0.062; // 0.062
float rate = 1.0; // 1.0

float o[][][];
float n[][][];

void setup(){
  size(600,600);
  frameRate(100);
  colorMode(HSB, TWO_PI, 1, 1);
  o = new float[width][height][2];
  n = new float[width][height][2];
  
  for(int i = 0; i < width; i++){
    for(int j = 0; j < height; j++){
      float x = 1;//random(0.5)+0.3;
      o[i][j][0] = x;
      n[i][j][0] = x;
      if(i >= 300 && i <= 350 && j >= 300 && j <= 350) o[i][j][1] = random(1);
    }
  }
  
  for(float r = 0; r < TWO_PI; r += PI/96){
    int x = int(200+ sin(r) * 150);
    int y = int(200+ cos(r) * 150);
    o[x][y][1] = 1;
    o[x][y+1][1] = 1;
    o[x+1][y][1] = 1;
    o[x+1][y+1][1] = 1;
  }
}

void draw(){
  //background(230);
  drawGrid();
  reactionDiffusion();
  println(frameCount+" "+frameRate);
}

void drawGrid(){
  loadPixels();
  for(int i = 0; i < width; i++){
    for(int j = 0; j < height; j++){
      //set(i, j, color(0, 0, o[i][j][0] - o[i][j][1])); // slower
      pixels[i + j * width] = color(PI/6, o[i][j][0], o[i][j][1]);//1 - (o[i][j][0] - o[i][j][1])); // faster
    }
  }
  updatePixels();
}

void reactionDiffusion(){
  for(int i = 0; i < width; i++){
    for(int j = 0; j < height; j++){
      
      float a = o[i][j][0];
      float b = o[i][j][1];
      n[i][j][0] = a + rate * ((dA * convolve(i,j,0))
                   - (a * b * b)
                   + (feed * (1-a)))
                   ;
      n[i][j][1] = b + rate * ((dB * convolve(i,j,1))
                   + (a * b * b) 
                   - (b * (k + feed)))
                   ;
      n[i][j][0] = constrain(n[i][j][0], 0, 1);
      n[i][j][1] = constrain(n[i][j][1], 0, 1);
    }
  }
  o = n;
  //n = new float[width][height][2];
  // ^^ this somehow changes something, keeping it would actually be correct,
  // but removing it gives us 10fps and it looks cooler, idk why
}

float convolve(int x, int y, int g){
  float sum = 0;
  
  for(int i = x-1; i <= x+1; i++){
    for(int j = y-1; j <= y+1; j++){
      int p = 0;
      float mult = 0;
      if(i < 0 || i >= width || j < 0 || j >= height) continue;
      if(i != x) p++;
      if(j != y) p++;
      switch(p){
        default:
          mult = 0;
          break;
        case 0:
          mult = -1;
          break;
        case 1:
          mult = 0.2;
          break;
        case 2:
          mult = 0.05;
          break;
      }
      sum += o[i][j][g] * mult;
    }
  }
  
  return sum;
}

void keyPressed()
{
  if (keyCode==32) {
    saveFrame("rd-"+hour()+"-"+minute()+"-"+second()+".png");
  }
  if (keyCode==10) {
    setup();
  }
}
