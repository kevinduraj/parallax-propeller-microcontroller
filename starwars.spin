
CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

OBJ
  SqrWave : "SquareWave"

PUB PlayTones | index, pin, duration

  repeat index from 0 to 1
    pin := byte[@pins][index]
    spr[8 + index] := (%00100 << 26) + pin
    dira[pin]~~

  repeat index from 0 to 4
    frqa := SqrWave.NcoFrqReg(word[@Anotes][index])
    frqb := SqrWave.NcoFrqReg(word[@Bnotes][index])
    duration := clkfreq/(byte[@durations][index])
    waitcnt(duration + cnt)
