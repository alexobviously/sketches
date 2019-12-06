// made by alex
// iamalexbaker@gmail.com
// dailygenerative.art.blog

// https://en.wikipedia.org/wiki/Reaction–diffusion_system

float dA = 1.2; // 1.0
float dB = 0.3; // 0.5
float dC = 0.3;
float feed = 0.055; // 0.055
float k = 0.052; // 0.062
float rate = 1.0; // doesn't really work as expected but definitely does Something
int chemicals = 3; // changing this won't do anything yet
boolean randomFill = true;
int colourMode = 0; // 0: white / 2 colours, 1: black / 2 colours, 2: ???
int seedMode = 2; // 0: squares and arcs, 1: dividing line w/ circles, 2: split circle

float o[][][];
float n[][][];

float[] col = new float[2];
float gradient;

void setup(){
  size(600,600);
  frameRate(100);
  colorMode(HSB, TWO_PI, 1, 1);
  o = new float[width][height][3];
  n = new float[width][height][3];
  
  col[0] = random(TWO_PI);
  col[1] = random(TWO_PI);
  for(int i = 0; i < width; i++){
    for(int j = 0; j < height; j++){
      float x = 1;//random(0.5)+0.3;
      o[i][j][0] = x;
      n[i][j][0] = x;
      //if(i >= 300 && i <= 350 && j >= 300 && j <= 350) o[i][j][2] = random(1);
    }
  }
  if(seedMode==0){
    for(int k = 0; k < 50; k++){
      populateArc(1, random(width), random(height), random(TWO_PI), random(TWO_PI), random(50) + 10, PI/96, 2);
      populateRect(2, random(width), random(height), random(50)+10, random(50)+10, 1);
    }
  } else if(seedMode==1){
    gradient = random(-2,2);
    if(gradient==0) gradient = 0.1;
    for(int k = 0; k < 50; k++){
      float x = random(width);
      float y = random(height);
      int chem;
      if(y - height/2 > gradient * (x - width/2)){
        chem = 1;
      } else { chem = 2; }
      populateArc(chem, x, y, 0, TWO_PI, random(10) + 10, PI/48, 2);
    }
  } else if(seedMode==2){
    for(int k = 0; k < 10; k++){
      splitCircle(random(width), random(height), random(TWO_PI), random(100)+150, PI/96, 2);
    }
  }
}

void populateRect(int chem, float xp, float yp, float w, float h, float density){
  for(int x = int(xp - w/2); x < xp + w/2; x++){
    for(int y = int(yp - h/2); y < yp + h/2; y++){
      if(x < 0 || y < 0 || x >= width || y >= height) continue;
        o[x][y][chem] = (randomFill)?random(1):1;
    }
  }
}

void splitCircle(float xp, float yp, float startAngle, float radius, float step, int thickness){
  populateArc(1, xp, yp, startAngle, PI, radius, step, thickness);
  populateArc(2, xp, yp, startAngle + PI, PI, radius, step, thickness);
}

void populateArc(int chem, float xp, float yp, float startAngle, float arcAngle, float radius, float step, int thickness){
  for(float r = startAngle; r < startAngle + arcAngle; r += step){
    int x = int(xp + sin(r) * radius);
    int y = int(yp + cos(r) * radius);
    if(x < 0 || y < 0 || x >= width || y >= height) continue;
    for(int i = x - thickness; i <= x + thickness; i++){
      if(i > 0 && i < width){
        for(int j = y - thickness; j <= y + thickness; j++){
          if(j > 0 && j < height){
            o[i][j][chem] = (randomFill)?random(1):1;
          }
        }
      }
    }
  }
}

void draw(){
  //background(230);
  drawGrid();
  reactionDiffusion();
  //println(frameCount+" "+frameRate);
}

void drawGrid(){
  loadPixels();
  float hue;
  for(int i = 0; i < width; i++){
    for(int j = 0; j < height; j++){
      float a = o[i][j][0];
      float b = o[i][j][1];
      float c = o[i][j][2];
      if(b >= c){
        hue = lerp(col[0], col[1], c/b);
      }else{
        hue = lerp(col[1], col[0], b/c);
      }
      switch(colourMode){
        default:
        case 0:
          pixels[i + j * width] = color(hue, constrain((b+c),0,1), 1-constrain((b+c),0,1));
          break;
        case 1:
          pixels[i + j * width] = color(hue, constrain((b+c),0,1), constrain((b+c),0,1));
          break;
        case 2:
          pixels[i + j * width] = color(col[0] + constrain((b+c),0,1)*TWO_PI, hue/TWO_PI, 1-constrain((b+c),0,0.8));
          break;
      }
    }
  }
  updatePixels();
}

void reactionDiffusion(){
  for(int i = 0; i < width; i++){
    for(int j = 0; j < height; j++){
      
      float a = o[i][j][0];
      float b = o[i][j][1];
      float c = o[i][j][2];
      n[i][j][0] = a + rate * ((dA * convolve(i,j,0,1))
                   - (a * (b*b + c*c))
                   + (feed * (1-a)));
      n[i][j][1] = b + rate * ((dB * convolve(i,j,1,1))
                   + (a * b * b) 
                   - (b * (k + feed)));
      n[i][j][2] = c + rate * ((dC * convolve(i,j,2,1))
                   + (a * c * c)
                   - (c * (k + feed)));
      n[i][j][0] = constrain(n[i][j][0], 0, 1);
      n[i][j][1] = constrain(n[i][j][1], 0, 1);
      n[i][j][2] = constrain(n[i][j][2], 0, 1);
    }
  }
  o = n;
  //n = new float[width][height][2];
  // ^^ this somehow changes something, keeping it would actually be correct,
  // but removing it gives us 10fps and it looks cooler, idk why
}

float convolve(int x, int y, int g, float r){
  float sum = 0;
  float[] m = new float[3];
  
  m[0] = -1 * r;
  m[1] = 0.2 * r;
  m[2] = 0.05 * r;
  
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
          mult = m[0];
          break;
        case 1:
          mult = m[1];
          break;
        case 2:
          mult = m[2];
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
