'------------------------------------------------------'
' File TimeCounter
'------------------------------------------------------'
CON
  _clkmode      = xtal1 + pll1x
  _xinfreq      = 5_000_000

VAR
  long seconds, minutes, hours, days, dT, T

PUB GoodTimeCount

  dira[15..3]~~

  dT := clkfreq
  T  := cnt

  repeat

    T += dT
    waitcnt(T)
    seconds++
    ! outa[3]

    if seconds // 60 == 0
      minutes++
      if minutes == 60
        minutes := 0

    if seconds // 3600 == 0
      hours++
      if hours == 24
        hours := 0

    if seconds // 86400 == 0
      days ++

    outa[15..3] := seconds

