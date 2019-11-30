void setup(){
  size(400,400);
  noStroke();
  float sh = 6;
  float bigt = TWO_PI / sh;
  float r = width/2;
  float crd2 = r * sin(bigt/2);
  translate(width/2, height/2);
  for(float i = 0; i < TWO_PI; i += PI/64){
    float x = r * cos(i);
    float y = r * sin(i);
    fill(30);
    ellipse(x, y, 5, 5);
    
    float t = i % bigt;
    fill(200,0,0, 150);
    x = r * cos(t);
    y = r * sin(t);
    ellipse(x, y, 5, 5);
    
    float rr = crd2 / (tan(abs(bigt/2)) * cos(abs(bigt/2 - t)));
    //float rr = crd2 / tan(abs(bigt/2));
    fill(0, 0, 200, 150);
    x = rr * cos(i);
    y = rr * sin(i);
    ellipse(x, y, 5, 5);
  }
}
