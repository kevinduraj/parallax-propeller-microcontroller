''ADC-to-DAC Demo
''Uses the two CTRs in a COG to do ADC input and DAC output of analog signals.
''Samples are periodically output to a TV for viewing



CON

  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000
  bits = 10  

PUB go

  cognew(@asm_entry, 0)   'launch assembly program in a COG

DAT

'
' This assembly program places CTRA in POS W/FEEDBACK mode in order to realize sigma-delta
' A/D conversion on pins 8 and 9. It also places CTRB in DUTY mode for D/A conversion on pin 0.
'
' It is very critical that the following circuit be connected within a few millimeters of the
' Propeller pins, since at 80 MHz there is a 12.5ns feedback loop operating. Normally, this
' kind of thing is done on-chip, where parasitics are minimal. This probably will not work on
' the breadboad, at all. I soldered 0603 SMT parts directly onto the pins to keep things
' short and it worked beautifully:
'
'
'    ADC Circuit                                     
'                                  │
'               10uF   1k   .1uF           1k
'    Analog input ─────────────╋───────────┳───────── Pin 8 (sigma-delta feedback)
'    3V peak                      .1uF      │
'                                  │           └─────────── Pin 9 (sigma-delta input)
'                                  
'
'
' The DAC output circuit is not layout-critical. The breadboard is fine to use.
'
'
'    DAC Circuit
'                              1k                
'    (DUTY output) Pin 0 ─────────┳──────── Analog output
'                                   1000pF   3V peak
'                                    │
'                                    
'
'
' The code below performs 11-bit conversions at 39k samples per second, with the Propeller
' running at 80 MHz.
'
' It digitizes an analog input using sigma-delta ADC and then outputs the samples via a
' duty-modulation DAC.
'
'


              org

asm_entry     mov       dira,diraval                    'make pins 8 (ADC) and 0 (DAC) outputs

              movs      ctra,#8                         'POS W/FEEDBACK mode for CTRA
              movd      ctra,#9
              movi      ctra,#%01001_000
              mov       frqa,#1

              movi      ctrb,#%00111_000                'DUTY mode for CTRB
              movs      ctrb,#10
              movd      ctrb,#11
              
              mov       asm_c,cnt                       'prepare for WAITCNT loop
              add       asm_c,asm_cycles

              
:loop         waitcnt   asm_c,asm_cycles                'wait for next CNT value
                                                        '(timing is determinant after WAITCNT)
              mov       asm_new,phsa                    'capture PHSA

              mov       asm_sample,asm_new              'compute sample from 'new' - 'old'
              sub       asm_sample,asm_old
              mov       asm_old,asm_new       

              shl       asm_sample,#32-bits
              mov       frqb,asm_sample
        
              jmp       #:loop                          '(..since it must sync to the HUB)



asm_cycles    long      1<<bits-1                       '(use $FFFF for 16-bit, $FFF for 12-bit, or $FF for 8-bit)

diraval       long      $E00

asm_c         res       1                               'uninitialized variables follow emitted data
asm_cnt       res       1
asm_new       res       1
asm_old       res       1
asm_sample    res       1
asm_temp      res       1
addr          res       1
addr2         res       1
data2         res       1