''*****************************
''*  PS/2 Mouse Driver v1.0   *
''*  (C) 2004 Parallax, Inc.  *
''*****************************

VAR

  long  cogon, cog

  long  oldx, oldy, oldz        'must be followed by parameters (10 contiguous longs)

  long  par_x           'absolute x             read-only       (7 contiguous longs)
  long  par_y           'absolute y             read-only
  long  par_z           'absolute z             read-only
  long  par_buttons     'button states          read-only
  long  par_present     'mouse present          read-only
  long  par_dpin        'data pin               write-only
  long  par_cpin        'clock pin              write-only


PUB start(dpin, cpin) : okay

'' Start mouse driver - starts a cog
'' returns false if no cog available
''
''   dpin  = data signal on PS/2 jack
''   cpin  = clock signal on PS/2 jack
''
''     use 30-ohm resistors between pins and jack
''     use 3K-ohm resistors to pull jack-side signals to 5V
''     connect jack-power to 5V, jack-gnd to vss

  stop
  par_dpin := dpin
  par_cpin := cpin
  okay := cogon := (cog := cognew(@entry,@par_x)) > 0


PUB stop

'' Stop mouse driver - frees a cog

  if cogon~
    cogstop(cog)
  longfill(@oldx, 0, 10)


PUB present : type

'' Check if mouse present - valid ~2s after start
'' returns mouse type:
''
''   3 = five-button scrollwheel mouse
''   2 = three-button scrollwheel mouse
''   1 = two-button or three-button mouse
''   0 = no mouse connected

  type := par_present


PUB button(b) : state

'' Get the state of a particular button
'' returns t|f

  state := -(par_buttons >> b & 1)


PUB buttons : states

'' Get the states of all buttons
'' returns buttons:
''
''   bit4 = right-side button
''   bit3 = left-side button
''   bit2 = center/scrollwheel button
''   bit1 = right button
''   bit0 = left button

  states := par_buttons


PUB abs_x : ax

'' Get absolute-x

  ax := par_x


PUB abs_y : ay

'' Get absolute-y

  ay := par_y


PUB abs_z : az

'' Get absolute-z (scrollwheel)

  az := par_z


PUB delta_x : dx | newx

'' Get delta-x

  newx := par_x
  dx := newx - oldx
  oldx := newx


PUB delta_y : dy | newy

'' Get delta-y

  newy := par_y
  dy := newy - oldy
  oldy := newy


PUB delta_z : dz | newz

'' Get delta-z (scrollwheel)

  newz := par_z
  dz := newz - oldz
  oldz := newz


PUB  delta_reset

'' Reset deltas

  oldx := par_x
  oldy := par_y
  oldz := par_z


DAT

'***************************************
'* Assembly language PS/2 mouse driver *
'***************************************

                        org
'
'
' Entry
'
entry                   mov     x,par                   'load input parameters:
                        add     x,#5*4                  '_dpin/_cpin
                        rdlong  _dpin,x
                        add     x,#4
                        rdlong  _cpin,x

                        mov     dmask,#1                'set pin masks
                        shl     dmask,_dpin
                        mov     cmask,#1
                        shl     cmask,_cpin

                        test    _dpin,#$20      wc      'modify port registers within code
                        muxc    _d1,dlsb
                        muxc    _d2,dlsb
                        muxc    _d3,#1
                        muxc    _d4,#1
                        test    _cpin,#$20      wc
                        muxc    _c1,dlsb
                        muxc    _c2,dlsb
                        muxc    _c3,#1

                        movd    :par,#_x                'reset output parameters:
                        mov     x,#5                    '_x/_y/_z/_buttons/_present
:par                    mov     0,#0
                        add     :par,dlsb
                        djnz    x,#:par
'
'
' Reset mouse
'
reset                   mov     dira,#0                 'reset directions
                        mov     dirb,#0

                        mov     stat,#1                 'set reset flag
'
'
' Update parameters
'
update                  movd    :par,#_x                'update output parameters:
                        mov     x,par                   '_x/_y/_z/_buttons/_present
                        mov     y,#5
:par                    wrlong  0,x
                        add     :par,dlsb
                        add     x,#4
                        djnz    y,#:par

                        test    stat,#1         wc      'if reset flag, transmit reset command
        if_c            mov     data,#$FF
        if_c            call    #transmit
'
'
' Get data packet
'
                        mov     stat,#0                 'reset state

                        call    #receive                'receive first byte

                        cmp     data,#$AA       wz      'powerup/reset?
        if_z            jmp     #init

                        mov     _buttons,data           'data packet, save buttons

                        call    #receive                'receive second byte

                        test    _buttons,#$10   wc      'adjust _x
                        muxc    data,signext
                        add     _x,data

                        call    #receive                'receive third byte

                        test    _buttons,#$20   wc      'adjust _y
                        muxc    data,signext
                        add     _y,data

                        and     _buttons,#%111          'trim buttons

                        cmp     _present,#2     wc      'if not scrollwheel mouse, update parameters
        if_c            jmp     #update


                        call    #receive                'scrollwheel mouse, receive fourth byte

                        cmp     _present,#3     wz      'if 5-button mouse, handle two extra buttons
        if_z            test    data,#$10       wc
        if_z_and_c      or      _buttons,#%01000
        if_z            test    data,#$20       wc
        if_z_and_c      or      _buttons,#%10000

                        shl     data,#28                'adjust _z
                        sar     data,#28
                        sub     _z,data

                        jmp     #update                 'update parameters
