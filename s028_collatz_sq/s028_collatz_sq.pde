// made by alex
// iamalexbaker@gmail.com
// dailygenerative.art.blog

// https://en.wikipedia.org/wiki/Collatz_conjecture

int do_draw = 1;
float[] len = {10, 10};
float[] angle = {-PI/2, PI/2, 0};
int[] start = {1000000, 2000000, 0};
int[] num = {10000, 20000, 0};
float[] size = {1, 5, 0};
float[] weights = {1,10,0,50}; // probability of {line, circle, square, blank}
PVector origin;
int nc = 2;
color[] c = new color[nc];
float colour_spread = 80;
float alpha = 30;
void setup() {
  size(800, 800);
  rectMode(CENTER);
  strokeWeight(1);
  do_draw = 1;
  origin = new PVector(random(width/2)+width/4, random(height/2)+height/4);
  start[2] = int(random(start[0], start[1]));
  num[2] = int(random(num[0], num[1]));
  size[2] = random(size[0], size[1]);
  angle[2] = random(angle[0], angle[1]);
  for (int i = 0; i < nc; i++) {
    c[i] = dullColour(colour_spread);
  }
}

void draw() {
  if (do_draw == 0) return;
  background(50);
  stroke(255,10);
  fill(255,10);
  cycle(start[2], start[2]+num[2], angle[2], 0, origin);

  do_draw = 0;
}

void cycle(int s, int e, float a, float r, PVector o)
{
  for (int i = s; i < e; i++) {
    LongList seq = new LongList();
    resetMatrix();
    translate(o.x, o.y);
    rotate(r);
    long n = i;
    int steps = 0;
    do {
      seq.append(n);
      n = collatz(n);
      steps++;
    } while (n != 1);
    seq.append(1);
    seq.reverse();
    for (int j = 0; j < seq.size(); j++)
    {
      long value = seq.get(j);
      if (value % 2 == 0) {
        rotate(a);
      } else {
        rotate(-a);
      }
      float l = random(len[0], len[1]);

      int t = selectWeighted(weights);
      fill(lerpColor(c[0], c[1], float(j)/seq.size()), alpha);
      stroke(lerpColor(c[0], c[1], float(j)/seq.size()), alpha);
      switch(t){
        case 1:
          ellipse(0, 0, size[2], size[2]);
          break;
        case 2:
          rect(0, 0, size[2], size[2]);
          break;
        default:
        case 3:
          break;
        case 0:
          line(0, 0, 0, l);
          break;
      }
      translate(0, l);
    }
  }
}

long collatz(long n) {
  if (n % 2 == 0) {
    return n / 2;
  } else {
    return (3*n + 1) / 2;
  }
}

void keyPressed()
{
  if (keyCode==32) {
    saveFrame("csq-"+hour()+"-"+minute()+"-"+second()+".png");
  }
  if (keyCode==10) {
    setup();
  }
}

color dullColour(float spread)
{
  color col;
  float x = random(255);
  col = color(constrain(x + random(spread) - spread/2, 0, 255), constrain(x + random(spread) - spread/2, 0, 255), constrain(x + random(spread) - spread/2, 0, 255));
  return col;
}

// function to randomly select an array index from an array of weights
int selectWeighted(float[] w){
  int total = 0;
  for(float ww: w) total += ww;
  float r = random(total);
  int n = 0;
  for(float ww: w){
    r -= ww;
    if(r <= 0) return n;
    n++;
  }
  return w.length;
}
