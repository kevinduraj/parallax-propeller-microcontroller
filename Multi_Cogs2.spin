'---------------------------------------------------------------'
'               Assignment 2: Kevin Duraj
'---------------------------------------------------------------'
CON
  _clkmode      = xtal1 + pll16x
  _xinfreq      = 5_000_000

  START         = 4
  END           = 7

  PUSHBUTTON3   = 18
  PUSHBUTTON2   = 17
  PUSHBUTTON1   = 16

VAR
  Byte  wait
  long stack[70]

OBJ
  'pst : "Parallax Serial Terminal"

'-----------------------------------------------------------------------------'
' Executed Main on Cog0
'-----------------------------------------------------------------------------'
PUB Main
  wait := 0

  repeat
    if ina[PUSHBUTTON1] == 1
      coginit(1, RedLEDs,        @stack[10])
      'coginit(2, YellowLEDs,     @stack[20])
      'coginit(3, GreenLEDs,     @stack[30])
      coginit(4, ControlButtons, @stack[40])
      coginit(5, MakeSound,      @stack[50])

    waitcnt(clkfreq / 4 + cnt)
    wait++

'-----------------------------------------------------------------------------'
' Executing Red LEDs
'-----------------------------------------------------------------------------'
PUB RedLEDs

  dira[4..7]~~
  outa[4..7]~

  repeat while 60 > wait
    waitcnt(clkfreq / 2 + cnt)
    outa[4..7]++

  wait := 0
'-----------------------------------------------------------------------------'
' Executing Yellow LEDs
'-----------------------------------------------------------------------------'
PUB YellowLEDs

  dira[8..11]~~
  outa[8..11]~

  repeat while 60 > wait
    waitcnt(clkfreq / 2 + cnt)
    outa[8..11]++

  wait := 0

'-----------------------------------------------------------------------------'
' Executing Green LEDs
'-----------------------------------------------------------------------------'
PUB GreenLEDs

  dira[12..15]~~
  outa[12..15]~

  repeat while 60 > wait
    waitcnt(clkfreq / 2 + cnt)
    outa[12..15]++

  wait := 0

'-----------------------------------------------------------------------------'
' Control Buttons
'-----------------------------------------------------------------------------'
PUB ControlButtons

  repeat
    if ina[PUSHBUTTON2] == 1
      cogstop(1)
      coginit(2, YellowLEDs, @stack[20])

    if ina[PUSHBUTTON3] == 1
      cogstop(2)
      coginit(3, GreenLEDs, @stack[30])

    waitcnt(clkfreq / 8 + cnt)

'-----------------------------------------------------------------------------'
' Executed Sound on Cog4
'-----------------------------------------------------------------------------'
PUB MakeSound | index

  ctra[30..26] := %00100
  ctra[5..0] := 27
  frqa := 0

  repeat index from 0 to 7
     frqa := long[@notes][index]

     dira[27]~~
     waitcnt(clkfreq/4 + cnt)

     dira[27]~
     waitcnt(clkfreq/4 + cnt)
'-----------------------------------------------------------------------------'
' Sound Data
'-----------------------------------------------------------------------------'
DAT
'80 MHz frqa values for square wave musical note approximations with the counter module
'configured to NCO:
'          C6      D6      E6      F6      G6      A6      B6       C7
notes long 56_184, 63_066, 70_786, 74_995, 84_181, 94_489, 105_629, 112_528, 126_127, 141_572, 149_948, 168_363, 188_979, 212_123, 224_734

