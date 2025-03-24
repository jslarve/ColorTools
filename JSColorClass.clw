  MEMBER
!MIT License
!
!Copyright (c) 2021 Jeff Slarve
!
!Permission is hereby granted, free of charge, to any person obtaining a copy
!of this software and associated documentation files (the "Software"), to deal
!in the Software without restriction, including without limitation the rights
!to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
!copies of the Software, and to permit persons to whom the Software is
!furnished to do so, subject to the following conditions:
!
!The above copyright notice and this permission notice shall be included in all
!copies or substantial portions of the Software.
!
!THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
!IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
!FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
!AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
!LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
!OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
!SOFTWARE.
!
  INCLUDE('JSColorClass.inc'),ONCE
  INCLUDE('StringTheory.inc'),ONCE

  MAP
    INCLUDE('CWUTIL.INC'),ONCE
    MODULE('')
      ULtoA(ULONG,*CSTRING,SIGNED),ULONG,RAW,NAME('_ultoa'),PROC
      GetSysColor(LONG pIndex),LONG,PASCAL
    END
  END

ModST StringTheory

!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
JSColorClass.AnalyzeColor     PROCEDURE(LONG pColor)
!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CurrentH REAL
CurrentS REAL
CurrentL REAL
CurrentR BYTE
CurrentG BYTE
CurrentB BYTE
Ndx1     LONG
NdxHue   REAL
NdxSL    REAL
NdxColor BYTE
ShortHex CSTRING(12)
DEG_SYM  EQUATE('<0B0h>') ! Workaround to avoid putting extended degree symbol in source.

  CODE
  
  IF BAND(pColor,80000000h)
    pColor = SELF.JCF.GetSystemColor(pColor)
  END

  ColorToHSL(pColor,CurrentH,CurrentS,CurrentL)
  ColorToRGB(pColor,CurrentR,CurrentG,CurrentB)
  ShortHex = SELF.JCF.WebHex(pColor)
  IF NOT SELF.ReduceHexColor(ShortHex)
    ShortHex = ''
  END
  
  SELF.InfoString = 'Clarion:<9>' & SELF.HEX(pColor) & 'h<13,10>' & |
                    'Web:<9>' & SELF.JCF.WebHex(pColor) & ' ' & ShortHex & '<13,10>'   & |
                    'HSL<9>' & CLIP(LEFT(FORMAT(ROUND(360 * CurrentH,.01),@N10.2))) & DEG_SYM & ',' & CLIP(LEFT(FORMAT(ROUND(CurrentS * 100,.01),@N10.2))) & ',' & CLIP(LEFT(FORMAT(ROUND(CurrentL * 100,.01),@N10.2))) & '<13,10>' &|
                    'RGB:<9>' & CurrentR & ',' & CurrentG & ',' & CurrentB
 
  FREE(SELF.ColorQ)
  NdxHue    = .99723
  NdxSL     =  1
  NdxColor  = 255
  LOOP Ndx1 = 1 TO 21
    !Column 1 = HUE 
    SELF.ColorQ.ColorDesc1 =  ROUND(NdxHue * 360,.01) & DEG_SYM
    HSLToColor(NdxHue,CurrentS,CurrentL,SELF.ColorQ.BackColor1)
    SELF.ColorQ.BackColor1 = BAND(SELF.ColorQ.BackColor1,0FFFFFFh)
    SELF.ColorQ.TextColor1 = SELF.GetContrastFontColor(SELF.ColorQ.BackColor1)
    !Column 2 = Saturation
    SELF.ColorQ.ColorDesc2 =  CLIP(LEFT(FORMAT(ROUND(NdxSL * 100,.01),@n10.2)))
    HSLToColor(CurrentH,NdxSL,CurrentL,SELF.ColorQ.BackColor2)
    SELF.ColorQ.BackColor2 = BAND(SELF.ColorQ.BackColor2,0FFFFFFh)
    SELF.ColorQ.TextColor2 = SELF.GetContrastFontColor(SELF.ColorQ.BackColor2)
    !Column 3 = Lightness
    SELF.ColorQ.ColorDesc3 = CLIP(LEFT(FORMAT(ROUND(NdxSL * 100,.01),@n10.2)))
    HSLToColor(CurrentH,CurrentS,NdxSL,SELF.ColorQ.BackColor3)
    SELF.ColorQ.BackColor3 = BAND(SELF.ColorQ.BackColor3,0FFFFFFh)
    SELF.ColorQ.TextColor3 = SELF.GetContrastFontColor(SELF.ColorQ.BackColor3)
    !Column 4 = Red
    SELF.ColorQ.ColorDesc4 = NdxColor
    SELF.ColorQ.BackColor4 = SELF.RGBColor(NdxColor,CurrentG,CurrentB)   
    SELF.ColorQ.TextColor4 = SELF.GetContrastFontColor(SELF.ColorQ.BackColor4)
    !Column 5 = Green
    SELF.ColorQ.ColorDesc5 = NdxColor
    SELF.ColorQ.BackColor5 = SELF.RGBColor(CurrentR,NdxColor,CurrentB)
    SELF.ColorQ.TextColor5 = SELF.GetContrastFontColor(SELF.ColorQ.BackColor5)
    !Column 6 = Blue
    SELF.ColorQ.ColorDesc6 = NdxColor
    SELF.ColorQ.BackColor6 = SELF.RGBColor(CurrentR,CurrentG,NdxColor)
    SELF.ColorQ.TextColor6 = SELF.GetContrastFontColor(SELF.ColorQ.BackColor6)
    
    ADD(SELF.ColorQ)
    IF NdxHue < .05
        NdxHue = 0
    ELSE
      NdxHue -= .05
    END
    IF NdxSL < .05
        NdxSL = 0
    ELSE
      NdxSL -= .05
    END
    IF NdxColor < 13
      NdxColor = 0
    ELSE
      NdxColor -= 13
    END  
  END

