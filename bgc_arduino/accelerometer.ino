
byte _buff[6];
 
void readAccel() {
  
  uint8_t numBytesToRead = 6;

  //Reading registers
  readFrom(DEVICE_ADDRESS, DATAX0, numBytesToRead, _buff);
 
  //each axis reading comes in 10 bit resolution, ie 2 bytes
  //Least Significant byte first!!
  //thus we are converting both bytes into one int
  int x = (((int)_buff[1]) << 8) | _buff[0];   
  int y = (((int)_buff[3]) << 8) | _buff[2];
  int z = (((int)_buff[5]) << 8) | _buff[4];
  
  //Mapping values from min/max calibration measures to known values [-100,+100]
  int xAng = map(x, -259, 259, -100, 100); 
  int yAng = map(y, -260, 268, -100, 100);  
  int zAng = map(z, -247, 260, -100, 100); 

  // Z-Y Angle
  zy = map(RAD_TO_DEG * (atan2(-zAng, -yAng) + PI), 0, 360, 0, 801);  

  // Z-X Angle
  zx = map(RAD_TO_DEG * (atan2(-zAng, -xAng) + PI), 0, 360, 0, 401);    
}
 
//Funcion auxiliar de escritura
void writeTo(int device, byte address, byte val) {
  Wire.beginTransmission(device);
  Wire.write(address);
  Wire.write(val);
  Wire.endTransmission(); 
}
 
//Funcion auxiliar de lectura
void readFrom(int device, byte address, int num, byte _buff[]) {
  Wire.beginTransmission(device);
  Wire.write(address);
  Wire.endTransmission();
 
  Wire.beginTransmission(device);
  Wire.requestFrom(device, num);
 
  int i = 0;
  while(Wire.available())
  { 
    _buff[i] = Wire.read();
    i++;
  }
  Wire.endTransmission();
}

