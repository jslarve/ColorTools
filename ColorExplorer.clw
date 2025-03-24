
  PROGRAM
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
 * Created with Clarion 11.0
 * User: Jeff Slarve
 * Date: 4/3/2021
 * Time: 9:35 PM
 ***

  MAP
    INCLUDE('CWUTIL.INC'),ONCE 
    ColorExplorer(<*LONG pColor>,<LONG pGridQuality>),LONG,PROC
  END

  INCLUDE('JSClassyFuncs.inc'),ONCE
  INCLUDE('JSColorClass.inc'),ONCE
  INCLUDE('JSPaletteClass.inc'),ONCE
  INCLUDE('JSSelectSpinnerClass.inc'),ONCE
  INCLUDE('KEYCODES.CLW')
  INCLUDE('StringTheory.inc'),ONCE

C LONG
  ITEMIZE,PRE(GridQuality)     !Arbitrary equates for setting the size of the individual grid cells.
Basic   EQUATE(1)              !These are explicit (instead of automatic) because the 
Normal  EQUATE(2)              !VALUE() attribute of certain controls on the window uses them.
Fine    EQUATE(3)
  END  
JCF     JSClassyFuncs
   CODE
     
  C = COLOR:Blue               !Setting a default color
  IF ColorExplorer(C,)         !Passing it to the ColorExplorer
    MESSAGE(JCF.Hex(C,8))                !User selected a color
  END

ColorExplorer  PROCEDURE(<*LONG pColor>,<LONG pGridQuality>)
DummyColor     LONG(COLOR:Blue)! Hi! I'm a dummy color! :-D
Ndx            LONG
ParamColorRef  &LONG           ! Local reference to either the pased color or a local color if no color was passed.
PreviousColumn LONG            ! For tracking LeftKey/RightKey in Color Grid
PreviousRow    LONG            ! For tracking UpKey/DownKey in Color Grid
ReturnVal      LONG(FALSE)     ! Bool 
  
ST             StringTheory    ! General purpose StringTheory object 
HexSpinner     JSSelectSpinnerClass !Allows spinning of the RGB hex nybbles in the color entry control.
JSC            JSColorClass    ! Instance of the color class
JSF            JSClassyFuncs
ClarionColors  JSPaletteClass  ! Instance of the palette class.
HtmlColors     JSPaletteClass  ! Instance of the palette class.
Palette        JSPaletteClass  ! Instance of the palette class.
Swatch         JSPaletteClass  ! Instance of the palette class.
SystemColors   JSPaletteClass  ! System Colors
WebSafe        JSPaletteClass  ! Instance of the palette class.

HexColor       CSTRING(26)     ! This is large to support system colors (such as COLOR:BtnFace)
IsClarionColor BYTE            ! Hex is presented as 0BBGGRRh. Otherwise #RRGGBB (or system color if applicable).

CurrentColor   LONG            ! The current color being used
RGBColor       LONG
RGB            GROUP,OVER(RGBColor),PRE(RGB)
Red              BYTE               ! These fields are used in the Red, Green, Blue spinners 
Green            BYTE
Blue             BYTE
               END

HSL            GROUP,PRE(HSL)  ! These fields represent the HSL spinners
HueDeg           REAL
SaturationPct    REAL
LightnessPct     REAL
Hue              REAL
Saturation       REAL
Lightness        REAL
               END  
GridQuality    BYTE            ! GridQuality:Basic, GridQuality:Normal, GridQuality:Fine
ShowLabels     BYTE(TRUE)

