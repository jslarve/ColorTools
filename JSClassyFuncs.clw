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
  INCLUDE('JSClassyFuncs.inc'),ONCE
  INCLUDE('SystemString.inc'),ONCE
  INCLUDE('StringTheory.inc'),ONCE
  
  MAP
    INCLUDE('CWUTIL.INC'),ONCE
    MODULE('')
      ULtoA(ULONG,*CSTRING,SIGNED),ULONG,RAW,NAME('_ultoa'),PROC
      GetSysColor(LONG pIndex),LONG,PASCAL
      InvalidateRect(ulong, LONG, UNSIGNED),PASCAL
      GetWindowRect(UNSIGNED hWnd, UNSIGNED lpRect),BYTE,RAW,PASCAL,NAME('GetWindowRect'),PROC
      ClientToScreen(LONG phwnd , LONG lpPoint),LONG,PASCAL,PROC,RAW
      ScreenToClient(LONG phwnd , LONG lpPoint),LONG,PASCAL,PROC,RAW
    END
  END
  
!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
JSClassyFuncs.ARGBTOClarionColor PROCEDURE(Long pColor)!,LONG
!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ImageExColorS GROUP,OVER(pColor)
Blue            BYTE
Green           BYTE
Red             BYTE
Alpha           BYTE
              END
ReturnColor   LONG
ReturnColorS  GROUP,OVER(ReturnColor)
Red             BYTE
Green           BYTE
Blue            BYTE
Alpha           BYTE
              END

   CODE

  ReturnColors.Alpha =  0
  ReturnColors.Red   =  ImageExColors.Red
  ReturnColors.Green =  ImageExColors.Green
  ReturnColors.Blue  =  ImageExColors.Blue

  RETURN ReturnColor

!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
JSClassyFuncs.BNOT          PROCEDURE  (LONG pBitmap, LONG pMask)!,LONG
!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  Code

  RETURN BXOR(pBitMap,(BAND(pBitMap,pMask)))        


JSClassyFuncs.FixClarionLabel PROCEDURE(STRING pLabel)
LegalChars    STRING('_{47}0123456789:_{6}ABCDEFGHIJKLMNOPQRSTUVWXYZ_{6}abcdefghijklmnopqrstuvwxyz_{132}')
Ndx1          LONG,AUTO
ReturnLabel   STRING(SIZE(pLabel)+1)

  CODE  

  ReturnLabel = pLabel
  CASE ReturnLabel[1]
  OF '0' TO '9'
    ReturnLabel = '_' & ReturnLabel
  END
  LOOP Ndx1 = 1 TO LEN(ReturnLabel)
    ReturnLabel[Ndx1] = LegalChars[VAL(ReturnLabel[Ndx1])]
  END
  RETURN CLIP(ReturnLabel)

!JSClassyFuncs.FixFileName     PROCEDURE(STRING pFileName)
!LegalChars    STRING('_{47}0123456789_{7}ABCDEFGHIJKLMNOPQRSTUVWXYZ_{6}abcdefghijklmnopqrstuvwxyz_{132}')
!$!'"@+`|=#%&{}*\?:/;"<>|,()<9,10,13> 
  
JSClassyFuncs.GenerateCharString      PROCEDURE(BYTE pIncludeZero=TRUE)!,STRING
Ndx1      LONG
ArraySize LONG
ReturnString SystemStringClass
  CODE  
  ArraySize = 255   + CHOOSE(pIncludeZero)
  DO GenerateByte
  RETURN ReturnString.ToString()
  
GenerateByte   ROUTINE
  DATA
ByteString    STRING(ArraySize)
ByteArray     BYTE,DIM(ArraySize),OVER(ByteString)
  CODE
  LOOP Ndx1 = 1 - CHOOSE(pIncludeZero) TO 255 + CHOOSE(pIncludeZero)
    ByteArray[Ndx1 + CHOOSE(pIncludeZero)] = Ndx1
  END
  ReturnString.FromString(ByteString)
  
!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
JSClassyFuncs.GetContrastFontColor PROCEDURE(LONG pColor)!,LONG
!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Luminance REAL
Red       BYTE
Green     BYTE
Blue      BYTE

  CODE
  
  IF BAND(pColor,80000000h)
    pColor = SELF.GetSystemColor(pColor)
  END

  ColorToRGB(pColor,Red,Green,Blue)
  !https://stackoverflow.com/questions/1855884/determine-font-color-based-on-background-color
  !Counting the perceptive luminance - human eye favors green color... 
  Luminance =  ( 0.299 * Red + 0.587 * Green + 0.114 * Blue)/255
  RETURN CHOOSE(Luminance > .5,COLOR:Black,COLOR:White)  

