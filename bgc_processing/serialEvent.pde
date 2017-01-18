void serialEvent(Serial port){ 
   String inData = port.readStringUntil('\n');
   inData = trim(inData);                
   
   if (inData.charAt(0) == 'B'){          
     inData = inData.substring(1);        
     BPM = int(inData);                  
   }
   if (inData.charAt(0) == 'X'){           
     inData = inData.substring(1);      
     zx = int(inData);                
   }
   if (inData.charAt(0) == 'Y'){        
     inData = inData.substring(1);    
     zy = int(inData);                
   }
   if (inData.charAt(0) == 'D'){        
     inData = inData.substring(1);     
     dist = int(inData);               
     //dist = map(dist, 2, 400, 0, 800);
   }
   if (inData.charAt(0) == 'G'){         
     inData = inData.substring(1);     
     gsr = int(inData);                 
   }
}