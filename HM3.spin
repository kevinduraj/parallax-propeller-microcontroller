'' Homework
'' Test RC circuit decay measurements.
CON
  _clkmode      = xtal1 + pll16x
  _xinfreq      = 5_000_000
  POTENCIOMETER = 25
  scale         = 16_777_216
  LED1          = 8

VAR
  Byte RESISTANCE
  long stack[120]

OBJ
  pst : "Parallax Serial Terminal"

PUB Init | i, cog1, cog2
  pst.Start(115_200)            ' Initialize boud rate for terminal
  'ctra[30..26] := %01000
  'ctra[5..0]   := POT
  'frqa         := 1
  ''main

  'coginit(1, Main, @stack[10])
  'coginit(2, DimLED, @stack[40])

  cog1 := cognew(Main, @stack[10])
  pst.NewLine
  pst.Str(String(pst#NL, "Cog1 = "))
  pst.Dec(cog1)
  pst.NewLine

  waitcnt(clkfreq/2 + cnt)

  cog2 := cognew(DimLED, @stack[60])
  pst.NewLine
  pst.Str(String(pst#NL, "Cog2 = "))
  pst.Dec(cog2)
  pst.NewLine

  'waitcnt(clkfreq/2 + cnt)

PUB Main | time

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

    repeat 10
      pst.Char(".")
      waitcnt(clkfreq/30 + cnt)

   time := (phsa - 624) #> 0
   pst.Str(String(pst#NL, "Resistance = "))
   pst.Dec(time)
   RESISTANCE := time
   waitcnt(clkfreq/2 + cnt)

PUB DimLED | duty, mode

  ctra[30..26] := %00110
  ctra[5..0]   := LED1
  frqa         := duty * scale

  dira[LED1]~~

  repeat

    repeat duty from 0 to 255
      frqa := duty * scale
      waitcnt(clkfreq/128 + cnt)          ' Frequency of dim

    repeat duty from 255 to 0
      frqa := duty * scale
      waitcnt(clkfreq/128 + cnt)          ' Frequency of dim