!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
JSColorClass.Construct        PROCEDURE
!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  CODE
  
  SELF.ColorBuffer  &= NULL
  SELF.RowCount      = 0
  SELF.ColumnCount   = 0
  SELF.ColorQ       &= NEW JSColorQ
  SELF.WebColorQ    &= NEW JSColorQ
  SELF.SystemColorQ &= NEW JSColorQ
  SELF.JCF          &= NEW JSClassyFuncs
  SELF.FillSystemColorQ

!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
JSColorClass.Destruct         PROCEDURE
!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  CODE
  
  DISPOSE(SELF.ColorBuffer)
  DISPOSE(SELF.ColorQ)
  DISPOSE(SELF.JCF)
  DISPOSE(SELF.WebColorQ)
  DISPOSE(SELF.SystemColorQ)

!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
JSColorClass.DrawCursorAt     PROCEDURE(LONG pCol,LONG pRow)
!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  CODE
  
  SELF.WorkBuffer = SELF.ColorBuffer
  DO DrawCursor
  
DrawCursor ROUTINE
  DATA
L   LONG,DIM(SELF.RowCount,SELF.ColumnCount),OVER(SELF.WorkBuffer)  
CursorWidth  EQUATE(4)
Ndx1         LONG
  CODE
  
  IF pRow < 1
    pRow = 1
  END
  IF pCol < 1
    pCol = 1
  END
  
  LOOP Ndx1 = pCol - 6 TO pCol - CursorWidth - 4 BY -1
     IF Ndx1 <= 1
        BREAK
     END
     L[pRow,Ndx1] = SELF.GetContrastFontColor(L[pRow,Ndx1])
  END
  LOOP Ndx1 = pCol + 2 TO pCol + CursorWidth
     IF Ndx1 >= SELF.ColumnCount
        BREAK
     END
     L[pRow,Ndx1] = SELF.GetContrastFontColor(L[pRow,Ndx1])
  END

  SELF.DataChanged = TRUE
  DISPLAY(SELF.FEQ)   

!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
JSColorClass.ExpandHexColor           PROCEDURE(STRING pHex)!,STRING
!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  CODE
  
  CASE LEN(pHex)
  OF 3
  OF 4
    IF pHex[1] <> '#'
      RETURN pHex
    END
    pHex = SUB(pHex,2,3)  
  ELSE
    RETURN pHex
  END
  RETURN '#' & pHex[1] & pHex[1] & pHex[2] & pHex[2] & pHex[3] & pHex[3]

!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
JSColorClass.FillSystemColorQ PROCEDURE
!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
c CLASS
AddQRecord PROCEDURE(STRING pText,LONG pColor)
  END
