// made by alex
// iamalexbaker@gmail.com
// dailygenerative.art.blog

int num = 200;
float numRange = 200;
float alpha = 100;
float direction = -0.6;
int[] layers = {50,40,30,20,10};
boolean differentColourLayers = true;
boolean differentShapedLayers = true;
float[][] shape = {{0.5, 5, 1}, {0.5, 5, 1}, {0, 20, 0}, {0.5, 20, 1}, {0.001, TWO_PI, 0}, {0.001, TWO_PI, 0}};

float[] numbers = new float[num];
float[] pos = new float[num];

float div;
int nc = 2;
color[] c = new color[nc];

void setup(){
  size(800, 800);
  noStroke();
  colorMode(HSB, TWO_PI, 1, 1);
  background(PI/6,0,0.8);
  div = width/num;
  resetColours();
  randomShape();
  for(int k = 0; k < layers.length; k++){
    resetPos();
    if(differentShapedLayers) randomShape();
    if(differentColourLayers) resetColours();
    for(int j = 0; j < layers[k]; j++){
      newSort();
    }
  }
}

void newSort(){
  for(int i = 0; i < numbers.length; i++){
    numbers[i] = random(numRange);
  }
  quicksort(numbers, 0, numbers.length-1);
}

void quicksort(float[] A, int lo, int hi){
  //println("QS "+lo+" - "+hi);
  if(lo < hi){
    int p = partition(A, lo, hi);
    //println("pivot "+p+" value "+A[p]);
    quicksort(A, lo, p);
    quicksort(A, p + 1, hi);
  }
  else{
    //println("terminate index "+lo+" value "+A[lo]);
  }
}

int partition(float[] A, int lo, int hi){
  //println("PART "+lo+" "+hi);
  float pivot = A[lo+(hi-lo)/2];
  int i = lo - 1;
  int j = hi + 1;
  float temp;
  while(0==0){
    do{
      i++;
    } while (A[i] < pivot);
    do{
      j--;
    } while (A[j] > pivot);
    if(i >= j) return j;
    temp = A[i];
    A[i] = A[j];
    A[j] = temp;
    build(i, A[i]);
    build(j, A[j]);
  }
}

void randomShape(){
  for(float[] s: shape){
    s[2] = random(s[0], s[1]);
  }
}

void resetColours(){
  for (int i = 0; i < nc; i++) {
    c[i] = color(random(TWO_PI), random(0.8), random(0.8));
  }
}

void resetPos(){
  for(int i = 0; i < numbers.length; i++){
    if(direction < 0) pos[i] = height;
    if(direction >= 0) pos[i] = 0;
  }
}

void build(int index, float amt){
  fill(lerpColor(c[0], c[1], amt/200), alpha);
  rect(index*div, pos[index], div, div);
  pos[index] += direction* (((shape[0][2]>0)?abs(pow(cos(TWO_PI/(amt * shape[4][2])),shape[0][2]))*shape[1][2]:0) + ((shape[2][2]>0)?pow(tan(TWO_PI/(amt * shape[5][2])),shape[2][2])*shape[3][2]:0));
}

void draw(){}

void keyPressed()
{
  if (keyCode==32) {
    saveFrame("qs-"+hour()+"-"+minute()+"-"+second()+".png");
  }
  if (keyCode==10) {
    setup();
  }
}
