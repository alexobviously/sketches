import java.util.Map;
import oscP5.*;
OscP5 oscP5;

int rectWidth = 100;
int rectHeight = 100;
int rectX = 520;
int rectY = 360;

// to keep track of how long since the last overlap of right hand and rectangle
//float timeDifference = 0;

public class Keypoint{
  PVector position;
  float score;
  public Keypoint(){
    this.position = new PVector(0,0);
    this.score = 0;
  }
}

class usTwo {
  //color c;
  float xpos, ypos;
  float xspeed;
  boolean playing = false;
  long timeTriggered;
 
  usTwo() {
    //c = color(100, 0, 0);
    xpos = -30;
    ypos = height / 2;
    xspeed = 1;
  }
 
  void display() {
    //rectMode(CENTER);
    //fill(c);
    rect(xpos, ypos, 20, 10);
  }
 
  void play() {
    if (playing) {
      
      xpos = width / 2;
      /*xpos = xpos + xspeed;
      if (xpos > width+20) {
        xpos = -20;
      }
      */
    }
  }
 
  void triggerPlaying() {
    timeTriggered = millis();
    playing = true;
  }
  
 void triggerStopping() {
    xpos = -30;
    timeTriggered = 0;
    playing = false;
  } 
}
 
usTwo myUsTwo;

public class Pose{
  HashMap<String,Keypoint > keypoints;
  float score;
  boolean inside;
  public Pose(){
    this.keypoints = new HashMap<String,Keypoint>();
    this.score = 0;
  }
}
Pose[] poses = new Pose[0];
int nPoses = 0;

public void settings() {
  size(640, 480);
  //print("setting");
}

//----------------------------------
void setup() {
  //print("setup");
  OscProperties myProperties = new OscProperties();
  // increase the datagram size to 10000 bytes
  // by default it is set to 1536 bytes
  // https://processing.org/discourse/beta/num_1189011577.html
  myProperties.setDatagramSize(10000); 
  myProperties.setListeningPort(9527);
  
  oscP5 = new OscP5(this, myProperties);
  oscP5.plug(this,"parseData","/poses/xml");
  
  myUsTwo = new usTwo();
  
}

void drawHand(Pose pose, String part0){
  HashMap<String,Keypoint> keypoints;
  try{
    keypoints = pose.keypoints;
  }catch(Exception e){
    //print("meh");
    return;//meh
  }
  
  if (!keypoints.containsKey(part0)){
    //print("no part 0");
    return;
  }
  /*if (!keypoints.containsKey(part1)){
    //print("no part 1");
    return;
  }*/

  PVector p0 = keypoints.get(part0).position;
  //PVector p1 = keypoints.get(part1).position;
  //line(p0.x,p0.y,p1.x,p1.y);
  
  float handX = 640-p0.x;
  float handY = p0.y;
  
  long timeDifference = millis() - myUsTwo.timeTriggered;
  print("timedifference: "+timeDifference+" \n");
  
  if (handX > rectX && handX < rectX + rectWidth && handY > rectY && handY < rectY + rectHeight) {
    
    if(timeDifference <= 3000){
      print("need time \n");
    } else {
      myUsTwo.triggerPlaying();
      print("playing \n");
    }
    
    fill(0, 255, 0);
  } 
  else {
    
    if(timeDifference > 3000){
      print("stopping \n");
      myUsTwo.triggerStopping();
    }
    fill(255, 0, 0);
  }
  
  circle(handX,handY, 15);
  
}

//----------------------------------
void draw() {
  background (180);
  fill(0);
  stroke(0);
  myUsTwo.play();
  myUsTwo.display();
  rect(rectX, rectY, rectWidth, rectHeight);
  fill(204, 102, 0);
  stroke(204, 102, 0);
  for (int i = 0; i < nPoses; i++){
    drawHand(poses[i],"rightWrist");
  }
}

//----------------------------------
public void parseData(String data){
  
  XML xml = parseXML(data);
  nPoses = xml.getInt("nPoses");
  int w = xml.getInt("videoWidth");
  int h = xml.getInt("videoHeight");
  
  if (w != width || h != height){
    surface.setSize(w,h);
  }
  
  poses = new Pose[nPoses];
  XML[] xmlposes = xml.getChildren("pose");
  for (int i = 0; i < xmlposes.length; i++){
    XML[] xmlkeypoints = xmlposes[i].getChildren("keypoint");
    
    poses[i] = new Pose();
    poses[i].score = xmlposes[i].getFloat("score");
    
    for (int j = 0; j < xmlkeypoints.length; j++){
      Keypoint kpt = new Keypoint();
     
      kpt.position.x = xmlkeypoints[j].getFloat("x");
      kpt.position.y = xmlkeypoints[j].getFloat("y");
      kpt.score = xmlkeypoints[j].getFloat("score");
      
      poses[i].keypoints.put(xmlkeypoints[j].getString("part"), kpt);
    }
  }

}
