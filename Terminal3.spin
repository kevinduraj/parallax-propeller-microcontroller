{{ SoundImpactSensor_Simple.spin
Displays the current state of the output pin from the Sound Impact Sensor connected to P0
using the Parallax Serial Terminal. For P8X32A. }}

CON
_clkmode = xtal1 + pll16x ' System clock → 80 MHz
_xinfreq = 5_000_000

OBJ
pst : "Parallax Serial Terminal"

PUB Main
 dira[0]~ ' Set pin 0 to input
 pst.Start(115_200) ' Set Parallax Serial Terminal to 115,200 baud

 repeat

  if ina[0] == 1
  pst.Str(string("Sound detected!")) ' When noise is detected, display a message
  waitcnt(clkfreq + cnt) ' Wait 1 second
  pst.Clear ' Clear the Parallax Serial Terminal
  else
  pst.Str(string("All is well.")) ' If no sound detected, display all is well
  waitcnt(clkfreq/10 + cnt) ' Wait 1/10 of a second
  pst.Home ' Move cursor to the top left corner of the PST
