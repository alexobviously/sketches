// made by alex
// iamalexbaker@gmail.com

int n_cubes = 4;
float box_size = 100;
float phase, colour_phase = 0;
float move_dist = 100;
color[] c = new color[n_cubes];
color[] d = new color[n_cubes];
float colour_spread = 110;
void setup()
{
  size(800, 800, P3D);
  rectMode(CENTER);
  fill(51);
  stroke(255);
  noStroke();
  for (int i = 0; i < c.length; i++) 
  {
    float cc = random(255);
    c[i] = color(constrain(cc+random(colour_spread)-colour_spread/2, 0, 255), constrain(cc+random(colour_spread)-colour_spread/2, 0, 255), constrain(cc+random(colour_spread)-colour_spread/2, 0, 255), 255 - (255/c.length+1)*i);
    d[i] = color(constrain(cc+random(colour_spread)-colour_spread/2, 0, 255), constrain(cc+random(colour_spread)-colour_spread/2, 0, 255), constrain(cc+random(colour_spread)-colour_spread/2, 0, 255), 255 - (255/c.length+1)*i);
  }
  //translate(width/2,height/2,0);
}

void draw()
{
  background(230);
  translate(width/2, height/2, 0);
  rotateX(phase*0.01);
  rotateY(phase*0.008);
  rotateZ(phase*-0.007);

  float cl = abs(sin(colour_phase * PI/4));
  if (cl >= 1.0) {
    colour_phase = 0.0;
    cl = 0;
    for (int i = 0; i < c.length; i++)
    {
      float cc = random(255);

      c[i] = d[i];
      d[i] = color(constrain(cc+random(colour_spread)-colour_spread/2, 0, 255), constrain(cc+random(colour_spread)-colour_spread/2, 0, 255), constrain(cc+random(colour_spread)-colour_spread/2, 0, 255), 255 - (255/c.length+1)*i);
    }
  }
  cube(box_size/2, lerpColor(c[0], d[0], cl), -PI/32, move_dist/2);
  cube(box_size, lerpColor(c[1], d[1], cl), PI/32, move_dist);
  cube(box_size*2, lerpColor(c[2], d[2], cl), -PI/32, move_dist*2);
  cube(box_size*3, lerpColor(c[3], d[3], cl), PI/32, move_dist*3);

  phase += 0.1;
  colour_phase += 0.01;
}

void cube(float size, color fc, float phase_rate, float m_d) {
  pushMatrix();
  fill(fc);
  float rot_offset = sin(phase_rate * phase);
  float offset = abs(rot_offset) * m_d;

  rotateY(TWO_PI * rot_offset);
  rotateZ(PI * rot_offset);
  // L/R
  pushMatrix();
  translate(size/2 + offset, 0, 0);
  rotateY(PI/2);
  rect(0, 0, size, size);
  translate(0, 0, -(size+offset*2));
  rect(0, 0, size, size);
  popMatrix();
  // T/B
  pushMatrix();
  translate(0, -size/2 - offset, 0);
  rotateX(PI/2);
  rect(0, 0, size, size);
  translate(0, 0, -(size+offset*2));
  rect(0, 0, size, size);
  popMatrix();
  // B/F
  pushMatrix();
  translate(0, 0, size/2 + offset);
  rotateZ(PI/2);
  rect(0, 0, size, size);
  translate(0, 0, -(size+offset*2));
  rect(0, 0, size, size);
  popMatrix();
  popMatrix();
}
