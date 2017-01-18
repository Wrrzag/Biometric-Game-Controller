
#define DEBUG 0

// HR
#define pulsePin 0 

// ACCEL
#define G_2  0x00
#define G_4  0x01
#define G_8  0x02 
#define G_16 0x03

//Devide Address 
#define DEVICE_ADDRESS 0x53  

//Registers Address - ADXL345
#define POWER_CTL 0x2D
#define DATA_FORMAT  0x31
#define DATAX0  0x32  //X-Axis Data 0
#define DATAX1  0x33 //X-Axis Data 1
#define DATAY0  0x34 //Y-Axis Data 0
#define DATAY1  0x35 //Y-Axis Data 1
#define DATAZ0  0x36 //Z-Axis Data 0
#define DATAZ1  0x37 //Z-Axis Data 1

#include <Wire.h>

// DISTANCE
#define TRIG_PIN 3
#define ECHO_PIN 2


// GSR
#define GSR_PIN 2





// these variables are volatile because they are used during the interrupt service routine!
volatile int BPM;                   // used to hold the pulse rate
volatile int Signal;                // holds the incoming raw data
volatile int IBI = 600;             // holds the time between beats, the Inter-Beat Interval
volatile boolean Pulse = false;     // true when pulse wave is high, false when it's low
volatile boolean QS = false;        // becomes true when Arduoino finds a beat.
int zx;
int zy;
long dist;


void setup(){
  Serial.begin(115200);             // we agree to talk fast!
  interruptSetup();                 // sets up to read Pulse Sensor signal every 2mS 
   // UN-COMMENT THE NEXT LINE IF YOU ARE POWERING The Pulse Sensor AT LOW VOLTAGE, 
   // AND APPLY THAT VOLTAGE TO THE A-REF PIN
   //analogReference(EXTERNAL);   

  Wire.begin();
  writeTo(DEVICE_ADDRESS, DATA_FORMAT, G_2);  //ADXL345 Range +- 2G
  writeTo(DEVICE_ADDRESS, POWER_CTL, 0x00);   //Reset  - Power Control
  writeTo(DEVICE_ADDRESS, POWER_CTL, 0x10);   //ADXL in Standby mode
  writeTo(DEVICE_ADDRESS, POWER_CTL, 0x08);   //ADXL in Measure mode

  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);
}



void loop(){
  if (QS == true){                       
        sendData('B',BPM);  
        QS = false;                      
     }

  readAccel();
  if(DEBUG) { 
    Serial.print("\nANGLE ZY: ");
    Serial.print(zy);
    Serial.print("\nANGLE ZX: ");
    Serial.println(zx);
  }

  sendData('X', zx);
  sendData('Y', zy);
  

  readDist();
  if(DEBUG) { 
    Serial.print("\nDIST: ");
    Serial.println(dist);
  }

  sendData('D', dist);


  int gsr = analogRead(GSR_PIN);
  if(DEBUG) { 
    Serial.print("\nGSR: ");
    Serial.println(gsr);
  }
  
  sendData('G', gsr);
  
  delay(100);                           
}


void sendData(char symbol, int data ){
    Serial.print(symbol);                // symbol prefix tells Processing what type of data is coming
    Serial.println(data);                // the data to send culminating in a carriage return
  }