Window WINDOW('Color Explorer'),AT(,,461,305),CENTER,IMM,SYSTEM,ICON('colorwheel.ico'), |
      FONT('Segoe UI',9)
    GROUP('&User Colors'),AT(2,194,235,109),USE(?UserColorsGroup),BOXED
      LIST,AT(6,203,226,95),USE(?UserColorsList),TRN,VSCROLL,COLUMN,ALRT(DeleteKey)
    END
    PANEL,AT(242,196,217,48),USE(?PANEL1),BEVEL(2,2,9999H)
    ENTRY(@s25),AT(243,246,153,14),USE(HexColor),CENTER,FONT('Consolas',12)
    CHECK('Clarion Color Format'),AT(378,264,78),USE(IsClarionColor)
    BUTTON,AT(438,245,16,14),USE(?ColorDialogButton),SKIP,ICON('search.ico'), |
        TIP('Open standard Clarion COLORDIALOG()')
    TEXT,AT(243,262,130,40),USE(?InfoString),FONT('Segoe UI',10)
    LIST,AT(243,2,213,178),USE(?AnalysisList),COLUMN,FORMAT('38R(2)|*~Hue~C(0)38' & |
        'R(2)|*~Saturation~C(0)38R(2)|*~Lightness~C(0)32R(2)|*~Red~C(0)32R(2)|*~' & |
        'Green~C(0)32R(2)|*~Blue~C(0)')
    SPIN(@n7.2),AT(244,183,34),USE(HSL:HueDeg),RIGHT,FONT(,8),RANGE(0,360),STEP(1)
    SPIN(@n7.2~%~),AT(282,183,34),USE(HSL:SaturationPct),RIGHT,FONT(,8), |
        RANGE(0,100),STEP(1)
    SPIN(@n7.2~%~),AT(320,183,34),USE(HSL:LightnessPct),RIGHT,FONT(,8), |
        RANGE(0,100),STEP(1)
    SPIN(@n3),AT(358,183,31),USE(RGB:Red),RIGHT,FONT(,8),RANGE(0,255),STEP(1)
    SPIN(@n3),AT(391,183,31),USE(RGB:Green),RIGHT,FONT(,8),RANGE(0,255),STEP(1)
    SPIN(@n3),AT(424,183,31),USE(RGB:Blue),RIGHT,FONT(,8),RANGE(0,255),STEP(1)
    SHEET,AT(2,3,235,191),USE(?PaletteSheet),JOIN,ABOVE
      TAB('H/L'),USE(?HLTab)
        LIST,AT(5,19,227,155),USE(?ColorGrid),COLUMN,FORMAT('21L(2)|M@p pb@'), |
            ALRT(LeftKey), ALRT(RightKey), ALRT(UpKey), ALRT(DownKey)
        OPTION('Grid Quality'),AT(196,179,38,13),USE(GridQuality)
          RADIO('B'),AT(197,180,11,10),USE(?BasicButton),SKIP,TIP('Basic setting' & |
              ' - Fewest color choices, but probably enough for most people.'), |
              ICON(ICON:None),VALUE('1')
          RADIO('N'),AT(209,180,11,10),USE(?NormalButton),SKIP,TIP('Normal Setti' & |
              'ng - A good number of color choices, while still loading quickly'), |
              ICON(ICON:None),VALUE('2')
          RADIO('F'),AT(221,180,11,10),USE(?FineButton),SKIP,TIP('Fine Setting -' & |
              ' The most color choices, but slower to load'),ICON(ICON:None), |
              VALUE('3')
        END
      END
      TAB('Swatch'),USE(?SwatchTab)
        LIST,AT(5,19,227,172),USE(?SwatchList),TRN,VSCROLL,FONT('Consolas'),COLUMN
      END
      TAB('Clarion'),USE(?ClarionTab)
        LIST,AT(5,19,227,172),USE(?ClarionColorsList),TRN,VSCROLL,FONT('Consolas'), |
            COLUMN
      END
      TAB('System'),USE(?SystemColorsTab)
        LIST,AT(5,19,227,172),USE(?SystemColorsList),VSCROLL,COLUMN, |
            FORMAT('154L(2)|M*~System Color~C(0)20L(2)|M*~RGB Version (This mach' & |
            'ine)~C(0)'),ALRT(CtrlF)
      END
      TAB('HTML'),USE(?HTMLColorTab)
        LIST,AT(5,19,227,172),USE(?HTMLColorsList),TRN,VSCROLL,FONT('Consolas'),COLUMN
      END
      TAB('Web Safe'),USE(?WebColorTab)
        LIST,AT(5,19,227,172),USE(?WebColorsList),TRN,VSCROLL,FONT('Consolas'),COLUMN
      END
    END
    BUTTON('&Select'),AT(377,289,39),USE(?SelectButton),DEFAULT
    BUTTON('&Cancel'),AT(419,289,39,14),USE(?CancelButton),STD(STD:Close)
    CHECK('Show Labels'),AT(378,275,75),USE(ShowLabels),TIP('Show color labels o' & |
        'n collections.')
    BUTTON,AT(401,246,16,14),USE(?AddToUserColorsButton),KEY(InsertKey),SKIP, |
        FONT(,9,,FONT:bold),ICON('insert.ico'),TIP('Add to User Colors (Insert B' & |
        'utton)')
    BUTTON,AT(419,245,16,14),USE(?DeleteFromUserColorsButton),KEY(DeleteKey),SKIP, |
        FONT(,9,,FONT:bold),ICON('delete.ico'),TIP('Remove from User Colors (Del' & |
        'ete Button)')
  END
 
