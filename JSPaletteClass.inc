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
OMIT('_EndOfInclude_',_JSPaletteClassPresent_)

_JSPaletteClassPresent_      EQUATE(1)     

  INCLUDE('ABPOPUP.INC'),ONCE
  INCLUDE('JSClassyFuncs.inc'),ONCE                                 
                      
JSPaletteQ            QUEUE,TYPE
Color                   LONG
RGB                     GROUP,OVER(Color)
Red                       BYTE
Green                     BYTE
Blue                      BYTE
Alpha                     BYTE
                        END
HSL                     GROUP      
Hue                       REAL
Sat                       REAL
Lum                       REAL
                        END                        
Name                    CSTRING(31)
Description             CSTRING(201)
Mark                    BYTE
                      END                      

JSPaletteClass        CLASS,TYPE,MODULE('JSPaletteClass.clw'),LINK('JSPaletteClass.clw',_ABCLinkMode_),DLL(_ABCDLLMode_)
ChangesHash              LONG
ColumnCount              LONG
DataChanged              BYTE
FEQ                      LONG
Initing                  BYTE
Popup                    &PopupClass
ShowText                 BYTE
JCF                      &JSClassyFuncs
PaletteQ                 &JSPaletteQ
RowCount                 LONG
AddColor                 PROCEDURE(LONG pColor,<STRING pName>,<STRING pDescription>,BYTE pRefresh=TRUE)
Construct                PROCEDURE
DeleteColor              PROCEDURE(LONG pIndex=0,LONG pColor=0)
Destruct                 PROCEDURE
FetchColor               PROCEDURE(LONG pRow, LONG pColumn, <*STRING pColorName>,<*STRING pDescription>),LONG
FillClarionColors        PROCEDURE
FillHtmlColors           PROCEDURE
FillSystemColors         PROCEDURE
FillWebSafeColors        PROCEDURE
FindColor                PROCEDURE(<LONG pColor>,<STRING pSearchText>,BYTE pSelectListBox=TRUE,<*LONG pFoundColor>,<*STRING pName>,<*STRING pDescription>),BYTE
Init                     PROCEDURE(LONG pFEQ,LONG pColumnWidth,LONG pRowHeight,<STRING pPicture>,LONG pColumnCount=0)
LoadAcoSwatch            PROCEDURE(<STRING pFileName>),LONG
RefreshList              PROCEDURE
Records                  PROCEDURE,LONG
SetShowText              PROCEDURE(BYTE pShowText=TRUE)
                      END



_EndOfInclude_