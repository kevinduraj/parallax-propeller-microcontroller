''--------------------------------------------------------------------'
'' Emphasizes interactions between circuits and multiple cogs
'' Test RC circuit decay measurements controlled by potenciometer.
'' Written by: Kevin Duraj
''--------------------------------------------------------------------'
CON
  _clkmode      = xtal1 + pll16x
  _xinfreq      = 5_000_000
  POTENCIOMETER = 25
  'scale        = 16_777_216   ' 2^32 / 256
  scale         = 42_949_672   ' 2^32 / 100
  LED1          = 8
  MAX_DECAY     = 6520
  MIN_DECAY     = 45
  MAXIMUM       = 100

VAR
  long duty
  long stack[300]
  long wave

OBJ
  pst : "Parallax Serial Terminal"


PUB Main | time, cog1

  ' Initialize boud rate for terminal
  ' Changed Terminal to run on Cog 7 by default
  pst.Start(115_200)

  coginit(1, DimLED, @stack[150])
  waitcnt(clkfreq/2 + cnt)

  ctra[30..26] := %01000
  ctra[5..0]   := POTENCIOMETER
  frqa         := 1

  repeat
    dira[POTENCIOMETER]~~
    outa[POTENCIOMETER]~~
    waitcnt(clkfreq/100_000 + cnt)       ' Wait for circuit to charge
    phsa~                                ' Clear the phsa register
    dira[POTENCIOMETER]~                 ' Pin to input stops charging circuit

    repeat 22
      waitcnt(clkfreq/60 + cnt)

   time := (phsa - 624) #> 0
   duty := time
   waitcnt(clkfreq/2 + cnt)

PUB DimLED | level, decay, wait

  ctra[30..26] := %00110
  ctra[5..0]   := LED1
  frqa         := duty * scale

  dira[LED1]~~

  '---- Calculate the flash period --------'
  decay := (MAX_DECAY - MIN_DECAY) / MAXIMUM

  repeat

    if(duty > MIN_DECAY)
      level := duty/decay
    else
      level := 0

    if(level > MAXIMUM)
      level := MAXIMUM

    wave := level * scale
    frqa := wave
    wait := duty/decay

    pst.Str(String(pst#NL, "Range = "))
    pst.Dec(level)

    pst.Str(String(pst#NL, "Wave = "))
    pst.Dec(wave)

    pst.Str(String(pst#NL, "Decay = "))
    pst.Dec(decay)

    pst.Str(String(pst#NL, "Duty = "))
    pst.Dec(duty)

    pst.Str(String(pst#NL, "Wait = "))
    pst.Dec(wait)
    pst.NewLine

    if(wait < 1)
      wait := 1

    waitcnt(clkfreq/(wait) + cnt)          ' Frequency of dim



