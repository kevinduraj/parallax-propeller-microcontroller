''My First Program: Kevin Duraj

CON
  _clkmode      = xtal1 + pll1x
  _xinfreq      = 5_000_000

  LED1_START    = 0
  LED1_END      = 6

  LED2_START    = 7
  LED2_END      = 9

  PUSHBUTTON    = 16

PUB ButtonBlinkSpeed

  '' Send on/of (3.3V/0 V) signals at approximately 2Hz

  dira[15]~~
  outa[15]~

  repeat
    ! outa[15]

    if ina[PUSHBUTTON] == 1
      ! outa[LED1_START..LED1_END]
      waitcnt(clkfreq / 10 + cnt)


