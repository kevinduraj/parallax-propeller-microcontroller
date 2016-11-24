'-----------------------------------------------------------------------------------'
' Assignment # 1
' Kevin Duraj
'-----------------------------------------------------------------------------------'

CON
  _clkmode      = xtal1 + pll1x
  _xinfreq      = 5_000_000

  LED1_GREEN    = 4
  LED1_YELLOW   = 5
  LED1_RED      = 6

  LED2_GREEN    = 7
  LED2_YELLOW   = 8
  LED2_RED      = 9

  PUSHBUTTON1   = 16
  PUSHBUTTON2   = 17

  LONG_PAUSE    = 5
  SHORT_PAUSE   = 2

'-----------------------------------------------------------------------------------'
VAR
  Byte cycles
  long stack[10]

PUB ButtonBlinkSpeed | counter

  cycles := 10
  ' Send on/of (3.3V/0 V) signals at approximately 2Hz
  dira[LED1_GREEN..LED2_RED]~~

  ' State 1 - Initial State
  outa[LED1_GREEN]   := %0
  outa[LED1_YELLOW]  := %0
  outa[LED1_RED]     := %1

  outa[LED2_GREEN]   := %1
  outa[LED2_YELLOW]  := %0
  outa[LED2_RED]     := %0
  'waitcnt(clkfreq / SHORT_PAUSE + cnt)  ' Short Pause

'-----------------------------------------------------------------------------------'
  repeat

    'State 1: Light 1 going Green
    outa[LED1_GREEN]  := %0
    outa[LED1_YELLOW] := %0
    outa[LED1_RED]    := %1
    waitcnt(clkfreq / SHORT_PAUSE + cnt)  ' Short Pause

    '---------------------- 1. Long Wait ------------------------------
    outa[LED2_GREEN]  := %1
    outa[LED2_YELLOW] := %0
    outa[LED2_RED]    := %0

    counter := 0
    repeat while ina[PUSHBUTTON1] == 0 AND counter < cycles
      waitcnt(clkfreq / SHORT_PAUSE + cnt)  ' Short Pause
      counter++
    '----------------------------------------------------------------

    'State 3: Light 2 going Yellow
    outa[LED2_GREEN]  := %0
    outa[LED2_YELLOW] := %1
    waitcnt(clkfreq / SHORT_PAUSE + cnt)  ' Short Pause

    outa[LED2_YELLOW] := %0
    outa[LED2_RED]    := %1
    waitcnt(clkfreq / SHORT_PAUSE + cnt)  ' Short Pause


    '---------------------- 2. Long Wait ------------------------------
    outa[LED1_GREEN]  := %1
    outa[LED1_RED]    := %0
    counter := 0
    repeat while ina[PUSHBUTTON2] == 0 AND counter < cycles
      waitcnt(clkfreq / SHORT_PAUSE + cnt)  ' Short Pause
      counter++
    '----------------------------------------------------------------

    outa[LED1_GREEN]  := %0
    outa[LED1_YELLOW] := %1
    waitcnt(clkfreq / SHORT_PAUSE + cnt)  ' Short Pause

'-----------------------------------------------------------------------------------'

