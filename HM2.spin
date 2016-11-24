{-----------------------------------------------------------------------------
  Assignment 3: Kevin Duraj
 -----------------------------------------------------------------------------}
CON
  _clkmode      = xtal1 + pll16x
  _xinfreq      = 5_000_000

  START         = 4
  END           = 15

  PUSHBUTTON3   = 18
  PUSHBUTTON2   = 17
  PUSHBUTTON1   = 16

VAR
  Byte signal
  Byte stopcogs
  long stack[70]

'-----------------------------------------------------------------------------'
' Executed Main on Cog0
'-----------------------------------------------------------------------------'
PUB Main

  dira[3]~~
  stopcogs := signal := 0

  repeat

    if ina[PUSHBUTTON3] == 1
      stopcogs := signal := 0
      outa[3]~~
      coginit(2, ControlButtons, @stack[40])
      waitcnt(clkfreq / 2 + cnt)

    if stopcogs == 1
      outa[3]~
      cogstop(1)
      cogstop(2)
      waitcnt(clkfreq / 2 + cnt)

  waitcnt(clkfreq / 2 + cnt)

'-----------------------------------------------------------------------------'
' LED Operation on Cog1
'   1. Turns all LEDs off
'   2. Wait for signals from cog 2
'   3. Flashes LEDs as directed by cog 2
'-----------------------------------------------------------------------------'
PUB FlashLEDs

  dira[4..15]~~
  outa[4..15]~

  repeat
      if signal == 1
        ! outa[4..7]
        waitcnt(clkfreq / 4 + cnt)
      elseif signal == 2
        ! outa[12..15]
        waitcnt(clkfreq / 4 + cnt)
      elseif signal == 3
        ! outa[8..11]
        waitcnt(clkfreq / 4 + cnt)
      elseif signal == 4
        outa[4..15]~
        waitcnt(clkfreq / 4 + cnt)
      else
        signal := 1
        waitcnt(clkfreq / 4 + cnt)

      waitcnt(clkfreq / 2 + cnt)


'-----------------------------------------------------------------------------'
' Control Buttons on Cog 2
'-----------------------------------------------------------------------------'
PUB ControlButtons

  repeat
    if ina[PUSHBUTTON2] == 1
      stopcogs := 1
      waitcnt(clkfreq / 4 + cnt)

    if ina[PUSHBUTTON1] == 1
      signal++
      waitcnt(clkfreq / 4 + cnt)
      coginit(1, FlashLEDs, @stack[20])

    waitcnt(clkfreq / 4 + cnt)

'-----------------------------------------------------------------------------'

