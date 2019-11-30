// made by alex
// iamalexbaker@gmail.com

// https://en.wikipedia.org/wiki/Collatz_conjecture

int do_draw = 1;
float[] len = {5, 15};
float angle = PI/32;
int start = 10000000;
int num = 8000;
PVector origin;
int n_sets = 1;
color[] c = new color[n_sets];
float colour_spread = 40;
void setup() {
  size(800, 800);
  strokeWeight(1);
  origin = new PVector(width, 0);
  for (int i = 0; i < n_sets; i++) {
    c[i] = dullColour(colour_spread);
  }
}

void draw() {
  if (do_draw == 0) return;
  background(50);

  //start += 10;
  //angle += random(-PI/128, PI/128);

  //translate(width/2, height);
  stroke(255,10);
  cycle(start, start+num, angle, 0, origin);
  //stroke(40,0,40,10);
  //cycle(start+num, start+num*2, angle, PI/2, origin);
  //stroke(180,230,255,5);
  //cycle(start+num*2, start+num*3, 4*angle/6, PI/2);
  
  //for (int i = 0; i < n_sets; i++)
  //{
  //  stroke(0, 10);
  //  cycle(start+num*i, start+num*(i+1), angle, (TWO_PI/n_sets)*i, origin);
  //}

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

      line(0, 0, 0, l);
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
    saveFrame("collatz-"+hour()+"-"+minute()+"-"+second()+".png");
  }
  if (keyCode==10) {
    setup();
  }
}

color dullColour(float spread)
{
  color col;
  float x = random(255);
  col = color(constrain(x + random(spread) - spread/2, 0, 255), constrain(x + random(spread) - spread/2 + 40, 0, 255), constrain(x + random(spread) - spread/2, 0, 255));
  return col;
}
