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
  Include('JSSelectSpinnerClass.inc'),ONCE
  Include('KeyCodes.clw'),ONCE

OMIT('***')
 * Created with Clarion 10.0
 * User: jslarve
 * Date: 9/8/2018
 * Time: 8:19 AM
 ***
  MAP
    Module('')
      ULtoA(ULONG,*CSTRING,SIGNED),ULONG,RAW,NAME('_ultoa'),PROC
    end
    ToHEX(Long pLong,Long pLen=6),STRING
    IsSpecialHexCharacter(String pS),LONG
    LeftRotate(SIGNED pN,UNSIGNED pD,SIGNED pBits=32),SIGNED
    RightRotate(SIGNED pN,UNSIGNED pD,SIGNED pBits=32),SIGNED
  END

JSSelectSpinnerClass.Construct               PROCEDURE

  CODE

  SELF.FEQ = 0
  SELF.MinRange = 33
  SELF.MaxRange = 126
  SELF.BitQty   = 24 
    
JSSelectSpinnerClass.IncrementBuffer         PROCEDURE(*STRING pS,LONG pDirection)
S        &String
MinRange LONG
MaxRange LONG
HexString String('0123456789ABCDEF')
DecVal   SHORT

   CODE

  S &= pS[1]
  Case SELF.Mode
  of JSSpinMode:Alpha OROF JSSpinMode:ASCII OROF JSSpinMode:Custom
    Case SELF.Mode 
    of JSSpinMode:Alpha
      Case Val(S)
      of 33 to 126
        Case Val(S)
        of 65 to 90
           MinRange = 65
           MaxRange = 90
        of 97 to 122
           MinRange = 97
           MaxRange = 122
        else
           MinRange = Val(S)
           MaxRange = MinRange
        end
      ELSE
        RETURN       
      end
    of JSSpinMode:ASCII
      MinRange = 33
      MaxRange = 126
    of JSSpinMode:Custom
      MinRange = SELF.MinRange
      MaxRange = SELF.MaxRange
    END
    Case pDirection
    of 1
      S = CHR(VAL(S)+1)
      If VAL(S) > MaxRange
        S = CHR(MinRange)
      end
    of -1
      S = CHR(VAL(S)-1)
      If VAL(S) < MinRange
        S = CHR(MaxRange)
      end
    end
  of JSSpinMode:Binary
    S = Choose(S=1,0,1)
  of JSSpinMode:Decimal
    Case pDirection
    of 1
      If S = 9
        S = 0
      else
        S += 1
      end
    of -1
      If S = 0
         S = 9
      ELSE
         S -= 1
      END
    end
  of JSSpinMode:Hexadecimal
     DecVal = Evaluate('0' & S & 'h')
     Case pDirection
     of 1
       If DecVal >= 15
         DecVal = 0
       ELSE
         DecVal += 1
       END
     of -1
       If DecVal <= 0
         DecVal = 15
       ELSE
         DecVal -= 1
       END
     END
     S = HexString[DecVal+1]
  of JSSpinMode:Octal
     Case pDirection
     of 1
        If S = 7
          S = 0
        ELSE
          S += 1
        END
     of -1
        If S = 0
          S = 7
        ELSE
          S -= 1
        END
     end
  end

JSSelectSpinnerClass.Init                   PROCEDURE(LONG pFEQ,LONG pMODE)

   CODE

   CASE pFEQ{PROP:Type}
   OF CREATE:entry orof CREATE:text
     SELF.FEQ = pFEQ
   ELSE
     Message('JSSelectSpinnerClass: You can only pass an ENTRY or TEXT control to the Init method')
     RETURN
   END

   CASE pMode
   OF JSSpinMode:Alpha 
   OROF JSSpinMode:Binary
   OROF JSSpinMode:Decimal
   OROF JSSpinMode:Hexadecimal
   OROF JSSpinMode:Octal
     SELF.Mode = pMode
   ELSE
     SELF.Mode = JSSpinMode:Alpha
   END

   SELF.FEQ{PROP:Alrt,255} = PgUpKey
   SELF.FEQ{PROP:Alrt,255} = PgDnKey
   SELF.FEQ{PROP:Alrt,255} = CtrlPgDn
   SELF.FEQ{PROP:Alrt,255} = CtrlPgUp
   SELF.FEQ{PROP:Alrt,255} = CtrlMouseLeft2
   SELF.FEQ{PROP:Alrt,255} = ShiftPgDn
   SELF.FEQ{PROP:Alrt,255} = ShiftPgUp


