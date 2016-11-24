'' TestRcDecay.spin
'' Test RC circuit decay measurements.
CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000
  POT      = 25

OBJ
  pst : "Parallax Serial Terminal"

PUB Init
  pst.Start(115_200)
  ctra[30..26] := %01000
  ctra[5..0]   := POT
  frqa         := 1
  main

PUB Main | time

  repeat
    dira[POT] := outa[POT] := 1             ' Set pin to output-high
    waitcnt(clkfreq/100_000 + cnt)          ' Wait for circuit to charge
    phsa~                                   ' Clear the phsa register
    dira[POT]~                              ' Pin to input stops charging circuit
    pst.Str(String(pst#NL, pst#NL, "Working on other tasks", pst#NL))

    repeat 22
      pst.Char(".")
      waitcnt(clkfreq/60 + cnt)

   time := (phsa - 624) #> 0
   pst.Str(String(pst#NL, "time = "))
   pst.Dec(time)
   waitcnt(clkfreq/2 + cnt)

