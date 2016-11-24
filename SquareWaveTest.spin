''SquareWaveTest.spin
''Send 2093 Hz square wave to P27 for 1 s with counter module.
CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

  SCALE = 53

PUB TestFrequency

  ctra[30..26] := %00100
  ctra[5..0] := 27
  frqa := 112_367
  dira[27]~~

  repeat
    frqa := 523 * SCALE
    waitcnt(clkfreq / 2 + cnt)

    frqa := 587 * SCALE
    waitcnt(clkfreq / 2 + cnt)

    frqa := 659 * SCALE
    waitcnt(clkfreq / 2 + cnt)

    frqa := 698 * SCALE
    waitcnt(clkfreq / 2 + cnt)

    frqa := 783 * SCALE
    waitcnt(clkfreq / 2 + cnt)

    frqa := 880 * SCALE
    waitcnt(clkfreq / 2 + cnt)

    frqa := 987 * SCALE
    waitcnt(clkfreq / 2 + cnt)

    frqa := 987 * SCALE
    waitcnt(clkfreq / 2 + cnt)