JSSelectSpinnerClass.TakeEvent              PROCEDURE
Looped   BYTE
Buffer  &String
Ndx      LONG
OrigSelStart LONG
OrigSelEnd   LONG
SelStart LONG
SelEnd   LONG
EvalLong LONG

   CODE

  If Field() <> SELF.FEQ
     Return 0
  end
  Case Event()
  of Event:AlertKey orof EVENT:PreAlertKey
  ELSE
    Return 0
  
  end
!  ST.Trace('Class event: ' & Event() & '  Field=' & Field())  
  LOOP                                                     ! This method receive all EVENT:Accepted's
    IF Looped
      RETURN 0
    ELSE
      Looped = 1
    END
    Case Event()
    of EVENT:PreAlertKey
       Case KeyCode()
       of CtrlMouseLeft2
          Cycle
       end
    of EVENT:AlertKey
      Case KeyCode()
      of CtrlMouseLeft2
         Execute Popup('Alpha Mode|Binary Mode|Octal Mode|Decimal Mode|Hexadecimal Mode|ASCII Mode|Custom Mode')
            SELF.Mode = JSSpinMode:Alpha
            SELF.Mode = JSSpinMode:Binary
            SELF.Mode = JSSpinMode:Octal
            SELF.Mode = JSSpinMode:Decimal
            SELF.Mode = JSSpinMode:HexaDecimal
            SELF.Mode = JSSpinMode:ASCII
            SELF.Mode = JSSpinMode:Custom
         end
         SELF.FEQ{PROP:SelStart} = 0
         SELF.FEQ{PROP:SelEnd} = Len(Clip(Contents(SELF.FEQ)))
         SelEnd = 0
         SelStart = 0
         OrigSelEnd = 0
         OrigSelStart = 0
         SELECT(SELF.FEQ)
      of PgUpKey orof CtrlPgUp
        Do GetContents
        Do GetSelection

!        ST.Trace('PgUpKey SelStart=' & SelStart & '  Selend=' & SelEnd)
        If SelStart = SelEnd
           Ndx = SelStart
           If Ndx <> 0
             SELF.IncrementBuffer(Buffer[Ndx],1)
           end
        else
          Case KeyCode()
          of PgUpKey
            Loop Ndx = SelStart to SelEnd
               If SELF.Mode = JSSpinMode:Hexadecimal AND IsSpecialHexCharacter(Buffer[Ndx])
                  Cycle
               end
               SELF.IncrementBuffer(Buffer[ndx],1)
            end
          of CtrlPgUp
            Case SELF.Mode
            of JSSpinMode:Decimal orof JSSpinMode:Hexadecimal orof JSSpinMode:Octal
              Loop Ndx = SelEnd to SelStart BY -1
                 If SELF.Mode = JSSpinMode:Hexadecimal AND IsSpecialHexCharacter(Buffer[Ndx])
                    Cycle
                 end
                 SELF.IncrementBuffer(Buffer[ndx],1)
                 If Buffer[Ndx] <> '0'
                    Break
                 end
              end
            else
              Loop Ndx = SelStart to SelEnd
                 SELF.IncrementBuffer(Buffer[ndx],1)
              end
            end
          end
       end
        Do PutContents
      of ShiftPgUp
         Case SELF.Mode 
         of JSSpinMode:HexaDecimal
            Do GetContents
            EvalLong = Evaluate('0' & Buffer & 'h') 
            EvalLong = LeftRotate(EvalLong,1,SELF.BitQty)
            Buffer = ToHEX(EvalLong,Len(Clip(Buffer)))
            Do PutContents
         end
      of ShiftPgDn
         Case SELF.Mode 
         of JSSpinMode:HexaDecimal
            Do GetContents
            EvalLong = Evaluate('0' & Buffer & 'h') 
            EvalLong = RightRotate(EvalLong,1,SELF.BitQty)
            Buffer = ToHEX(EvalLong,Len(Clip(Buffer)))
            Do PutContents
         end
      of PgDnKey orof CtrlPgDn     
        Do GetContents
        Do GetSelection
