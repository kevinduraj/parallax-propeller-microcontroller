''LedDutySweep.spin
''Cycle P4 LED from off, gradually brighter, full brightness.
CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

  scale = 16_777_216
  LED1   = 4
VAR
  long stack[120]

PUB Main | i

  repeat i from 1 to 7
    cognew(TestDuty(i*2), @stack[i*10])
    waitcnt(clkfreq/2 + cnt)


PUB TestDuty(pin) | duty, mode

  ctra[30..26] := %00110
  ctra[5..0] := pin
  frqa := duty * scale

  dira[pin]~~

  repeat

    repeat duty from 0 to 255
      frqa := duty * scale
      waitcnt(clkfreq/128 + cnt)          ' Frequency of dim

    repeat duty from 255 to 0
      frqa := duty * scale
      waitcnt(clkfreq/128 + cnt)          ' Frequency of dim

