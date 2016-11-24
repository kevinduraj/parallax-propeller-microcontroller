'' Homework
'' Test RC circuit decay measurements.
CON
  _clkmode      = xtal1 + pll16x
  _xinfreq      = 5_000_000
  POTENCIOMETER = 25
  scale     = 16_777_216
  LED1          = 8
  MAX_DECAY     = 6520
  MIN_DECAY     = 45

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
    waitcnt(clkfreq/100_000 + cnt)          ' Wait for circuit to charge
    phsa~                                   ' Clear the phsa register
    dira[POTENCIOMETER]~                    ' Pin to input stops charging circuit

    repeat 22
      waitcnt(clkfreq/60 + cnt)

   time := (phsa - 624) #> 0
   'pst.Str(String(pst#NL, "Potenciometer = "))
   'pst.Dec(time)
   duty := time
   waitcnt(clkfreq/2 + cnt)

PUB DimLED | range, current_decay

  ctra[30..26] := %00110
  ctra[5..0]   := LED1
  frqa         := duty * scale

  dira[LED1]~~
  current_decay := (MAX_DECAY - MIN_DECAY) / 255

  repeat

    'repeat duty from 0 to 255

    if(duty > MIN_DECAY)
      range := duty/current_decay
    else
      range := 0

    if(range > 255)
      range := 255

    wave := range * scale

    pst.Str(String(pst#NL, "Range = "))
    pst.Dec(range)

    pst.Str(String(pst#NL, "Wave = "))
    pst.Dec(wave)

    frqa := wave
    waitcnt(clkfreq/2 + cnt)          ' Frequency of dim

    'repeat range from 0 to 255
    '  wave := range * scale
    '  pst.Str(String(pst#NL, "wave = "))
    '  pst.Dec(wave)
    '  frqa := wave
    '  waitcnt(clkfreq/128 + cnt)          ' Frequency of dim


