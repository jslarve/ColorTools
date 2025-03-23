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

OMIT('***')
 * Created with Clarion 10.0
 * User: jslarve
 * Date: 9/8/2018
 * Time: 8:09 AM
 ***

OMIT('_EndOfInclude_',_JSSelectSpinnerPresent_)

_JSSelectSpinnerPresent_ EQUATE(1)

  ITEMIZE,PRE(JSSpinMode)
Alpha       EQUATE(0)
Hexadecimal EQUATE
Decimal     EQUATE
Octal       EQUATE
Binary      EQUATE
ASCII       EQUATE
Custom      EQUATE !Internal minrange/maxrange used
  END


JSSelectSpinnerClass CLASS,TYPE,MODULE('JSSelectSpinnerClass.clw'),LINK('JSSelectSpinnerClass.clw',_ABCLinkMode_),DLL(_ABCDllMode_)
BitQty                 LONG
FEQ                    SIGNED
Mode                   LONG !Hex,Dec,Oct,Bin,Alpha
MinRange               LONG !Used for CUSTOM Spin mode
MaxRange               LONG !Used for CUSTOM Spin mode
Construct              PROCEDURE 
IncrementBuffer        PROCEDURE(*STRING pS,LONG pDirection)
Init                   PROCEDURE(LONG pFEQ,LONG pMODE)
TakeEvent              PROCEDURE,LONG
                     END

  _EndOfInclude_