DEG_SYM  EQUATE('<0B0h>') ! Workaround to avoid putting extended degree symbol in source.
 
  CODE

  IF OMITTED(pColor)             !Setting a reference that we can use instead of further checking of OMITTED whenever we need this value
    ParamColorRef &= DummyColor
  ELSE
    ParamColorRef &= pColor
  END

  OPEN(Window)
  
  ?HSL:HueDeg{PROP:Text} = '@n7.2~' & DEG_SYM & '~' ! Workaround to put a degree (alt+248) symbol without adding extended character to Clarion source module
  
  0{PROP:Buffer} = 1
  0{PROP:Pixels} = TRUE          !Working with pixels makes things more precise when lining stuff up
  DO SetPositions
  ClarionColors.Init(?ClarionColorsList,-1,20,'@s60',1) !Setting a 40 pixel square palette unit.
  ClarionColors.SetShowText(ShowLabels)
  ClarionColors.FillClarionColors()
  ?ClarionTab{PROP:Text} = 'Clarion (' & ClarionColors.Records() & ')'

  Palette.Init(?UserColorsList,-1,40,'@s60',4) !Setting a 40 pixel square palette unit.
  Palette.SetShowText(ShowLabels)
  Palette.AddColor(Color:Red)         
  Palette.AddColor(Color:Blue)
  Palette.AddColor(Color:Green)
  Palette.AddColor(Color:Yellow)
  Swatch.Init(?SwatchList,-1,20,'@s60',5)
  Swatch.SetShowText(ShowLabels)
  HtmlColors.Init(?HTMLColorsList,-1,20,'@s60',1)
  HtmlColors.SetShowText(ShowLabels)
  WebSafe.Init(?WebColorsList,-1,20,'@S20',6)
  WebSafe.SetShowText(ShowLabels)
  WebSafe.FillWebSafeColors
  ?WebColorTab{PROP:Text} = 'Web Safe (' & WebSafe.Records() & ')'
  ?WebColorTab{PROP:Tip}  = '"Web Safe" colors list (generated at run time).<10>Not sure anybody really adheres to this.<10>It is interesting to look at the pattern of incrementation, though.<10>Everything increments by 33h.'
  IF NOT OMITTED(pGridQuality)
    GridQuality = pGridQuality
  ELSE
    GridQuality = GridQuality:Normal
  END
  SystemColors.Init(?SystemColorsList,-1,20,'@S30',2)
  SystemColors.SetShowText(ShowLabels)
  SystemColors.FillSystemColors
  ?SystemColorsTab{PROP:Text} = 'System (' & SystemColors.Records() & ')'
  ?SystemColorsTab{PROP:Tip} = 'System colors based on users'' color theme.<10>TIP: Click the left side for the system color, and the right side for the actual color.'

  DO SetGridQuality
  ?InfoString{PROP:Use} = JSC.InfoString
  ?AnalysisList{PROP:From} = JSC.ColorQ 
  ?AnalysisList{PROPLIST:BarFrame} = COLOR:White
  ?ColorGrid{PROPLIST:BarFrame} = COLOR:White
  HexSpinner.Init(?HexColor,JSSpinMode:Hexadecimal)
  CurrentColor = ParamColorRef
  DO AnalyzeColor
  ?SwatchTab{PROP:Text} = 'Swatch (' & Swatch.LoadAcoSwatch('Rich-Colors.aco') & ')'
  HtmlColors.FillHtmlColors
  ?HtmlColorTab{PROP:Text} = 'HTML (' & HtmlColors.Records() & ')'
  ?UserColorsGroup{PROP:Text} = 'User Colors (' & Palette.Records() & ')'
  
  ACCEPT
    CASE ACCEPTED()
    OF ?ShowLabels
      ClarionColors.SetShowText(ShowLabels)
      HtmlColors.SetShowText(ShowLabels)
      Palette.SetShowText(ShowLabels)
      Swatch.SetShowText(ShowLabels)
      SystemColors.SetShowText(ShowLabels)
      WebSafe.SetShowText(ShowLabels)

    OF ?DeleteFromUserColorsButton
      Palette.DeleteColor(,CurrentColor)
      ?UserColorsGroup{PROP:Text} = 'User Colors (' & Palette.Records() & ')'
    OF ?AddToUserColorsButton
      IF BAND(CurrentColor,80000000h)
        SystemColors.PaletteQ.Color = CurrentColor
        GET(SystemColors.PaletteQ,SystemColors.PaletteQ.Color)
        IF NOT ERRORCODE()
          Palette.AddColor(CurrentColor,SystemColors.PaletteQ.Name,SystemColors.PaletteQ.Name & ' is a Systerm Color, dependent on user color theme settings.<10,10>On the currently running system, the color is ' & JSF.WebHex(JSF.GetSystemColor(CurrentColor)) )
        END
      ELSE
        Palette.AddColor(CurrentColor)
      END  
      ?UserColorsGroup{PROP:Text} = 'User Colors (' & Palette.Records() & ')'
    OF ?GridQuality
      SETCURSOR(CURSOR:Wait)
      DO SetGridQuality
      DISPLAY
      SETCURSOR()
    OF ?IsClarionColor
      DO AnalyzeColor
    OF ?SelectButton
      ParamColorRef = CurrentColor
      ReturnVal = TRUE
      POST(EVENT:CloseWindow)
    END  
    CASE FIELD()
    OF ?HTMLColorsList
      CASE EVENT()
      OF EVENT:NewSelection
        CurrentColor =  HtmlColors.FetchColor(CHOICE(?HTMLColorsList),INT(?HTMLColorsList{PROP:Column}))
        DO AnalyzeColor
      END  
    OF ?SwatchList
      CASE EVENT()
      OF EVENT:NewSelection
        CurrentColor =  Swatch.FetchColor(CHOICE(?SwatchList),INT(?SwatchList{PROP:Column}))
        DO AnalyzeColor
      END  
    OF ?WebColorsList
      CASE EVENT()
      OF EVENT:NewSelection
        CurrentColor =  WebSafe.FetchColor(CHOICE(?WebColorsList),INT(?WebColorsList{PROP:Column}))
        DO AnalyzeColor
      END  
    OF ?SystemColorsList
      CASE EVENT()
      OF EVENT:NewSelection
        CurrentColor =  SystemColors.FetchColor(CHOICE(?SystemColorsList),INT(?SystemColorsList{PROP:Column}))
        DO AnalyzeColor
      OF EVENT:AlertKey
        IF SystemColors.FindColor()
        END
      END
    OF ?UserColorsList
      CASE EVENT()
      OF EVENT:NewSelection
        CurrentColor = Palette.FetchColor(CHOICE(?UserColorsList),INT(?UserColorsList{PROP:Column}))
        DO AnalyzeColor
      OF EVENT:AlertKey
        CASE KEYCODE()
        OF DeleteKey
          Palette.DeleteColor(,CurrentColor)    
          ?UserColorsGroup{PROP:Text} = 'User Colors (' & Palette.Records() & ')'         
        END
      END
    OF ?HexColor
      CASE EVENT()
      OF EVENT:Accepted
         IF LEN(HexColor) < 7
           HexColor = JSC.ExpandHexColor(HexColor)
         END
         CurrentColor = JCF.HexToClarionColor(HexColor,IsClarionColor)
         DO AnalyzeColor
      END
      IF HexSpinner.TakeEvent()
      END
    OF ?ColorDialogButton
      CASE EVENT()
      OF EVENT:Accepted
        IF COLORDIALOG('Select Color',CurrentColor,)
          DO AnalyzeColor
        END
      END  
    OF ?RGB:Red OROF ?RGB:Green OROF ?RGB:Blue
      CASE EVENT()
      OF EVENT:NewSelection OROF EVENT:Accepted
        CurrentColor = RGBColor
        DO AnalyzeColor
      END
    OF ?HSL:HueDeg OROF ?HSL:LightnessPct OROF ?HSL:SaturationPct
      CASE EVENT()
      OF EVENT:NewSelection OROF EVENT:Accepted
        HSL:Hue = HSL:HueDeg / 360
        HSL:Saturation = HSL:SaturationPct * .01
        HSL:Lightness = HSL:LightnessPct * .01
        HSLToColor(HSL:Hue,HSL:Saturation,HSL:Lightness,CurrentColor)
        DO AnalyzeColor
      END   
    OF ?ColorGrid
       CASE EVENT()
       OF EVENT:AlertKey
         CASE KEYCODE()
         OF LeftKey 
           IF PreviousColumn = 1
             ?ColorGrid{PROP:Column}   = JSC.ColumnCount
             POST(EVENT:NewSelection,?ColorGrid)
           END
         OF RightKey
           IF PreviousColumn = JSC.ColumnCount
             ?ColorGrid{PROP:Column}   = 1
             POST(EVENT:NewSelection,?ColorGrid)
           END
         OF UpKey
           IF PreviousRow    = 1
             ?ColorGrid{PROP:Selected} = JSC.RowCount
             POST(EVENT:NewSelection,?ColorGrid)
           END
         OF DownKey
           IF PreviousRow    = JSC.RowCount
             ?ColorGrid{PROP:Selected} = 1
             POST(EVENT:NewSelection,?ColorGrid)
           END
         END
       OF EVENT:NewSelection
         JSC.SelectedRow = CHOICE(?ColorGrid)
         JSC.SelectedCol = ?ColorGrid{PROP:Column}
         CurrentColor = JSC.GetColorAt(JSC.SelectedCol,JSC.SelectedRow) 
         IF ?ColorGrid{PROPLIST:BarFrame} <> JCF.GetContrastFontColor(CurrentColor)
           ?ColorGrid{PROPLIST:BarFrame} = JCF.GetContrastFontColor(CurrentColor)         
         END
         DO AnalyzeColor
       OF EVENT:PreAlertKey
         CASE KEYCODE()
         OF LeftKey OROF RightKey
           PreviousColumn = ?ColorGrid{PROP:Column}
           CYCLE
         OF UpKey OROF DownKey
           PreviousRow    = ?ColorGrid{PROP:Selected}
           CYCLE
         END
       END  
    OF ?AnalysisList   
      CASE EVENT()
      OF EVENT:NewSelection  
        GET(JSC.ColorQ,CHOICE(?AnalysisList))
        CASE ?AnalysisList{PROP:Column}
        OF 1 !Hue
          CurrentColor = JSC.ColorQ.BackColor1
        OF 2 !Saturation
          CurrentColor = JSC.ColorQ.BackColor2
        OF 3 !Lightness
          CurrentColor = JSC.ColorQ.BackColor3
        OF 4 !Red
          CurrentColor = JSC.ColorQ.BackColor4
        OF 5 !Green
          CurrentColor = JSC.ColorQ.BackColor5
        OF 6 !Blue
          CurrentColor = JSC.ColorQ.BackColor6
        END
        DO AnalyzeColor
      END
    END  
  END
  RETURN ReturnVal
  
