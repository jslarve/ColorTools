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
OMIT('_EndOfInclude_',_JSColorClassPresent_)

_JSColorClassPresent_      EQUATE(1)     

  INCLUDE('JSClassyFuncs.inc'),ONCE                                 

JSColorQ              QUEUE,TYPE
ColorDesc1              STRING(30)
TextColor1              LONG
BackColor1              LONG
TextSelColor1           LONG,OVER(TextColor1)
BackSelColor1           LONG,OVER(BackColor1)
ColorDesc2              STRING(30)
TextColor2              LONG
BackColor2              LONG
TextSelColor2           LONG,OVER(TextColor2)
BackSelColor2           LONG,OVER(BackColor2)
ColorDesc3              STRING(30)
TextColor3              LONG
BackColor3              LONG
TextSelColor3           LONG,OVER(TextColor3)
BackSelColor3           LONG,OVER(BackColor3)
ColorDesc4              STRING(30)
TextColor4              LONG
BackColor4              LONG
TextSelColor4           LONG,OVER(TextColor4)
BackSelColor4           LONG,OVER(BackColor4)
ColorDesc5              STRING(30)
TextColor5              LONG
BackColor5              LONG
TextSelColor5           LONG,OVER(TextColor5)
BackSelColor5           LONG,OVER(BackColor5)
ColorDesc6              STRING(30)
TextColor6              LONG
BackColor6              LONG
TextSelColor6           LONG,OVER(TextColor6)
BackSelColor6           LONG,OVER(BackColor6)
                      END
                      

JSColorClass          CLASS,TYPE,MODULE('JSColorClass.clw'),LINK('JSColorClass.clw',_ABCLinkMode_),DLL(_ABCDLLMode_)
ColumnCount              LONG
DataChanged              BYTE
RowCount                 LONG
FEQ                      LONG
InfoString               CSTRING(201)
Initing                  BYTE
SelectedCol              LONG
SelectedRow              LONG
ColorBuffer              &STRING
WorkBuffer               &STRING                
ColorQ                   &JSColorQ
JCF                      &JSClassyFuncs
WebColorQ                &JSColorQ
SystemColorQ             &JSColorQ
AnalyzeColor             PROCEDURE(LONG pColor)
Construct                PROCEDURE
Destruct                 PROCEDURE
DrawCursorAt             PROCEDURE(LONG pCol,LONG pRow)
ExpandHexColor           PROCEDURE(STRING pHex),STRING
FillSystemColorQ         PROCEDURE
GetColorAt               PROCEDURE(LONG pCol,LONG pRow),LONG
GetContrastFontColor     PROCEDURE(LONG pColor),LONG
HEX                      PROCEDURE(LONG pLong,LONG pLen=6),STRING
Init                     PROCEDURE(LONG pFEQ,LONG pColumns=24, LONG pRows=24, LONG pCellWidth=2, LONG pCellHeight=2)
InitializeColorBuffer    PROCEDURE(LONG pColumns,LONG pRows)
ReduceHexColor           PROCEDURE(*CSTRING pHex),LONG
RGBColor                 PROCEDURE(BYTE pRed,BYTE pGreen,BYTE pBLUE),LONG
VLBproc                  PROCEDURE(LONG xRow, SHORT xCol),STRING,PRIVATE   
WebHex                   PROCEDURE(LONG pColor),STRING
                       END



_EndOfInclude_