!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------  
JSClassyFuncs.GetFormatString  PROCEDURE(LONG pColumns,LONG pColumnWidth=2,<STRING pPicture>,BYTE pExtraColumn=FALSE)!,STRING
!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ColumnFormat   EQUATE('$WIDTH$L(2)*@p pb@P')
Ndx1           LONG
ST             StringTheory
STColumnFormat StringTheory    

  CODE

  STColumnFormat.SetValue(ColumnFormat)
  STColumnFormat.Replace('$WIDTH$',pColumnWidth)
  IF NOT OMITTED(pPicture)
    STColumnFormat.Replace('@p pb',pPicture)
  END
  LOOP Ndx1 = 1 TO pColumns
    ST.Append(STColumnFormat.GetValue())
  END
  IF pExtraColumn
    STColumnFormat.SetValue(ColumnFormat)
    STColumnFormat.Replace('$WIDTH$',1)
    ST.Append(STColumnFormat.GetValue())
  END

  RETURN ST.GetValue()

!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
JSClassyFuncs.GetSystemColor      PROCEDURE(LONG pIndexColor)!,LONG
!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  CODE
  
  IF NOT BAND(pIndexColor,80000000h)
    RETURN pIndexColor
  END
  RETURN GetSysColor(BAND(pIndexColor,0FFFFFFh))


!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
JSClassyFuncs.HEX        PROCEDURE(LONG pLong,LONG pLen=6)!,STRING
!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
lHexCS CSTRING(20)

  CODE

  ULtoA(pLong,lHexCS,16)
  IF pLen 
      RETURN UPPER(ALL('0',pLen - LEN(lHexCS)) & lHexCS)
  END
  RETURN lHexCS
 
!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
JSClassyFuncs.HexToClarionColor PROCEDURE(STRING pHex,LONG pIsClarion)!,LONG
!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ST          StringTheory
HexResult   LONG
ReturnColor LONG

  CODE
   !This could use a bit of refactoring, but it works for now.
   ST.SetValue(UPPER(CLIP(LEFT(pHex))))
   ST.KeepChars('01234567890ABCDEF')
   HexResult = EVALUATE('0' & ST.GetValue() & 'h')
   IF pIsClarion
     ReturnColor = HexResult
   ELSE
     ReturnColor = SELF.ARGBTOClarionColor(HexResult)
   END
   RETURN ReturnColor
 
 
!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
JSClassyFuncs.InvalidateWindow  PROCEDURE
!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    CODE
        
    InValidateRect(INT(0{PROP:ClientHandle}),0,1)

!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
JSClassyFuncs.KeepChars  PROCEDURE(STRING pBuffer,STRING pChars,BYTE pCaseSensitive=TRUE)!,STRING  
!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Charray                    BYTE,DIM(256),AUTO 
Ndx1                       LONG,AUTO
ReturnString               STRING(SIZE(pBuffer))
ReturnNdx                  LONG

  CODE

  DO FillCharray 
  LOOP Ndx1 = 1 TO LEN(pBuffer)
    IF Charray[VAL(pBuffer[Ndx1])+1]
       ReturnNdx += 1
       ReturnString[ReturnNdx] = pBuffer[Ndx1]
    END
  END

  IF NOT ReturnNdx
    ReturnNdx = 1
  END
  
  RETURN ReturnString[1 : ReturnNdx]

FillCharray ROUTINE 
  !Fill a lookup array
  CLEAR(Charray)
  LOOP Ndx1 = 1 TO LEN(pChars)
    IF pCaseSensitive
      Charray[VAL(pChars[Ndx1])+1]        = TRUE 
    ELSE
      Charray[VAL(UPPER(pChars[Ndx1]))+1] = TRUE 
      Charray[VAL(LOWER(pChars[Ndx1]))+1] = TRUE 
    END
  END 
  
!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
JSClassyFuncs.MoveParentFEQ  PROCEDURE(LONG pParentFEQ,LONG pXShift,LONG pYShift,BYTE pMoveType=0)
!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
XOffset  LONG
YOffset  LONG
OldXPos  LONG
OldYPos  LONG
NewXPos  LONG
NewYPos  LONG

  ITEMIZE,PRE(MoveType)
Shift    EQUATE(0)
Move     EQUATE(1)
  END

