#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Outfile=..\..\Autoit Projects\Color picker\clr_pkr.Exe
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

; A tool to open the color picker

#include <Misc.au3>
Local $clr = _ChooseColor(2)
ClipPut($clr)
Exit

;0xFF8080
;8421631