This       &JSColorClass

  CODE
  
  This &= SELF
  FREE(SELF.SystemColorQ)
  c.AddQRecord('ScrollBar'               , COLOR:SCROLLBAR               )
  c.AddQRecord('Background'              , COLOR:BACKGROUND              )
  c.AddQRecord('ActiveCaption'           , COLOR:ACTIVECAPTION           )
  c.AddQRecord('InactiveCaption'         , COLOR:INACTIVECAPTION         )
  c.AddQRecord('Menu'                    , COLOR:MENU                    )
  c.AddQRecord('MenuBar'                 , COLOR:MENUBAR                 )
  c.AddQRecord('Window'                  , COLOR:WINDOW                  )
  c.AddQRecord('WindowFrame'             , COLOR:WINDOWFRAME             )
  c.AddQRecord('MenuText'                , COLOR:MENUTEXT                )
  c.AddQRecord('WindowText'              , COLOR:WINDOWTEXT              )
  c.AddQRecord('CaptionText'             , COLOR:CAPTIONTEXT             )
  c.AddQRecord('ActiveBorder'            , COLOR:ACTIVEBORDER            )
  c.AddQRecord('InactiveBorder'          , COLOR:INACTIVEBORDER          )
  c.AddQRecord('AppWorkspace'            , COLOR:APPWORKSPACE            )
  c.AddQRecord('Highlight'               , COLOR:HIGHLIGHT               )
  c.AddQRecord('HighlightText'           , COLOR:HIGHLIGHTTEXT           )
  c.AddQRecord('ButtonFace'              , COLOR:BTNFACE                 )
  c.AddQRecord('ButtonShadow'            , COLOR:BTNSHADOW               )
  c.AddQRecord('GrayText'                , COLOR:GRAYTEXT                )
  c.AddQRecord('ButtonText'              , COLOR:BTNTEXT                 )
  c.AddQRecord('InactiveCaptionText'     , COLOR:INACTIVECAPTIONTEXT     )
  c.AddQRecord('ButtonHighlight'         , COLOR:BTNHIGHLIGHT            )
  COMPILE('**C11.1**',_C111_)
    c.AddQRecord('3DDkShadow'              , COLOR:3DDkShadow              )
    c.AddQRecord('3DLight'                 , COLOR:3DLight                 )
    c.AddQRecord('InfoText'                , COLOR:InfoText                )
    c.AddQRecord('InfoBackground'          , COLOR:InfoBackground          )
    c.AddQRecord('HotLight'                , COLOR:HotLight                )
    c.AddQRecord('GradientActiveCaption'   , COLOR:GradientActiveCaption   )
    c.AddQRecord('GradientInactiveCaption' , COLOR:GradientInactiveCaption )
    c.AddQRecord('MenuHighlight'           , COLOR:MenuHighlight           )
  !**C11.1**

c.AddQRecord PROCEDURE(STRING pText,LONG pColor)

  CODE
  
  This.SystemColorQ.ColorDesc1 = pText
  This.SystemColorQ.BackColor1 = pColor
  This.SystemColorQ.BackColor2 = GetSysColor(BAND(pColor,0FFFFFFh))  
  This.SystemColorQ.ColorDesc2 = This.JCF.WebHex(This.SystemColorQ.BackColor2)
  This.SystemColorQ.TextColor2 = This.GetContrastFontColor(This.SystemColorQ.BackColor2)
  This.SystemColorQ.TextColor1 = This.SystemColorQ.TextColor2
  ADD(This.SystemColorQ)
  
!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
JSColorClass.GetColorAt       PROCEDURE(LONG pCol,LONG pRow)!,LONG
!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  CODE
  
  IF SELF.ColorBuffer &= NULL
    RETURN 0
  END
  CASE pCol 
  OF 1 TO SELF.ColumnCount
  ELSE
    pCol = 1
  END
  CASE pRow 
  OF 1 TO SELF.RowCount
  ELSE
    pRow = 1
  END

  DO ReturnColor

ReturnColor ROUTINE
  DATA
L   LONG,DIM(SELF.RowCount,SELF.ColumnCount),OVER(SELF.WorkBuffer)  
  CODE
  
  RETURN L[pRow,pCol]

!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
JSColorClass.GetContrastFontColor PROCEDURE(LONG pColor)!,LONG
!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  CODE
  
  RETURN SELF.JCF.GetContrastFontColor(pColor)
!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
JSColorClass.HEX              PROCEDURE(LONG pLong,LONG pLen=6)!,STRING
!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  CODE

  RETURN SELF.JCF.HEX(pLong,pLen)

!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
JSColorClass.Init             PROCEDURE(LONG pFEQ,LONG pColumns=24, LONG pRows=24, LONG pCellWidth=2, LONG pCellHeight=2)
!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Ndx1 LONG

  CODE
  
  IF pFEQ{PROP:Type} <> CREATE:list
     RETURN
  END
  SELF.FEQ                  =  pFEQ
  SELF.Initing              =  TRUE
  SELF.InitializeColorBuffer(pColumns,pRows)
  SELF.FEQ{PROP:LineHeight} =  pCellHeight
  SELF.FEQ{PROP:FORMAT    } =  SELF.JCF.GetFormatString(pColumns,pCellWidth)
  SELF.FEQ{PROP:Height    } =  pCellHeight * pRows
  SELF.FEQ{PROP:Width     } =  ((pCellWidth + 1)  * pColumns) + 2
  SELF.FEQ{PROP:VLBVal    } =  ADDRESS(SELF)
  SELF.FEQ{PROP:VLBProc   } =  ADDRESS(SELF.VLBProc)
  SELF.Initing              =  FALSE
