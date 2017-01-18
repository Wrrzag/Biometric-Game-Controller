import processing.serial.*;
import java.util.Queue;
import java.util.ArrayDeque;

int HISTORY_SIZE = 50;
int MIN_TREND = 10; // The minimum same changes to take the trend as descending or ascending
float ZX_DEADZONE_STEP = 0.3;
float ZY_DEADZONE_STEP = 0.3;
int ZX_MAX_DEADZONE = 60;
int ZX_MIN_DEADZONE = 20;
int ZY_MAX_DEADZONE = 100;
int ZY_MIN_DEADZONE = 50;
float STANDARD_DISTANCE_TO_SCREEN = 70;
float MIN_ZOOM = 0.5;
float MAX_ZOOM = 2.0;


Serial myport;
int BPM;         
int zx;
int zy;
float dist;
Queue<Integer> bpmHistory;
int bpmTrend;
Queue<Integer> gsrHistory;
int gsrTrend;
float zxDeadzone, zyDeadzone;
float zoomMultiplier;
int gsr;


void setup(){
  size(800,600);
  //noLoop();
  frameRate(100);
  printArray(Serial.list());
  myport=new Serial(this,Serial.list()[2],115200);
  myport.bufferUntil('\n');
  
  bpmHistory = new ArrayDeque(HISTORY_SIZE);
  gsrHistory = new ArrayDeque(HISTORY_SIZE);
  zxDeadzone = zyDeadzone = 0;
  zoomMultiplier = 1;
}

void draw(){
  background(0);

  text("Distance: ", 5, 10);
  rect(65, 1, map(dist, 2, 400, 0, 800), 10);
  System.out.println("DIST: " + dist);
  System.out.println("ZX:   " + zx);
  System.out.println("ZY:   " + zy);
  System.out.println("BPM:  " + BPM);
  System.out.println("GSR:  " + gsr);
  
  text("ZX:             " + zx, 5, 25);
  text("ZY:             " + zy, 5, 40);
  text("BPM:          " + BPM, 5, 55);
  text("GSR:          " + gsr, 5, 70);


  int currentTrend = calculateHR();
  if(currentTrend == 1) { // Increasing
    text("HEARTBEAT TREND: INCREASING", 5, 95);
  }
  else if(currentTrend == 0) { // Same
    text("HEARTBEAT TREND: SAME", 5, 95);
  }
  else { // Decreasing
    text("HEARTBEAT TREND: DECREASING", 5, 95);
  }
  
  bpmTrend += currentTrend;
  if(bpmTrend >= MIN_TREND * 2) {
    zxDeadzone += ZX_DEADZONE_STEP;
    zyDeadzone += ZY_DEADZONE_STEP;
    bpmTrend = MIN_TREND;
  }
  else if(bpmTrend <= 0) {
   zxDeadzone -= ZX_DEADZONE_STEP;
   zyDeadzone -= ZY_DEADZONE_STEP;
   bpmTrend = MIN_TREND;
  }
  zxDeadzone = min(zxDeadzone, ZX_MAX_DEADZONE);
  zxDeadzone = max(zxDeadzone, ZX_MIN_DEADZONE);
  zyDeadzone = min(zyDeadzone, ZY_MAX_DEADZONE);
  zyDeadzone = max(zyDeadzone, ZY_MIN_DEADZONE);
  
  
  
  currentTrend = calculateGSR();
  if(currentTrend == 1) { // Increasing
    text("GSR TREND: INCREASING", 5, 110);
  }
  else if(currentTrend == 0) { // Same
    text("GSR TREND: SAME", 5, 110);
  }
  else { // Decreasing
    text("GSR TREND: DECREASING", 5, 110);
  }
  
  gsrTrend += currentTrend;
  if(gsrTrend >= MIN_TREND * 2) {
    zxDeadzone += ZX_DEADZONE_STEP;
    zyDeadzone += ZY_DEADZONE_STEP;
    gsrTrend = MIN_TREND;
  }
  else if(gsrTrend <= 0) {
   zxDeadzone -= ZX_DEADZONE_STEP;
   zyDeadzone -= ZY_DEADZONE_STEP;
   gsrTrend = MIN_TREND;
  }
  zxDeadzone = min(zxDeadzone, ZX_MAX_DEADZONE);
  zxDeadzone = max(zxDeadzone, ZX_MIN_DEADZONE);
  zyDeadzone = min(zyDeadzone, ZY_MAX_DEADZONE);
  zyDeadzone = max(zyDeadzone, ZY_MIN_DEADZONE);
  
  
  text("CONTROLLER DEADZONE: ZX = " + zxDeadzone + ", ZY = " + zyDeadzone, 5, 140);
  
  
  
  String dir = "STOPPED";
  
  if(zy > 200 + zyDeadzone){
    dir = "MOVE FORWARD";
  }
  // Turning overrides moving forward
  if(zx < 100 - zxDeadzone){
    dir = "TURN LEFT";
  }
  else if(zx > 100 + zxDeadzone){
    dir = "TURN RIGHT";
  }
  
  text("MOVEMENT DIRECTION: " + dir, 5, 125);

  
  
  zoomMultiplier = map(dist, 2, STANDARD_DISTANCE_TO_SCREEN*2, MIN_ZOOM, MAX_ZOOM);  
  zoomMultiplier = min(zoomMultiplier, MAX_ZOOM);
  zoomMultiplier = max(zoomMultiplier, MIN_ZOOM);
  
  text("ZOOM MULTIPLIER " + zoomMultiplier, 5, 155);
  
  
  redraw = true;
}

int checkTrend(Queue<Integer> history) {
  if(history == null || history.size() == 0) return 0;
  
  int first = history.element();
  int gt = 0;
  int lt = 0;
 
  for(Integer bpm : history) {
     if(first > bpm) lt++;
     else if(first < bpm) gt++;
  }
 
  if(gt > lt) return 1;
  else if(lt > gt) return -1;
  else return 0; 
}

int calculateHR() {
  int toRet = 0;
  
  if(BPM < 180 && BPM > -20){ 
   if(bpmHistory.size() >= HISTORY_SIZE) bpmHistory.poll();
    bpmHistory.add(BPM);
       
       //////////////////////////////////////////////////////////////////7
    print("HR QUEUE: [");
    for(Integer i:bpmHistory) print("|"+i);
    println("]");
    ///////////////////////////////////////////////////////////////////////
  
    toRet = checkTrend(bpmHistory);
  }
  
  return toRet;
}

int calculateGSR () {
  int toRet = 0;
  
  if(gsr < 60 && gsr > -60){ 
    if(gsrHistory.size() >= HISTORY_SIZE) gsrHistory.poll();
      gsrHistory.add(gsr);
         
         //////////////////////////////////////////////////////////////////7
      print("GSR QUEUE: [");
      for(Integer i:gsrHistory) print("|"+i);
      println("]");
      ///////////////////////////////////////////////////////////////////////
    
      toRet = checkTrend(gsrHistory); 
  }
  
  return toRet;
}