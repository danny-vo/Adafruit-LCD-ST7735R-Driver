# Adafruit-LCD-ST7735R-Driver
Software written for TI TM4C123 Launchpad for interfacing output with the Adafruit LCD.  
Files worked on include IO.s, LCD.s, Print.s  
End product displays a test image followed by several decimal numbers represented by floating point (implemented with ARM Assembly) 
using a recursive algorithm to output to the LCD.  
  
Hardware used:  
- Adafruit ST7735R LCD  
- On-board negative logic switches (mapped to PortF4 and PortF0) to refresh LCD screen  
- On-board LEDs (mapped to PortF1-3) for debugging hearbeat