AnalyzeColor ROUTINE  

  ?PANEL1{PROP:Fill} = CurrentColor  
  RGBColor = JCF.GetSystemColor(CurrentColor)
  JSC.AnalyzeColor(RGBColor)
  ColorToHSL(RGBColor,HSL:Hue,HSL:Saturation,HSL:Lightness)
  HSL:HueDeg        = 360 * HSL:Hue
  HSL:SaturationPct = 100 * HSL:Saturation
  HSL:LightNessPct  = 100 * HSL:Lightness
  IF BAND(CurrentColor,80000000h)  
    JSC.SystemColorQ.BackColor1 = CurrentColor
    GET(JSC.SystemColorQ, JSC.SystemColorQ.BackColor1)
    IF NOT ERRORCODE()
      HexColor = JSC.SystemColorQ.ColorDesc1
      ?HexColor{PROP:FontSize} = 10
      ?HexColor{PROP:FontName} = 'Segoe UI'
    END
  ELSE
    ?HexColor{PROP:FontSize} = 12
    ?HexColor{PROP:FontName} = 'Consolas'
    IF IsClarionColor
      HexColor          = '0' & JSC.HEX(CurrentColor) & 'h'
    ELSE
      HexColor          = JSC.WebHex(CurrentColor)
    END
  END  
  HIDE(?HexColor)
  UNHIDE(?HexColor)
  DISPLAY