!        ST.Trace('PgDnKey SelStart=' & SelStart & '  Selend=' & SelEnd)
        If SelStart = SelEnd
           Ndx = SelStart
           If Ndx <> 0
             SELF.IncrementBuffer(Buffer[Ndx],-1)
           end
        else
          Case KeyCode()
          of PgDnKey
            Loop Ndx = SelStart to SelEnd
               If SELF.Mode = JSSpinMode:Hexadecimal AND IsSpecialHexCharacter(Buffer[Ndx])
                  Cycle
               end
               SELF.IncrementBuffer(Buffer[ndx],-1)
            end
          of CtrlPgDn
            Case SELF.Mode
            of JSSpinMode:Decimal orof JSSpinMode:Hexadecimal orof JSSpinMode:Octal
              Loop Ndx = SelEnd to SelStart BY -1
                 If SELF.Mode = JSSpinMode:Hexadecimal AND IsSpecialHexCharacter(Buffer[Ndx])
                    Cycle
                 end
                 SELF.IncrementBuffer(Buffer[ndx],-1)
                 Case SELF.Mode
                 of JSSpinMode:Decimal
                   If Buffer[Ndx] <> '9'
                      Break
                   end
                 of JSSpinMode:Hexadecimal
                   If Buffer[Ndx] <> 'F'
                      Break
                   end
                 of JSSpinMode:Octal
                   If Buffer[Ndx] <> '7'
                      Break
                   end
                 end
              end
            else
              Loop Ndx = SelStart to SelEnd
                SELF.IncrementBuffer(Buffer[ndx],-1)
              end
            end
          end
        end
        Do PutContents
      end
    end
  END
  Return 0

GetContents ROUTINE
  If CONTENTS(SELF.FEQ)
    Update(SELF.FEQ)
    Buffer &= NEW String(len(Contents(SELF.FEQ)))
    Buffer = CONTENTS(SELF.FEQ)
!    ST.Trace('GetContents Buffer="' & Buffer & '"')
  end        
PutContents ROUTINE
  If NOT Buffer &= NULL
     Change(SELF.FEQ,Clip(Buffer))
     Display(SELF.FEQ)
     Dispose(Buffer)

     SELF.FEQ{PROP:SelStart} = SelStart 
     SELF.FEQ{PROP:SelEnd} = SelEnd
   
!    ST.Trace('PutContents  SelStart=' & SELF.FEQ{PROP:SelStart} & ' SelEnd=' & SELF.FEQ{PROP:SelEnd})
     SELF.FEQ{PROP:Touched} = TRUE
     Post(Event:Accepted,SELF.FEQ)
  end
  
GetSelection ROUTINE

  OrigSelStart = SELF.FEQ{PROP:SelStart}
  OrigSelEnd   = SELF.FEQ{PROP:SelEnd}
  If OrigSelEnd < OrigSelStart
     SelStart = OrigSelEnd + 1
     SelEnd = OrigSelStart - 1
  ELSE
     SelStart = OrigSelStart
     SelEnd = OrigSelEnd
  end

!  ST.Trace('GetSelection 1: SelStart=' & SelStart & '  SelEnd=' & SElEnd)

  If NOT SelStart
    SelStart = 1
  end
  If SelStart > SelEnd
    !SelStart = SelEnd
    SelEnd = SelStart 
  end
  If SelEnd > Len(Clip(Contents(SELF.FEQ)))
    SelEnd = Len(Clip(Contents(SELF.FEQ)))
  end
  If SelStart > Len(Clip(Contents(SELF.FEQ)))
    SelStart = Len(Clip(Contents(SELF.FEQ)))
  end
  If NOT SelEnd
    SelEnd = SelStart
  end

!  ST.Trace('GetSelection 2: SelStart=' & SelStart & '  SelEnd=' & SElEnd)

IsSpecialHexCharacter  PROCEDURE(String pS)

  CODE

     Case pS
     of '#' orof 'x' orof 'h' orof 'H'
       RETURN TRUE
     END
     RETURN FALSE

ToHEX  PROCEDURE(Long pLong,Long pLen=6)!,STRING
lHexCS CSTRING(20)

  CODE

  ULtoA(pLong,lHexCS,16)
  RETURN UPPER(ALL('0',pLen - LEN(lHexCS)) & lHexCS)

LeftRotate   PROCEDURE(SIGNED pN,UNSIGNED pD,SIGNED pBits=32)!,SIGNED
TruncMask LONG
BitNdx    LONG

  CODE

  TruncMask = (2 ^ pBits) - 1
  RETURN  BAND(                           |
             BOR(                         |
               BSHIFT(pN,ABS(pD)),        |
               BSHIFT(pN,-(pBits-ABS(pD)))|
                ),                        |
             TruncMask                    |
              )

RightRotate  PROCEDURE(SIGNED pN,UNSIGNED pD,SIGNED pBits=32)!,SIGNED
TruncMask LONG
BitNdx    LONG

  CODE

  TruncMask = (2 ^ pBits) - 1
  RETURN  BAND(                          |
             BOR(                        |
               BSHIFT(pN,-ABS(pD)),      |
               BSHIFT(pN,(pBits-ABS(pD)))|
             ),                          |
             TruncMask                   |
             )

