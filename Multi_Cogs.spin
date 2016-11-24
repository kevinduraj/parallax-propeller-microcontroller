'-----------------------------------------------------------'
' Running Multi Cog LEDs
'-----------------------------------------------------------'
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
  long stack[120]

OBJ
  'pst : "Parallax Serial Terminal"

PUB Main | cog1, cog2, cog3, cog4, cog5, cog6
  'dira[4..9]~~
  wait := 4
  'cnt  := 1

  '---- Initialize Terminal ------'
  'pst.Start(115_200)
  'pst.Char(pst#CS)
  '-------------------------------'

  repeat

    'pst.Clear
    'pst.Position(0,0)
    'pst.NewLine
    'pst.Str(String("New Cog: "))
    'pst.Dec(cnt)
    'cnt++

    cog1 := cognew(FlashLED(4,100), @stack[0])
    waitcnt(clkfreq / wait + cnt)

    cog2 := cognew(FlashLED(5,100), @stack[20])
    waitcnt(clkfreq / wait + cnt)

    cog3 := cognew(FlashLED(6,100), @stack[40])
    waitcnt(clkfreq / wait + cnt)

    cog4 := cognew(FlashLED(7,100), @stack[60])
    waitcnt(clkfreq / wait + cnt)

    cog5 := cognew(FlashLED(8,100), @stack[80])
    waitcnt(clkfreq / wait + cnt)

    cog6 := cognew(FlashLED(9,100), @stack[100])
    waitcnt(clkfreq / wait + cnt)

PUB FlashLED(p1, p2) | counter

  dira[p1]~~
  counter:=0

  repeat while counter < p2

    'outa[p1] := 1
    'waitcnt(clkfreq * 4 + cnt)
    'outa[p1] := 0

    ! outa[p1]
    waitcnt(clkfreq * wait + cnt)
    counter++


