' Play every minute number of sounds
CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

  LED_START    = 16
  LED_END      = 23
  SPEAKER      = 3

VAR
  Byte  wait
  long stack[60]
  long seconds, minutes, hours, days, dT, T

'------------------------------------------------------------------------------'
PUB Main | cog1, cog2

  wait := 4

  cog1 := cognew(Music, @stack[10])
  cog2 := cognew(MyWatch, @stack[20])

'------------------------------------------------------------------------------'
PUB Music | index

  'Configure ctra module
  ctra[30..26] := %00100
  ctra[5..0] := SPEAKER
  frqa := 0


  repeat index from 0 to 7
     frqa := long[@notes][index]
     'Broadcast the signal for 1/4 s

     dira[SPEAKER]~~
     waitcnt(clkfreq/wait + cnt)

     dira[SPEAKER]~
     waitcnt(clkfreq/wait + cnt)

PUB Beep(count) | index

  'Configure ctra module
  ctra[30..26] := %00100
  ctra[5..0] := SPEAKER
  frqa := 0


  repeat index from 0 to count-1
     frqa := long[@notes][index]
     'Broadcast the signal for 1/4 s

     dira[SPEAKER]~~
     waitcnt(clkfreq/2 + cnt)

     dira[SPEAKER]~
     waitcnt(clkfreq/2 + cnt)
'------------------------------------------------------------------------------'
PUB MyWatch | cog3

   dira[LED_START..LED_END]~~

  dT := clkfreq
  T  := cnt

  repeat

    T += dT
    waitcnt(T)
    seconds++
    '! outa[3]

    if seconds // 60 == 0
      minutes++
      cog3 := cognew(Beep(minutes), @stack[30])

      if minutes == 60
        minutes := 0
        'cog := cognew(Music, @stack[0])

    if seconds // 3600 == 0
      hours++
      if hours == 24
        hours := 0

    if seconds // 86400 == 0
      days ++

    ! outa[LED_END]

    if minutes     == 2
      outa[LED_START]~~
    elseif minutes == 4
      outa[LED_START]~
      outa[LED_START+1]~~
    elseif minutes == 6
      outa[LED_START+1]~
      outa[LED_START+2]~~
    elseif minutes == 8
      outa[LED_START+2]~
      outa[LED_START+3]~~
    elseif minutes == 10
      outa[LED_START+3]~
      outa[LED_START+4]~~
    elseif minutes == 12
      outa[LED_START+4]~
      outa[LED_START+5]~~
    elseif minutes == 14
      outa[LED_START+5]~
      outa[LED_START+6]~~
      cog3 := cognew(Beep(minutes), @stack[30])
    elseif minutes > 14
      outa[LED_START..LED_END-1]~~


'------------------------------------------------------------------------------'
DAT
'80 MHz frqa values for square wave musical note approximations with the counter module
'configured to NCO:
'          C6      D6      E6      F6      G6      A6      B6       C7
notes long 56_184, 63_066, 70_786, 74_995, 84_181, 94_489, 105_629, 112_528, 126_127, 141_572, 149_948, 168_363, 188_979, 212_123, 224_734
