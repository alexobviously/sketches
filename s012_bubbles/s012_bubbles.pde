// made by alex
// iamalexbaker@gmail.com

ArrayList<bubble> bubbles = new ArrayList<bubble>();
ArrayList<bubble> fast_bubbles = new ArrayList<bubble>();
ArrayList<pebble> pebbles = new ArrayList<pebble>();
PImage pebble_img;

float stream_location;
float stream_width = 20;

float bubble_rate = 50;
float pebble_rate = 3;

class bubble{
  float xp, yp, size, speed;
  ArrayList<bubble> parent_array;
  bubble(ArrayList<bubble> p_a, float x, float y, float sz, float sp){
    parent_array = p_a; xp = x; yp = y; size = sz; speed = sp;
  }
  void update(){
    yp -= speed;
    if(yp<0){
      parent_array.remove(this);
    }
    ellipse(xp,yp,size,size);
  }
}

class pebble{
  float xp, yp, size, speed, rotation, rot_speed, depth;
  ArrayList<pebble> parent_array;
  pebble(ArrayList<pebble> p_a, float x, float y, float sz, float r, float rs, float d){
    parent_array = p_a; xp = x; yp = y; size = sz; rotation = r; rot_speed = rs; depth = d;
  }
  void update(){
    yp += size / 10;
    if(yp>height){
      parent_array.remove(this);
    }
    rotation += rot_speed;
    pushMatrix();
    translate(xp+size/2, yp+size/2);
    rotate(rotation);
    tint(255,depth);
    image(pebble_img, -size/2, -size/2, size, size);
    popMatrix();
  }
}

void draw()
{
  background(160,160,180);
  if(random(100)<bubble_rate)
  {
    bubbles.add(new bubble(bubbles, random(width/3)*2+width/6,height,random(10),random(5)+0.01));
  }
  if(random(100)<bubble_rate*2)
  {
    bubbles.add(new bubble(fast_bubbles, stream_location + random(stream_width) - stream_width/2,height,random(5),random(10)+2));
  }
  if(random(100)<pebble_rate)
  {
    pebbles.add(new pebble(pebbles, random(width/3)*2+width/6,0,random(20)+10,random(TWO_PI),random(PI/16)-PI/32,random(32)+112));
  }
  for(int i = 0; i < pebbles.size(); i++)
  {
    pebbles.get(i).update();
  }
  for(int i = 0; i < bubbles.size(); i++)
  {
    bubbles.get(i).update();
  }
  for(int i = 0; i < fast_bubbles.size(); i++)
  {
    fast_bubbles.get(i).update();
  }
  if(random(1000)>990) bubble_rate++;
  //println(bubbles.size()+" "+pebbles.size()+" "+fast_bubbles.size());
  
}

void setup()
{
  size(600,800);
  noStroke();
  fill(240,240,240,128);
  pebble_img = loadImage("pebble.png");
  stream_location = random((width/3) - stream_width)*2 + width/6 + stream_width/2;
}

void mousePressed(){
  stream_location = random((width/3) - stream_width)*2 + width/6 + stream_width/2;
}
