'--------------------------------------------------------------'
' Propeller Paralax Binary Counter
'--------------------------------------------------------------'

CON
  _clkmode      = xtal1 + pll1x
  _xinfreq      = 5_000_000

PUB Main
  dira[16]~~

  repeat
    waitcnt(clkfreq / 2 + cnt)
    outa[16]~~

