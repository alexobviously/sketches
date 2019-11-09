// made by alex
// iamalexbaker@gmail.com

PImage img;
color c1 = color(0,90,102);
color c2 = color(102,0,40);
color c3 = color(230,230,230);
float freq = 1.0;
float freq_mult = 1.0;
float f = freq;
void setup()
{
  /*println((c1>>16)&0xFF);r
  println((c1>>8)&0xFF);g
  println(c1&0xFF);b*/
  size(1000,400);
  textSize(24);
  freq_mult = TWO_PI/width;
  background(230);
  img = createImage(width,height,RGB);
}

void draw()
{
  background(c3);
  img.loadPixels();
  for(int i =0 ;i<img.pixels.length;i++)
  {
    if(random(2.0)-1<sin((i%img.width)*freq*freq_mult)){
      float xp = (float(i%img.width)/float(width))+((float(i)/float(width))/float(height*6));
      //println((i%img.width)+" "+width+" "+xp);
      img.pixels[i] = lerpColor(c2,c1,xp);
    }
    else{
      img.pixels[i] = c3;
    }
  }
  img.updatePixels();
  image(img,0,0);
  freq *= random(0.05)+0.98;
  text(freq,10,30);
}
