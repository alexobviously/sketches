import java.awt.image.BufferedImage;
import javax.imageio.plugins.jpeg.*;
import javax.imageio.*;
import javax.imageio.stream.*;

PImage img;
int next = 0;
int frame = 1;

int saveFrames = 0;

void setup(){
  size(437,584);
  img = loadImage("gau.png");
  image(img,0,0);
}

void draw(){
  if(next>0)
  {
    String fn = "gau-p.jpg";
    if(saveFrames==1) fn = "gau"+frame+".jpg";
    else fn = "gau-proc.jpg";
    jpg(fn,random(1.0));
    img = loadImage(fn);
    image(img,0,0);
    next = 0;
    frame++;
  }
}

void keyPressed()
{
  if(keyCode==32){
    next = 1;
  }
  if(keyCode==10){
     setup();
  }
}

public void jpg(String filename, float comp)
{
    // set the amount of compression
  // 1.0 = no compression, largest image file
  // 0.5 = 50% compression
  // 0.0 = 100% compression, smallest image file
  float compressionLevel = comp;
  
  // image to compress and image to output        
  String outputFilename = sketchPath("") + filename;

  try {

    // setup JPG output
    JPEGImageWriteParam jpegParams = new JPEGImageWriteParam(null);
    jpegParams.setCompressionMode(ImageWriteParam.MODE_EXPLICIT);
    jpegParams.setCompressionQuality(compressionLevel);
    final ImageWriter writer = ImageIO.getImageWritersByFormatName("jpg").next();
    writer.setOutput(new FileImageOutputStream(new File(outputFilename)));

    // output to BufferedImage object
    // create the object, then write the pixel data to it
    BufferedImage out = new BufferedImage(img.width, img.height, BufferedImage.TYPE_INT_RGB);
    for (int i=0; i<img.pixels.length; i++) {
      out.setRGB(i%img.width, i/img.width, img.pixels[i]);
    }

    // save it!
    writer.write(null, new IIOImage(out, null, null), jpegParams);
    println("Saved!");
  }
  catch (Exception e) {
    println("Problem saving... :(");
    println(e);
  }
}