!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
JSColorClass.InitializeColorBuffer PROCEDURE(LONG pColumns,LONG pRows)
!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CurColor &LONG 
ColNdx    LONG
RowNdx    LONG

   CODE
   
  DISPOSE(SELF.ColorBuffer)
  DISPOSE(SELF.WorkBuffer)
  SELF.ColumnCount  =  pColumns
  SELF.RowCount     =  pRows
  SELF.ColorBuffer &=  NEW STRING(SELF.ColumnCount * SELF.RowCount * 4)
  SELF.WorkBuffer  &=  NEW STRING(SIZE(SELF.ColorBuffer))         
  DO BuildData
  SELF.WorkBuffer   =  SELF.ColorBuffer

BuildData ROUTINE
  DATA
L   LONG,DIM(SELF.RowCount,SELF.ColumnCount),OVER(SELF.ColorBuffer)  
Hue REAL
Sat REAL
Lum REAL
HueDec REAL 
LumDec REAL
  CODE

  Hue = 0
  Sat = 1
  HueDec = 1 / (SELF.ColumnCount)
  LumDec = 1 / (SELF.RowCount)
  LOOP ColNdx = 1 TO SELF.ColumnCount
    Lum = 1
    LOOP RowNdx = 1 TO SELF.RowCount
      HSLToColor(Hue,Sat,Lum,L[RowNdx,ColNdx])
      L[RowNdx,ColNdx] = BAND(L[RowNdx,ColNdx],0FFFFFFh)
      IF Lum < LumDec
        Lum = 0
        BREAK
      ELSE
        Lum -= LumDec
      END
    END
    IF Hue > 1
      Hue = 1
    ELSE
      Hue += HueDec
    END  
  END  
  Lum = 1
  LOOP ColNdx = 1 TO SELF.ColumnCount
      IF ColNdx = SELF.ColumnCount
        Lum = 0
      END
      HSLToColor(0,0,Lum,L[1,ColNdx])
      L[1,ColNdx] = BAND(L[1,ColNdx],0FFFFFFh)
      IF Lum < HueDec
        Lum = 0
        BREAK
      ELSE
        Lum -= HueDec
      END
  END

!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
JSColorClass.ReduceHexColor           PROCEDURE(*CSTRING pHex)!,LONG
!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
HexColor CSTRING(SIZE(pHex))

  CODE
  
  HexColor = pHex
  CASE LEN(HexColor) 
  OF 6 
  OF 7
    IF HexColor[1] <> '#'
      RETURN FALSE
    END
    HexColor = SUB(HexColor,2,6)
  ELSE
    RETURN FALSE
  END
  IF (HexColor[1] <> HexColor[2]) OR (HexColor[3] <> HexColor[4]) OR (HexColor[5] <> HexColor[6])
    RETURN FALSE
  END
  pHex = '#' & HexColor[1] & HexColor[3] & HexColor [5]
  RETURN TRUE

!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
JSColorClass.RGBColor         PROCEDURE(BYTE pRed,BYTE pGreen,BYTE pBLUE)!,LONG
!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
  CODE
  
  RETURN pRed + BSHIFT(pGreen,8) + BSHIFT(pBlue,16)
   
    
!------------------------------------------------------------------------------------------------------------------------------------------------------
!!! <summary>Private method for virtual listbox</summary>
!!! <returns>String containing cell data</returns>
!======================================================================================================================================================
JSColorClass.VLBproc          PROCEDURE(LONG xRow, SHORT xCol)!,STRING,PRIVATE   
ROW:GetRowCount  EQUATE(-1)
ROW:GetColCount  EQUATE(-2)
ROW:IsQChanged   EQUATE(-3)
ReturnColor      LONG
col              LONG  
ST StringTheory

  CODE
    
  IF SELF.Initing
    RETURN 1
  END 
    
  CASE xRow
  OF ROW:GetRowCount
    RETURN SELF.RowCount
  OF ROW:GetColCount
    RETURN SELF.ColumnCount
  OF ROW:IsQChanged 
    IF SELF.DataChanged
      SELF.DataChanged = FALSE
      RETURN TRUE
    END
    RETURN FALSE
  END
  col = ((xCol+5) / 6)  

  If NOT col
    col = 1
  END   

  DO ReturnColor
  
ReturnColor ROUTINE
  DATA
L   LONG,DIM(SELF.RowCount,SELF.ColumnCount),OVER(SELF.WorkBuffer)  
  CODE
  
  ReturnColor = L[xRow,Col]
  IF xCol % 6 = 0 !Tooltip column#
    RETURN SELF.JCF.WebHex(ReturnColor)
  END
  RETURN ReturnColor

!--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
JSColorClass.WebHex           PROCEDURE(LONG pColor)!,STRING
!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
WebColor LONG

  CODE
  
  RETURN SELF.JCF.WebHex(pColor)
