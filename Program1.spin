''My First Program: Kevin Duraj

CON
  _clkmode      = xtal1 + pll1x
  _xinfreq      = 5_000_000

  LED1_START    = 0
  LED1_END      = 6

  LED2_START    = 7
  LED2_END      = 9

  PUSHBUTTON    = 22

PUB ButtonBlinkSpeed

  '' Send on/of (3.3V/0 V) signals at approximately 2Hz

  dira[LED1_START..LED1_END]~~
  dira[LED2_START..LED2_END]~~
  outa[LED2_START..LED2_END] := %111

  repeat
    ! outa[LED1_START..LED1_END]
    ! outa[LED2_START..LED2_END]

    if ina[PUSHBUTTON] == 1
      waitcnt(clkfreq / 20 + cnt)
    else
      waitcnt(clkfreq / 2 + cnt)

