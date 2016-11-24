CON
  _clkmode = xtal1 +pll16x
  _xinfreq = 5_000_000

  'set pins and baud for XB comms
  XB_Rx = 23   ' DOUT
  XB_Tx = 22   ' DIN
  XB_Baud = 9600

  'set pins and baud for pc comms
  PC_Rx = 31
  PC_Tx = 30
  PC_Baud = 9600

VAR
  long stack[50]

OBJ
  PC : "FullDuplexSerial"
  XB : "FullDuplexSerial"

PUB Start
  PC.start(PC_Rx, PC_Tx, 0, PC_Baud)
  XB.start(XB_Rx, XB_Tx, 0, XB_Baud)
  cognew(XB_to_PC, @stack)

  PC.rxFlush
  repeat
    XB.tx(PC.rx)

PUB XB_to_PC
  XB.rxFlush
  repeat
    PC.tx(XB.rx)
