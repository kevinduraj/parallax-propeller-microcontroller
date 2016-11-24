''My First Program: Kevin Duraj

CON
  _clkmode      = xtal1 + pll1x
  _xinfreq      = 5_000_000

  LED1_START    = 4
  LED1_END      = 6

  LED2_START    = 7
  LED2_END      = 9

  PUSHBUTTON1   = 16
  PUSHBUTTON2   = 18
  PUSHBUTTON3   = 20

VAR
  Byte  wait
  long stack[60]

PUB Main | cog1, cog2, cog3
  wait := 2

  repeat

    if ina[PUSHBUTTON1] == 1
      cog1 := cognew(FlashLED(4,4), @stack[0])
      waitcnt(clkfreq / wait + cnt)

    if ina[PUSHBUTTON2] == 1
      cog2 := cognew(FlashLED(5,4), @stack[20])
      waitcnt(clkfreq / wait + cnt)

    if ina[PUSHBUTTON3] == 1
      cog3 := cognew(FlashLED(6,4), @stack[40])
      waitcnt(clkfreq / wait + cnt)

PUB FlashLED(p1, p2) | counter

  dira[p1]~~
  counter:=0

  repeat while counter < 100
    outa[p1] := 1
    waitcnt(clkfreq / wait + cnt)
    outa[p1] := 0
    waitcnt(clkfreq / wait + cnt)
    counter++


