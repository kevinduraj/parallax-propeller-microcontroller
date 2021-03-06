''From Parallax Inc. Propeller Education Kit - 7: Counter Modules and
''Circuit Aplications.  Object version: 1.1
''Copyright 2009, Parallax Inc.  See end of file for license.

'' SquareWave.spin
'' Can be used to make either or both of a given cog's counter modules transmit square
'' waves from 1 to 128 MHz.  Based on CTR.spin by Chip Gracey.

'' REVISION: Freq used to be Module, Pin, Frequency, now it's  Pin, Module, Frequency

VAR

  long diffPin                           ' Global variable for differential signals
  
PUB Freq(pin, module, frequency) | s, d, ctr, temp

{{ Determine CTR settings for synthesis of 0..128 MHz in 1 Hz steps
  
   in:    Pin = Square wave output pin 
          Module = 0 or 1 for counter module A or B
          Freq = actual Hz to synthesize
  
   out:   ctr and frq hold ctra/ctrb and frqa/frqb values
  
     Uses NCO mode %00100 for 0..499_999 Hz
     Uses PLL mode %00010 for 500_000..128_000_000 Hz
}}
  
  Frequency := Frequency #> 0 <# 128_000_000     'limit frequency range

  if pin==-1                                     ' If only updating frequency
    temp := spr[8+module]                        ' Copy existing CTR register
    temp &= %00000100_00000000_01111110_00111111 ' Mask what needs to be saved
  
  if Frequency < 500_000                         'if 0 to 499_999 Hz,
    ctr := constant(%00100 << 26)                '..set NCO mode
    s := 1                                       '..shift = 1
  else                                           'if 500_000 to 128_000_000 Hz,
    ctr := constant(%00010 << 26)                '..set PLL mode
    d := >| ((Frequency - 1) / 1_000_000)        'determine PLLDIV
    s := 4 - d                                   'determine shift
    ctr |= d << 23                               'set PLLDIV

  if diffPin <> -1 and pin <> -1                 ' if differential & not frequency update
    ctr |= diffPin << 9                          ' Add to BPIN field
    ctr |= 1 << 26                               ' Set differential bit

  spr[10 + module] := fraction(Frequency, CLKFREQ, s)    'Compute frqa/frqb value

  if pin == -1                                   ' If just a frequency update
    spr[8+module] := (temp | (ctr & %01111011_10000000_00000000_00000000))
  else                                           ' If not just a frequency update
    ctr |= Pin                                   ' Set PINA to complete CTRA/CTRB value
    spr[8 + module] := ctr                       ' Copy ctr variable to counter control register

  {if frequency == 0
    dira[spr[8+module]&$1F]~
    if spr[8+module]&|<26
      dira[spr[8+module]>>9&$1F]~
  else}
    dira[spr[8+module]&$1F]~~
    if spr[8+module]&|<26
      dira[spr[8+module]>>9&$1F]~~

  pin~   
  diffPin~~

PUB FreqDiff(pinA, pinB, module, frequency)

{{ Determine CTR settings for synthesis of 0..128 MHz in 1 Hz steps
  
   in:    PinA = Square wave output pin
          PinB = Inverted square wave output pin
          Module = 0 or 1 for counter module A or B
          Freq = actual Hz to synthesize
  
   out:   ctr and frq hold ctra/ctrb and frqa/frqb values
  
     Uses NCO mode %00100 for 0..499_999 Hz
     Uses PLL mode %00010 for 500_000..128_000_000 Hz
}}

  diffPin := pinB                      ' Set global variable for Freq method
  Freq(pinA, module, frequency)        ' Call Freq method

PUB FreqUpdate(module, newFrequency)

  ''Update the freuqency transmitted by a module
  ''  module - 0 or 1
  ''  newFrequency - the new frequency (0 to 128 MHz) for the module to transmit
  ''NOTE: If you update to 0 Hz, the I/O pins will remain output and retain the
  ''output state(s) at the moment the newFrequency updates.  If you want the I/O
  ''pins changed to input, use the Remove method instead. 

  Freq(-1, module, newFrequency)                 ' pin = -1 => update frequency

PUB End(module)
  
  ''Stop a module from transmitting a frequency and set its I/O pin(s) to intput
  ''  module - the module (0 or 1) that gets stopped
  ''If you do not want to set the I/O pins to input, use FreqUpdate.

  if module                                      ' Decide which counter
    if ctrb[26]                                  ' If differential mode
      dira[ctrb[14..9]]~                         ' Inverted signal pin -> input
    dira[ctrb[5..0]]~                            ' Signal pin -> input
    ctrb~                                        ' Clear counter control register
    frqb~                                        ' Clear frequency register
  else                                           ' Else if CTRA
    if ctra[26]                                  ' If differential mode
      dira[ctra[17..9]]~                         ' Inverted signal pin -> input
    dira[ctra[5..0]]~                            ' Signal pin to 
    ctra~                                        ' Clear counter control register 
    frqa~                                        ' Clear frequency register
    
PUB NcoFrqReg(frequency) : frqReg
{{
Returns frqReg = frequency × (2³² ÷ clkfreq) calculated with binary long
division.  This is faster than the floating point library, and takes less
code space.  This method is an adaptation of the CTR object's fraction
method.
}}
  frqReg := fraction(frequency, clkfreq, 1)


PRI Fraction(a, b, shift) : f

  if shift > 0                                   'if shift, pre-shift a or b left
    a <<= shift                                  'to maintain significant bits while 
  if shift < 0                                   'insuring proper result
    b <<= -shift
 
  repeat 32                                      'perform long division of a/b
    f <<= 1
    if a => b
      a -= b
      f++           
    a <<= 1

{{
┌──────────────────────────────────────────────────────────────────────────────────────┐
│                           TERMS OF USE: MIT License                                  │                                                            
├──────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this  │
│software and associated documentation files (the "Software"), to deal in the Software │ 
│without restriction, including without limitation the rights to use, copy, modify,    │
│merge, publish, distribute, sublicense, and/or sell copies of the Software, and to    │
│permit persons to whom the Software is furnished to do so, subject to the following   │
│conditions:                                                                           │                                            │
│                                                                                      │                                               │
│The above copyright notice and this permission notice shall be included in all copies │
│or substantial portions of the Software.                                              │
│                                                                                      │                                                │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,   │
│INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A         │
│PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT    │
│HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION     │
│OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE        │
│SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                                │
└──────────────────────────────────────────────────────────────────────────────────────┘
}}    
    