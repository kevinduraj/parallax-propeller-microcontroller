'------------------------------------------------------------'
'            Communicating with serial terminal
'------------------------------------------------------------'

CON
  _clkmode      = xtal1 + pll16x
  _xinfreq      = 5_000_000

OBJ
  pst : "Parallax Serial Terminal"


PUB TerminalLedControl | var1, var2

  pst.Start(115_200)
  pst.Char(pst#CS)
  dira[4..9]~~

  repeat
    pst.NewLine
    pst.Str(String("------------------------------------"))
    pst.NewLine
    pst.Str(String("Calculator add two integers:"))
    pst.NewLine

    'var1 := pst.BinIn
    'var2 := pst.BinIn

    var1 := pst.DecIn
    var2 := pst.DecIn

    'outa[9..4] := var1 + var2

    pst.Str(String("____"))
    pst.NewLine
    pst.Dec(var1+var2)