'
'
' Initialize mouse
'
init                    call    #receive                '$AA received, receive id

                        movs    crate,#100              'try to enable 3-button scrollwheel type
                        call    #checktype
                        movs    crate,#200              'try to enable 5-button scrollwheel type
                        call    #checktype
                        shr     data,#1                 'if neither, 3-button type
                        add     data,#1
                        mov     _present,data

                        movs    srate,#200              'set 200 samples per second
                        call    #setrate

                        mov     data,#$F4               'enable data reporting
                        call    #transmit

                        jmp     #update
'
'
' Check mouse type
'
checktype               movs    srate,#200              'perform "knock" sequence to enable
                        call    #setrate                '..scrollwheel and extra buttons

crate                   movs    srate,#200/100
                        call    #setrate

                        movs    srate,#80
                        call    #setrate

                        mov     data,#$F2               'read type
                        call    #transmit
                        call    #receive

checktype_ret           ret
'
'
' Set sample rate
'
setrate                 mov     data,#$F3
                        call    #transmit
srate                   mov     data,#0
                        call    #transmit

setrate_ret             ret
'
'
' Transmit byte to mouse
'
transmit
_c1                     or      dira,cmask              'pull clock low
                        movs    napshr,#13              'hold clock for ~128us (must be >100us)
                        call    #nap
_d1                     or      dira,dmask              'pull data low
                        movs    napshr,#18              'hold data for ~4us
                        call    #nap
_c2                     xor     dira,cmask              'release clock

                        test    data,#$0FF      wc      'append parity and stop bits to byte
                        muxnc   data,#$100
                        or      data,dlsb

                        mov     x,#10                   'ready 10 bits
transmit_bit            call    #wait_c0                'wait until clock low
                        shr     data,#1         wc      'output data bit
_d2                     muxnc   dira,dmask
                        mov     wcond,c1                'wait until clock high
                        call    #wait
                        djnz    x,#transmit_bit         'another bit?

                        mov     wcond,c0d0              'wait until clock and data low
                        call    #wait
                        mov     wcond,c1d1              'wait until clock and data high
                        call    #wait

                        call    #receive_ack            'receive ack byte with timed wait
                        cmp     data,#$FA       wz      'if ack error, reset mouse
        if_nz           jmp     #reset

transmit_ret            ret
'
'
' Receive byte from mouse
'
receive                 test    _cpin,#$20      wc      'wait indefinitely for initial clock low
                        waitpne cmask,cmask
receive_ack
                        mov     x,#11                   'ready 11 bits
receive_bit             call    #wait_c0                'wait until clock low
                        movs    napshr,#16              'pause ~16us
                        call    #nap
_d3                     test    dmask,ina       wc      'input data bit
                        rcr     data,#1
                        mov     wcond,c1                'wait until clock high
                        call    #wait
                        djnz    x,#receive_bit          'another bit?

                        shr     data,#22                'align byte
                        test    data,#$1FF      wc      'if parity error, reset mouse
        if_nc           jmp     #reset
                        and     data,#$FF               'isolate byte

receive_ack_ret
receive_ret             ret
'
'
' Wait for clock/data to be in required state(s)
'
wait_c0                 mov     wcond,c0                '(wait until clock low)

wait                    mov     y,tenms                 'set timeout to 10ms

wloop                   movs    napshr,#18              'nap ~4us
                        call    #nap
_c3                     test    cmask,ina       wc      'check required state(s)
_d4                     test    dmask,ina       wz      'loop until got state(s) or timeout
wcond   if_never        djnz    y,#wloop                '(replaced with c0/c1/c0d0/c1d1)

                        tjz     y,#reset                'if timeout, reset mouse
wait_ret
wait_c0_ret             ret


c0      if_c            djnz    y,#wloop                '(if_never replacements)
c1      if_nc           djnz    y,#wloop
c0d0    if_c_or_nz      djnz    y,#wloop
c1d1    if_nc_or_z      djnz    y,#wloop
'
'
' Nap
'
nap                     rdlong  t,#0                    'get clkfreq
napshr                  shr     t,#18/16/13             'shr scales time
                        min     t,#3                    'ensure waitcnt won't snag
                        add     t,cnt                   'add cnt to time
                        waitcnt t,#0                    'wait until time elapses (nap)

nap_ret                 ret
'
'
' Initialized data
'
dlsb                    long    1 << 9
tenms                   long    10_000 / 4
signext                 long    $FFFFFF00
'
'
' Uninitialized data
'
dmask                   res     1
cmask                   res     1
stat                    res     1
data                    res     1
x                       res     1
y                       res     1
t                       res     1

_x                      res     1       'write-only
_y                      res     1       'write-only
_z                      res     1       'write-only
_buttons                res     1       'write-only
_present                res     1       'write-only
_dpin                   res     1       'read-only
_cpin                   res     1       'read-only