Ndx      LONG
ChildFEQ LONG
Hidden   BYTE

  CODE

  Hidden = pParentFEQ{PROP:Hide}
  HIDE(pParentFEQ)
  OldXPos = pParentFEQ{PROP:XPos}
  OldYPos = pParentFEQ{PROP:YPos}
  CASE pMoveType
  OF MoveType:Shift
    NewXPos = OldXPos + pXShift
    NewYPos = OldYPos + pYShift
    XOffset = pXShift
    YOffset = pYShift
  OF MoveType:Move
    NewXPos = pXShift
    NewYPos = pYShift
    XOffset = NewXPos - OldXPos
    YOffset = NewYPos - OldYPos
  END
  pParentFEQ{PROP:XPos} = NewXPos
  pParentFEQ{PROP:YPos} = NewYPos
  Ndx = 0
  LOOP
    Ndx += 1
    ChildFEQ = pParentFEQ{PROP:Child,Ndx}
    IF NOT ChildFEQ THEN BREAK.
    SELF.MoveParentFEQ(ChildFEQ,XOffSet,YOffset,0)
  END
  IF NOT Hidden
    UNHIDE(pParentFEQ)
  END

  
  
!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------  
JSClassyFuncs.RGB2CMYK PROCEDURE(BYTE pR, BYTE pG, BYTE pB, *BYTE pC, *BYTE pM, *BYTE pY, *BYTE pK)
!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
R REAL
G REAL
B REAL
C REAL
M REAL
Y REAL
K REAL

  CODE
  
  R = pR
  G = pG
  B = pB

  R = 1.0 - (R / 255.0)
  G = 1.0 - (G / 255.0)
  B = 1.0 - (B / 255.0)

  IF (R < G)
    K = R
  ELSE
    K = G
  END
  IF (B < K)
    K = B
  END  
  C = (R - K)/(1.0 - K)
  M = (G - K)/(1.0 - K)
  Y = (B - K)/(1.0 - K)

  C = (C * 100) + 0.5;
  M = (M * 100) + 0.5;
  Y = (Y * 100) + 0.5;
  K = (K * 100) + 0.5;

  pC = C
  pM = M
  pY = Y
  pK = K
  
  
!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
JSClassyFuncs.CMYK2RGB PROCEDURE(BYTE pC, BYTE pM, BYTE pY, BYTE pK)!,LONG
!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ColorRef LONG
RGB      GROUP,OVER(ColorRef)
r          BYTE
g          BYTE
b          BYTE
         END

R        REAL
G        REAL
B        REAL
C        REAL
M        REAL
Y        REAL
K        REAL

  CODE
  
  	C = pC
  	M = pM
  	Y = pY
  	K = pK
  
  	C = C / 255.0;
  	M = M / 255.0;
  	Y = Y / 255.0;
  	K = K / 255.0;
  
  	R = C * (1.0 - K) + K;
  	G = M * (1.0 - K) + K;
  	B = Y * (1.0 - K) + K;
  
  	R = (1.0 - R) * 255.0 + 0.5;
  	G = (1.0 - G) * 255.0 + 0.5;
  	B = (1.0 - B) * 255.0 + 0.5;
  
  	RGB.r = R;
  	RGB.g = G;
  	RGB.b = B;
  
    RETURN ColorRef    

!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
JSClassyFuncs.StringIsBinary  PROCEDURE(*STRING pS)!,LONG
!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ZeroCount           LONG,AUTO
Ndx                 LONG,AUTO
MaxLen              LONG,AUTO

    CODE

        MaxLen = LEN(pS)
        IF MaxLen > 7000
            MaxLen = 7000
        END
        ZeroCount = 0
        LOOP Ndx = 1 TO MaxLen
            IF VAL(pS[Ndx]) = 0
                ZeroCount += 1
            END
            IF ZeroCount = 3
                BREAK
            END
        END
        RETURN CHOOSE(ZeroCount => 3)        


!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------  
JSClassyFuncs.SwitchEndian16 PROCEDURE(USHORT pIN)!,USHORT
!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  CODE

  RETURN BOR(BSHIFT(BAND(pIN,0FF00h),-8),BSHIFT(BAND(pIN,0FFh),8))
  
!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
JSClassyFuncs.SwitchEndian32 PROCEDURE(ULONG pIN)!,ULONG
!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  CODE

  RETURN BOR(BOR(BSHIFT(BAND(pIN,0FF000000h),-24),BSHIFT(BAND(pIN,0FF0000h),-8)),|
             BOR(BSHIFT(BAND(pIN,0000000FFh), 24),BSHIFT(BAND(pIN,000FF00h), 8)))  
                                                         
  
!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
JSClassyFuncs.WebHex         PROCEDURE(LONG pColor)!,STRING
!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
WebColor LONG

  CODE
  
  WebColor = BSHIFT(BAND(pColor,0FFh),16) + BAND(pColor,0FF00h) + BSHIFT(BAND(pColor,0FF0000h),-16)
  RETURN '#' & SELF.HEX(WebColor)
  
             