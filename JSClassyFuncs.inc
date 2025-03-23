!ABCIncludeFile

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

OMIT('_EndOfInclude_',_JSClassyFuncsPresent_)
JSClassyFuncs        CLASS,TYPE,MODULE('JSClassyFuncs.clw'),LINK('JSClassyFuncs.clw',_ABCLinkMode_),DLL(_ABCDLLMode_)
ARGBTOClarionColor      PROCEDURE(LONG pColor),LONG
BNOT                    PROCEDURE  (LONG pBitmap, LONG pMask),LONG
CMYK2RGB                PROCEDURE(BYTE c, BYTE m, BYTE y, BYTE k),LONG
FixClarionLabel         PROCEDURE(STRING pLabel),STRING
GenerateCharString      PROCEDURE(BYTE pIncludeZero=TRUE),STRING
GetContrastFontColor    PROCEDURE(LONG pColor),LONG    
GetFormatString         PROCEDURE(LONG pColumns,LONG pColumnWidth=2,<STRING pPicture>,BYTE pExtraColumn=FALSE),STRING   
GetSystemColor          PROCEDURE(LONG pIndexColor),LONG
HEX                     PROCEDURE(LONG pLong,LONG pLen=6),STRING    
HexToClarionColor       PROCEDURE(STRING pHex,LONG pIsClarion),LONG
InvalidateWindow        PROCEDURE
KeepChars               PROCEDURE(STRING pBuffer,STRING pChars,BYTE pCaseSensitive=TRUE),STRING  
MoveParentFEQ           PROCEDURE(LONG pParentFEQ,LONG pXShift,LONG pYShift,BYTE pMoveType=0)
RGB2CMYK                PROCEDURE(BYTE pR, BYTE pG, BYTE pB, *BYTE pC, *BYTE pM, *BYTE pY, *BYTE pK)
StringIsBinary          PROCEDURE(*STRING pS),LONG
SwitchEndian16          PROCEDURE(USHORT pIN),USHORT
SwitchEndian32          PROCEDURE(ULONG pIN),ULONG
WebHex                  PROCEDURE(LONG pColor),STRING

                      END


_EndOfInclude_