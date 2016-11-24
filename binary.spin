'--------------------------------------------------------------'
' Propeller Paralax Binary Counter
'--------------------------------------------------------------'

CON
  _clkmode      = xtal1 + pll1x
  _xinfreq      = 5_000_000

  START = 16
  END   = 23


PUB Main
  dira[END..START]~~
  outa[END..START]~

  repeat
    waitcnt(clkfreq / 2 + cnt)
    outa[END..START]++