SetGridQuality ROUTINE
 DATA
SaveColor LONG 
 CODE

  SaveColor = CurrentColor
  CASE GridQuality
  OF GridQuality:Basic
   ! JSC.Init(?ColorGrid,18,8,26,26) 
   ! JSC.Init(?ColorGrid,18,8,20,23) 
    JSC.Init(?ColorGrid,18,12,21,25) 
  OF GridQuality:Normal
   ! JSC.Init(?ColorGrid,49,24,9,9) 
   ! JSC.Init(?ColorGrid,64,26,5,7) 
   ! JSC.Init(?ColorGrid,66,42,5,7) 
    JSC.Init(?ColorGrid,44,33,8,9) 
  OF GridQuality:Fine
    !JSC.Init(?ColorGrid,248,108,1,2) 
    !JSC.Init(?ColorGrid,192,92,1,2) 
    JSC.Init(?ColorGrid,99,60,3,5) 
  END
  CurrentColor = SaveColor
  DO AnalyzeColor

SetPositions   ROUTINE
  DATA
HSLWidth     EQUATE(63)  
RGBWidth     EQUATE(51)
SpacerWidth  EQUATE(6)
ButtonSpacer EQUATE(1)
X            LONG
Y            LONG
W            LONG
H            LONG

  CODE

  ?HSL:HueDeg{PROP:XPos}         = ?AnalysisList{PROP:XPos} + 1
  ?HSL:HueDeg{PROP:Width}        = HSLWidth
  ?HSL:SaturationPct{PROP:XPos}  = ?HSL:HueDeg{PROP:XPos} + ?HSL:HueDeg{PROP:Width} + SpacerWidth
  ?HSL:SaturationPct{PROP:Width} = HSLWidth
  ?HSL:LightnessPct{PROP:XPos}   = ?HSL:SaturationPct{PROP:XPos} + ?HSL:SaturationPct{PROP:Width} + SpacerWidth
  ?HSL:LightnessPct{PROP:Width}  = HSLWidth
  ?RGB:Red{PROP:XPos}            = ?HSL:LightnessPct{PROP:XPos} + ?HSL:LightnessPct{PROP:Width} + SpacerWidth
  ?RGB:Red{PROP:Width}           = RGBWidth
  ?RGB:Green{PROP:XPos}          = ?RGB:Red{PROP:XPos} + ?RGB:Red{PROP:Width} + SpacerWidth
  ?RGB:Green{PROP:Width}         = RGBWidth
  ?RGB:Blue{PROP:XPos}           = ?RGB:Green{PROP:XPos} + ?RGB:Green{PROP:Width} + SpacerWidth
  ?RGB:Blue{PROP:Width}          = RGBWidth
  
  GETPOSITION(?AddToUserColorsButton,X,Y,W,H)
  SETPOSITION(?DeleteFromUserColorsButton,X+W+ButtonSpacer,Y,W,H)
  SETPOSITION(?ColorDialogButton,X+(W+ButtonSpacer)*2,Y,W,H)
  GETPOSITION(?BasicButton,X,Y,W,H)
  !SETPOSITION(?BasicButton,X,Y+H+ButtonSpacer,W,H) 
  SETPOSITION(?NormalButton,X+W+ButtonSpacer,Y,W,H)
  SETPOSITION(?FineButton,X+(W+ButtonSpacer)*2,Y,W,H)

