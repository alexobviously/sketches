// made by alex
// iamalexbaker@gmail.com

import com.hamoid.*; // using Video Export library
boolean recording = false;
VideoExport videoExport;

PVector origin;
float len = 20;
int sides = 3;
int rate = 60;
int reset_state = 20000;
float colour_spread = 180;
int chain_length = 14000;
float angle;
int state, sc, cs;
ArrayList<Integer> turns = new ArrayList<Integer>();
color[] c = new color[2];



void setup()
{
  size(800,800);
  smooth();
  frameRate(30);
  
  videoExport = new VideoExport(this);
  videoExport.setDebugging(false);
  
  origin = new PVector(random(width), random(height));
  state = 1; // no divide by zero
  cs = 1;    //
  strokeWeight(1);
  stroke(50,10);
  turns.clear();
  for(int i = 0; i < 2; i++)
  {
    c[i] = dullColour(colour_spread);
  }
}

void draw()
{
  sc = 0;
  translate(origin.x, origin.y);
  angle = TWO_PI/sides;
  background(230);
  int k = 0;
  
  do{
    //println(sc+ " "+state+" "+float(sc)/state);
    if(sc >= state - chain_length){
      stroke(lerpColor(c[0], c[1], float(sc - (state-chain_length)) / chain_length),30);
      line(0,0,0,len);
    }
    translate(0, len);
    if(sc % reset_state == reset_state - 1)
    {
      resetMatrix();
      translate(origin.x, origin.y);
    }
    if(sc % sides == sides-1){
      if(turns.size() <= k){
        turns.add(int(random(sides)));
        //println("add turn");
      }
      for(int j = 0; j < turns.get(k); j++)
      {
        rotate(angle);
        translate(0, len);
      }
      k++;
      angle *= -1;
      rotate(angle);
    } else {
      rotate(angle);
    }
    sc++;
  } while(sc < state);
  
  if (recording) {
    videoExport.saveFrame();
  }
  
  state += rate;
}

color dullColour(float spread)
{
  color col;
  float x = random(255);
  col = color(constrain(x + random(spread) - spread/2, 0, 255), constrain(x + random(spread) - spread/2, 0, 255), constrain(x + random(spread) - spread/2, 0, 255));
  return col;
}

void keyPressed()
{
  if (keyCode==32) {
    saveFrame("tess-"+hour()+"-"+minute()+"-"+second()+".png");
  }
  if (keyCode==10) {
    setup();
  }
  
  if(keyCode==82){ // R
    recording = !recording;
    if(recording == true){
      videoExport.setMovieFileName(hour()+"-"+minute()+"-"+second() + ".mp4");
      videoExport.startMovie();
      println("Started recording");
    }
    else{
      println("Finished recording");
      videoExport.endMovie();
    }
  }
}
