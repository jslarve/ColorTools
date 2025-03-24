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
  INCLUDE('JSPaletteClass.inc'),ONCE
  INCLUDE('StringTheory.inc'),ONCE

  MAP
    INCLUDE('CWUTIL.INC'),ONCE
    VLBproc(JSPaletteClass pSelf,LONG xRow, SHORT xCol),STRING,PRIVATE   
  END

ModST StringTheory

!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
JSPaletteClass.AddColor       PROCEDURE(LONG pColor,<STRING pName>,<STRING pDescription>,BYTE pRefresh=TRUE)
!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  CODE
  
  CLEAR(SELF.PaletteQ)
  IF NOT OMITTED(pName)
    SELF.PaletteQ.Name = CLIP(pName)
    GET(SELF.PaletteQ,SELF.PaletteQ.Name)
    IF NOT ERRORCODE()
      RETURN
    END
    SELF.PaletteQ.Name = CLIP(pName)
  ELSE
    SELF.PaletteQ.Color = pColor
    GET(SELF.PaletteQ,SELF.PaletteQ.Color)
    IF NOT ERRORCODE()
      RETURN
    END
  END  
  SELF.PaletteQ.Color = pColor
  IF NOT OMITTED(pDescription)
    SELF.PaletteQ.Description = CLIP(pDescription)
  END
  ColorToHSL(SELF.PaletteQ.Color,SELF.PaletteQ.HSL.lum,SELF.PaletteQ.HSL.Hue,SELF.PaletteQ.HSL.Sat)
  !ADD(SELF.PaletteQ,SELF.PaletteQ.HSL.Hue,SELF.PaletteQ.RGB.Red,SELF.PaletteQ.RGB.Green,SELF.PaletteQ.RGB.Blue)
  !ADD(SELF.PaletteQ,SELF.PaletteQ.HSL.Lum,SELF.PaletteQ.RGB.RED,SELF.PaletteQ.RGB.Green,SELF.PaletteQ.RGB.Blue)
  !ADD(SELF.PaletteQ,SELF.PaletteQ.HSL.Lum,SELF.PaletteQ.HSL.Hue,SELF.PaletteQ.HSL.Sat)
  !ADD(SELF.PaletteQ,SELF.PaletteQ.RGB.Red,SELF.PaletteQ.RGB.Green,SELF.PaletteQ.RGB.Blue)
  ADD(SELF.PaletteQ)
  IF pRefresh
    SELF.RefreshList
  END  
!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
JSPaletteClass.Construct      PROCEDURE
!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  CODE
  
  SELF.Initing   =  TRUE
  SELF.PaletteQ &=  NEW JSPaletteQ  
  SELF.JCF      &=  NEW JSClassyFuncs
  SELF.Popup    &=  NEW PopupClass
  SELF.Popup.Init()

!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
JSPaletteClass.DeleteColor    PROCEDURE(LONG pIndex=0,LONG pColor=0)
!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  CODE
  
  IF pIndex
    GET(SELF.PaletteQ,pIndex)
    IF ERRORCODE()
      RETURN
    ELSE
      DELETE(SELF.PaletteQ)
    END
  ELSE
    SELF.PaletteQ.Color = pColor
    GET(SELF.PaletteQ,SELF.PaletteQ.Color)
    IF ERRORCODE()
      RETURN
    ELSE
      DELETE(SELF.PaletteQ)
    END
  END
  SELF.RefreshList
  POST(EVENT:NewSelection,SELF.FEQ)

!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
JSPaletteClass.Destruct       PROCEDURE
!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  CODE
  
  DISPOSE(SELF.PaletteQ)
  DISPOSE(SELF.JCF)
  SELF.Popup.Kill
  DISPOSE(SELF.Popup)
  
JSPaletteClass.FetchColor     PROCEDURE(LONG pRow, LONG pColumn, <*STRING pColorName>,<*STRING pDescription>)!,LONG
QRow LONG

  CODE

  QRow = (pRow-1) * SELF.ColumnCount + pColumn

  IF NOT OMITTED(pColorName)
    pColorName = ''
  END
  IF NOT OMITTED(pDescription)
    pDescription = ''
  END
  
  GET(SELF.PaletteQ,QRow)
  IF NOT ERRORCODE()
    IF NOT OMITTED(pColorName)
      pColorName = SELF.PaletteQ.Name
    END
    IF NOT OMITTED(pDescription)
      pDescription = SELF.PaletteQ.Description
    END
    RETURN SELF.PaletteQ.Color
  END
  RETURN -1!SELF.JCF.GetSystemColor(COLOR:WINDOW)

JSPaletteClass.FillClarionColors  PROCEDURE

  CODE
   
  FREE(SELF.PaletteQ) 
  SELF.AddColor(COLOR:Black     ,'COLOR:Black'      ,, FALSE )
  SELF.AddColor(COLOR:Maroon    ,'COLOR:Maroon'     ,, FALSE )
  SELF.AddColor(COLOR:Green     ,'COLOR:Green'      ,, FALSE )
  SELF.AddColor(COLOR:Olive     ,'COLOR:Olive'      ,, FALSE )
  SELF.AddColor(COLOR:Orange    ,'COLOR:Orange'     ,, FALSE )
  SELF.AddColor(COLOR:Navy      ,'COLOR:Navy'       ,, FALSE )
  SELF.AddColor(COLOR:Purple    ,'COLOR:Purple'     ,, FALSE )
  SELF.AddColor(COLOR:Teal      ,'COLOR:Teal'       ,, FALSE )
  SELF.AddColor(COLOR:Gray      ,'COLOR:Gray'       ,, FALSE )
  SELF.AddColor(COLOR:Silver    ,'COLOR:Silver'     ,, FALSE )
  SELF.AddColor(COLOR:Red       ,'COLOR:Red'        ,, FALSE )
  SELF.AddColor(COLOR:Lime      ,'COLOR:Lime'       ,, FALSE )
  SELF.AddColor(COLOR:Yellow    ,'COLOR:Yellow'     ,, FALSE )
  SELF.AddColor(COLOR:Blue      ,'COLOR:Blue'       ,, FALSE )
  SELF.AddColor(COLOR:Fuchsia   ,'COLOR:Fuchsia'    ,, FALSE )
  SELF.AddColor(COLOR:Aqua      ,'COLOR:Aqua'       ,, FALSE )
  SELF.AddColor(COLOR:White     ,'COLOR:White'      ,, FALSE )
  COMPILE('**C11.1**',_C111_)
    SELF.AddColor(COLOR:RoyalBlue ,'COLOR:RoyalBlue'  ,, FALSE )
    SELF.AddColor(COLOR:SteelBlue ,'COLOR:SteelBlue'  ,, FALSE )
    SELF.AddColor(COLOR:SkyBlue   ,'COLOR:SkyBlue'    ,, FALSE )
    SELF.AddColor(COLOR:Sand      ,'COLOR:Sand'       ,, FALSE )
    SELF.AddColor(COLOR:LightSand ,'COLOR:LightSand'  ,, FALSE )
    SELF.AddColor(COLOR:LightGray ,'COLOR:LightGray'  ,, FALSE )
    SELF.AddColor(COLOR:Fuschia   ,'COLOR:Fuschia'    ,, FALSE )
  !**C11.1**
  SELF.RefreshList 
  
JSPaletteClass.FillHtmlColors     PROCEDURE !Colors supported by all modern browsers
!Temporary until I can build an .aco file
  CODE
  
  FREE(SELF.PaletteQ)
  SELF.AddColor(SELF.JCF.HexToClarionColor('F0F8FF',FALSE),'AliceBlue'           ,'Alice Blue'            , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('FAEBD7',FALSE),'AntiqueWhite'        ,'Antique White'         , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('00FFFF',FALSE),'Aqua'                ,'Aqua'                  , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('7FFFD4',FALSE),'Aquamarine'          ,'Aquamarine'            , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('F0FFFF',FALSE),'Azure'               ,'Azure'                 , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('F5F5DC',FALSE),'Beige'               ,'Beige'                 , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('FFE4C4',FALSE),'Bisque'              ,'Bisque'                , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('000000',FALSE),'Black'               ,'Black'                 , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('FFEBCD',FALSE),'BlanchedAlmond'      ,'Blanched Almond'       , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('0000FF',FALSE),'Blue'                ,'Blue'                  , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('8A2BE2',FALSE),'BlueViolet'          ,'Blue Violet'           , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('A52A2A',FALSE),'Brown'               ,'Brown'                 , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('DEB887',FALSE),'BurlyWood'           ,'BurlyWood'             , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('5F9EA0',FALSE),'CadetBlue'           ,'CadetBlue'             , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('7FFF00',FALSE),'Chartreuse'          ,'Chartreuse'            , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('D2691E',FALSE),'Chocolate'           ,'Chocolate'             , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('FF7F50',FALSE),'Coral'               ,'Coral'                 , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('6495ED',FALSE),'CornflowerBlue'      ,'Cornflower Blue'       , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('FFF8DC',FALSE),'Cornsilk'            ,'Cornsilk'              , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('DC143C',FALSE),'Crimson'             ,'Crimson'               , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('00FFFF',FALSE),'Cyan'                ,'Cyan'                  , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('00008B',FALSE),'DarkBlue'            ,'Dark Blue'             , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('008B8B',FALSE),'DarkCyan'            ,'Dark Cyan'             , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('B8860B',FALSE),'DarkGoldenRod'       ,'Dark GoldenRod'        , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('A9A9A9',FALSE),'DarkGray'            ,'Dark Gray'             , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('A9A9A9',FALSE),'DarkGrey'            ,'Dark Grey'             , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('006400',FALSE),'DarkGreen'           ,'Dark Green'            , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('BDB76B',FALSE),'DarkKhaki'           ,'Dark Khaki'            , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('8B008B',FALSE),'DarkMagenta'         ,'DarkMagenta'           , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('556B2F',FALSE),'DarkOliveGreen'      ,'Dark OliveGreen'       , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('FF8C00',FALSE),'DarkOrange'          ,'Dark Orange'           , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('9932CC',FALSE),'DarkOrchid'          ,'Dark Orchid'           , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('8B0000',FALSE),'DarkRed'             ,'Dark Red'              , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('E9967A',FALSE),'DarkSalmon'          ,'Dark Salmon'           , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('8FBC8F',FALSE),'DarkSeaGreen'        ,'Dark SeaGreen'         , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('483D8B',FALSE),'DarkSlateBlue'       ,'Dark Slate Blue'       , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('2F4F4F',FALSE),'DarkSlateGray'       ,'Dark Slate Gray'       , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('2F4F4F',FALSE),'DarkSlateGrey'       ,'Dark Slate Grey'       , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('00CED1',FALSE),'DarkTurquoise'       ,'Dark Turquoise'        , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('9400D3',FALSE),'DarkViolet'          ,'Dark Violet'           , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('FF1493',FALSE),'DeepPink'            ,'Deep Pink'             , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('00BFFF',FALSE),'DeepSkyBlue'         ,'Deep Sky Blue'         , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('696969',FALSE),'DimGray'             ,'Dim Gray'              , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('696969',FALSE),'DimGrey'             ,'Dim Grey'              , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('1E90FF',FALSE),'DodgerBlue'          ,'Dodger Blue'           , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('B22222',FALSE),'FireBrick'           ,'Fire Brick'            , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('FFFAF0',FALSE),'FloralWhite'         ,'Floral White'          , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('228B22',FALSE),'ForestGreen'         ,'Forest Green'          , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('FF00FF',FALSE),'Fuchsia'             ,'Fuchsia'               , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('DCDCDC',FALSE),'Gainsboro'           ,'Gainsboro'             , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('F8F8FF',FALSE),'GhostWhite'          ,'Ghost White'           , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('FFD700',FALSE),'Gold'                ,'Gold'                  , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('DAA520',FALSE),'GoldenRod'           ,'GoldenRod'             , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('808080',FALSE),'Gray'                ,'Gray'                  , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('808080',FALSE),'Grey'                ,'Grey'                  , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('008000',FALSE),'Green'               ,'Green'                 , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('ADFF2F',FALSE),'GreenYellow'         ,'GreenYellow'           , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('F0FFF0',FALSE),'HoneyDew'            ,'HoneyDew'              , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('FF69B4',FALSE),'HotPink'             ,'Hot Pink'              , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('CD5C5C',FALSE),'IndianRed'           ,'Indian Red'            , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('4B0082',FALSE),'Indigo'              ,'Indigo'                , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('FFFFF0',FALSE),'Ivory'               ,'Ivory'                 , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('F0E68C',FALSE),'Khaki'               ,'Khaki'                 , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('E6E6FA',FALSE),'Lavender'            ,'Lavender'              , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('FFF0F5',FALSE),'LavenderBlush'       ,'Lavender Blush'        , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('7CFC00',FALSE),'LawnGreen'           ,'Lawn Green'            , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('FFFACD',FALSE),'LemonChiffon'        ,'Lemon Chiffon'         , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('ADD8E6',FALSE),'LightBlue'           ,'Light Blue'            , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('F08080',FALSE),'LightCoral'          ,'Light Coral'           , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('E0FFFF',FALSE),'LightCyan'           ,'Light Cyan'            , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('FAFAD2',FALSE),'LightGoldenRodYellow','Light GoldenRod Yellow', FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('D3D3D3',FALSE),'LightGray'           ,'Light Gray'            , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('D3D3D3',FALSE),'LightGrey'           ,'Light Grey'            , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('90EE90',FALSE),'LightGreen'          ,'Light Green'           , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('FFB6C1',FALSE),'LightPink'           ,'Light Pink'            , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('FFA07A',FALSE),'LightSalmon'         ,'Light Salmon'          , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('20B2AA',FALSE),'LightSeaGreen'       ,'Light Sea Green'       , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('87CEFA',FALSE),'LightSkyBlue'        ,'Light Sky Blue'        , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('778899',FALSE),'LightSlateGray'      ,'Light Slate Gray'      , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('778899',FALSE),'LightSlateGrey'      ,'Light Slate Grey'      , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('B0C4DE',FALSE),'LightSteelBlue'      ,'Light Steel Blue'      , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('FFFFE0',FALSE),'LightYellow'         ,'Light Yellow'          , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('00FF00',FALSE),'Lime'                ,'Lime'                  , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('32CD32',FALSE),'LimeGreen'           ,'Lime Green'            , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('FAF0E6',FALSE),'Linen'               ,'Linen'                 , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('FF00FF',FALSE),'Magenta'             ,'Magenta'               , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('800000',FALSE),'Maroon'              ,'Maroon'                , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('66CDAA',FALSE),'MediumAquaMarine'    ,'Medium Aqua Marine'    , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('0000CD',FALSE),'MediumBlue'          ,'Medium Blue'           , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('BA55D3',FALSE),'MediumOrchid'        ,'Medium Orchid'         , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('9370DB',FALSE),'MediumPurple'        ,'Medium Purple'         , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('3CB371',FALSE),'MediumSeaGreen'      ,'Medium Sea Green'      , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('7B68EE',FALSE),'MediumSlateBlue'     ,'Medium Slate Blue'     , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('00FA9A',FALSE),'MediumSpringGreen'   ,'Medium Spring Green'   , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('48D1CC',FALSE),'MediumTurquoise'     ,'Medium Turquoise'      , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('C71585',FALSE),'MediumVioletRed'     ,'Medium Violet Red'     , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('191970',FALSE),'MidnightBlue'        ,'Midnight Blue'         , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('F5FFFA',FALSE),'MintCream'           ,'Mint Cream'            , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('FFE4E1',FALSE),'MistyRose'           ,'Misty Rose'            , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('FFE4B5',FALSE),'Moccasin'            ,'Moccasin'              , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('FFDEAD',FALSE),'NavajoWhite'         ,'Navajo White'          , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('000080',FALSE),'Navy'                ,'Navy'                  , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('FDF5E6',FALSE),'OldLace'             ,'OldLace'               , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('808000',FALSE),'Olive'               ,'Olive'                 , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('6B8E23',FALSE),'OliveDrab'           ,'Olive Drab'            , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('FFA500',FALSE),'Orange'              ,'Orange'                , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('FF4500',FALSE),'OrangeRed'           ,'Orange Red'            , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('DA70D6',FALSE),'Orchid'              ,'Orchid'                , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('EEE8AA',FALSE),'PaleGoldenRod'       ,'Pale GoldenRod'        , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('98FB98',FALSE),'PaleGreen'           ,'Pale Green'            , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('AFEEEE',FALSE),'PaleTurquoise'       ,'Pale Turquoise'        , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('DB7093',FALSE),'PaleVioletRed'       ,'Pale VioletRed'        , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('FFEFD5',FALSE),'PapayaWhip'          ,'Papaya Whip'           , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('FFDAB9',FALSE),'PeachPuff'           ,'Peach Puff'            , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('CD853F',FALSE),'Peru'                ,'Peru'                  , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('FFC0CB',FALSE),'Pink'                ,'Pink'                  , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('DDA0DD',FALSE),'Plum'                ,'Plum'                  , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('B0E0E6',FALSE),'PowderBlue'          ,'Powder Blue'           , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('800080',FALSE),'Purple'              ,'Purple'                , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('663399',FALSE),'RebeccaPurple'       ,'Rebecca Purple'        , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('FF0000',FALSE),'Red'                 ,'Red'                   , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('BC8F8F',FALSE),'RosyBrown'           ,'Rosy Brown'            , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('4169E1',FALSE),'RoyalBlue'           ,'Royal Blue'            , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('8B4513',FALSE),'SaddleBrown'         ,'Saddle Brown'          , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('FA8072',FALSE),'Salmon'              ,'Salmon'                , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('F4A460',FALSE),'SandyBrown'          ,'Sandy Brown'           , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('2E8B57',FALSE),'SeaGreen'            ,'Sea Green'             , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('FFF5EE',FALSE),'SeaShell'            ,'Sea Shell'             , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('A0522D',FALSE),'Sienna'              ,'Sienna'                , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('C0C0C0',FALSE),'Silver'              ,'Silver'                , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('87CEEB',FALSE),'SkyBlue'             ,'SkyBlue'               , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('6A5ACD',FALSE),'SlateBlue'           ,'SlateBlue'             , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('708090',FALSE),'SlateGray'           ,'Slate Gray'            , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('708090',FALSE),'SlateGrey'           ,'Slate Grey'            , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('FFFAFA',FALSE),'Snow'                ,'Snow'                  , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('00FF7F',FALSE),'SpringGreen'         ,'Spring Green'          , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('4682B4',FALSE),'SteelBlue'           ,'Steel Blue'            , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('D2B48C',FALSE),'Tan'                 ,'Tan'                   , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('008080',FALSE),'Teal'                ,'Teal'                  , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('D8BFD8',FALSE),'Thistle'             ,'Thistle'               , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('FF6347',FALSE),'Tomato'              ,'Tomato'                , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('40E0D0',FALSE),'Turquoise'           ,'Turquoise'             , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('EE82EE',FALSE),'Violet'              ,'Violet'                , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('F5DEB3',FALSE),'Wheat'               ,'Wheat'                 , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('FFFFFF',FALSE),'White'               ,'White'                 , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('F5F5F5',FALSE),'WhiteSmoke'          ,'White Smoke'           , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('FFFF00',FALSE),'Yellow'              ,'Yellow'                , FALSE)
  SELF.AddColor(SELF.JCF.HexToClarionColor('9ACD32',FALSE),'YellowGreen'         ,'Yellow Green'          , FALSE)
                                                                                                                                                                                                                  
  SELF.RefreshList
                                                                                                                                                                                                                  
JSPaletteClass.FillSystemColors   PROCEDURE
 
!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  CODE
  
  FREE(SELF.PaletteQ)
  SELF.AddColor(COLOR:SCROLLBAR                                       ,'ScrollBar'                    ,'COLOR:SCROLLBAR', FALSE)
  SELF.AddColor(SELF.JCF.GetSystemColor(COLOR:SCROLLBAR)              ,'ScrollBar (RGB)'              ,, FALSE)
  SELF.AddColor(COLOR:BACKGROUND                                      ,'Background'                   ,'COLOR:BACKGROUND', FALSE)
  SELF.AddColor(SELF.JCF.GetSystemColor(COLOR:BACKGROUND)             ,'Background (RGB)'             ,, FALSE)
  SELF.AddColor(COLOR:ACTIVECAPTION                                   ,'ActiveCaption'                ,'COLOR:ACTIVECAPTION', FALSE)
  SELF.AddColor(SELF.JCF.GetSystemColor(COLOR:ACTIVECAPTION)          ,'ActiveCaption (RGB)'          ,, FALSE)
  SELF.AddColor(COLOR:INACTIVECAPTION                                 ,'InactiveCaption'              ,'COLOR:INACTIVECAPTION', FALSE)
  SELF.AddColor(SELF.JCF.GetSystemColor(COLOR:INACTIVECAPTION)        ,'InactiveCaption (RGB)'        ,, FALSE)
  SELF.AddColor(COLOR:MENU                                            ,'Menu'                         ,'COLOR:MENU', FALSE)
  SELF.AddColor(SELF.JCF.GetSystemColor(COLOR:MENU)                   ,'Menu (RGB)'                   ,, FALSE)
  SELF.AddColor(COLOR:MENUBAR                                         ,'MenuBar'                      ,'COLOR:MENUBAR', FALSE)
  SELF.AddColor(SELF.JCF.GetSystemColor(COLOR:MENUBAR)                ,'MenuBar (RGB)'                ,, FALSE)
  SELF.AddColor(COLOR:WINDOW                                          ,'Window'                       ,'COLOR:WINDOW', FALSE)
  SELF.AddColor(SELF.JCF.GetSystemColor(COLOR:WINDOW)                 ,'Window (RGB)'                 ,, FALSE)
  SELF.AddColor(COLOR:WINDOWFRAME                                     ,'WindowFrame'                  ,'COLOR:WINDOWFRAME', FALSE)
  SELF.AddColor(SELF.JCF.GetSystemColor(COLOR:WINDOWFRAME)            ,'WindowFrame (RGB)'            ,, FALSE)
  SELF.AddColor(COLOR:MENUTEXT                                        ,'MenuText'                     ,'COLOR:MENUTEXT', FALSE)
  SELF.AddColor(SELF.JCF.GetSystemColor(COLOR:MENUTEXT)               ,'MenuText (RGB)'               ,, FALSE)
  SELF.AddColor(COLOR:WINDOWTEXT                                      ,'WindowText'                   ,'COLOR:WINDOWTEXT', FALSE)
  SELF.AddColor(SELF.JCF.GetSystemColor(COLOR:WINDOWTEXT)             ,'WindowText (RGB)'             ,, FALSE)
  SELF.AddColor(COLOR:CAPTIONTEXT                                     ,'CaptionText'                  ,'COLOR:CAPTIONTEXT', FALSE)
  SELF.AddColor(SELF.JCF.GetSystemColor(COLOR:CAPTIONTEXT)            ,'CaptionText (RGB)'            ,, FALSE)
  SELF.AddColor(COLOR:ACTIVEBORDER                                    ,'ActiveBorder'                 ,'COLOR:ACTIVEBORDER', FALSE)
  SELF.AddColor(SELF.JCF.GetSystemColor(COLOR:ACTIVEBORDER)           ,'ActiveBorder (RGB)'           ,, FALSE)
  SELF.AddColor(COLOR:INACTIVEBORDER                                  ,'InactiveBorder'               ,'COLOR:INACTIVEBORDER', FALSE)
  SELF.AddColor(SELF.JCF.GetSystemColor(COLOR:INACTIVEBORDER)         ,'InactiveBorder (RGB)'         ,, FALSE)
  SELF.AddColor(COLOR:APPWORKSPACE                                    ,'AppWorkspace'                 ,'COLOR:APPWORKSPACE', FALSE)
  SELF.AddColor(SELF.JCF.GetSystemColor(COLOR:APPWORKSPACE)           ,'AppWorkspace (RGB)'           ,, FALSE)
  SELF.AddColor(COLOR:HIGHLIGHT                                       ,'Highlight'                    ,'COLOR:HIGHLIGHT', FALSE)
  SELF.AddColor(SELF.JCF.GetSystemColor(COLOR:HIGHLIGHT)              ,'Highlight (RGB)'              ,, FALSE)
  SELF.AddColor(COLOR:HIGHLIGHTTEXT                                   ,'HighlightText'                ,'COLOR:HIGHLIGHTTEXT', FALSE)
  SELF.AddColor(SELF.JCF.GetSystemColor(COLOR:HIGHLIGHTTEXT)          ,'HighlightText (RGB)'          ,, FALSE)
  SELF.AddColor(COLOR:BTNFACE                                         ,'ButtonFace'                   ,'COLOR:BTNFACE', FALSE)
  SELF.AddColor(SELF.JCF.GetSystemColor(COLOR:BTNFACE)                ,'ButtonFace (RGB)'             ,, FALSE)
  SELF.AddColor(COLOR:BTNSHADOW                                       ,'ButtonShadow'                 ,'COLOR:BTNSHADOW', FALSE)
  SELF.AddColor(SELF.JCF.GetSystemColor(COLOR:BTNSHADOW)              ,'ButtonShadow (RGB)'           ,, FALSE)
  SELF.AddColor(COLOR:GRAYTEXT                                        ,'GrayText'                     ,'COLOR:GRAYTEXT', FALSE)
  SELF.AddColor(SELF.JCF.GetSystemColor(COLOR:GRAYTEXT)               ,'GrayText (RGB)'               ,, FALSE)
  SELF.AddColor(COLOR:BTNTEXT                                         ,'ButtonText'                   ,'COLOR:BTNTEXT', FALSE)
  SELF.AddColor(SELF.JCF.GetSystemColor(COLOR:BTNTEXT)                ,'ButtonText (RGB)'             ,, FALSE)
  SELF.AddColor(COLOR:INACTIVECAPTIONTEXT                             ,'InactiveCaptionText'          ,'COLOR:INACTIVECAPTIONTEXT', FALSE)
  SELF.AddColor(SELF.JCF.GetSystemColor(COLOR:INACTIVECAPTIONTEXT)    ,'InactiveCaptionText (RGB)'    ,, FALSE)
  SELF.AddColor(COLOR:BTNHIGHLIGHT                                    ,'ButtonHighlight'              ,'COLOR:BTNHIGHLIGHT', FALSE)
  SELF.AddColor(SELF.JCF.GetSystemColor(COLOR:BTNHIGHLIGHT)           ,'ButtonHighlight (RGB)'        ,, FALSE)
  COMPILE('**C11.1**',_C111_)
    SELF.AddColor(COLOR:3DDkShadow                                      ,'3DDkShadow'                   ,'COLOR:3DDkShadow', FALSE)
    SELF.AddColor(SELF.JCF.GetSystemColor(COLOR:3DDkShadow)             ,'3DDkShadow (RGB)'             ,, FALSE)
    SELF.AddColor(COLOR:3DLight                                         ,'3DLight'                      ,'COLOR:3DLight', FALSE)
    SELF.AddColor(SELF.JCF.GetSystemColor(COLOR:3DLight)                ,'3DLight (RGB)'                ,, FALSE)
    SELF.AddColor(COLOR:InfoText                                        ,'InfoText'                     ,'COLOR:InfoText', FALSE)
    SELF.AddColor(SELF.JCF.GetSystemColor(COLOR:InfoText)               ,'InfoText (RGB)'               ,, FALSE)
    SELF.AddColor(COLOR:InfoBackground                                  ,'InfoBackground'               ,'COLOR:InfoBackground', FALSE)
    SELF.AddColor(SELF.JCF.GetSystemColor(COLOR:InfoBackground)         ,'InfoBackground (RGB)'         ,, FALSE)
    SELF.AddColor(COLOR:HotLight                                        ,'HotLight'                     ,'COLOR:HotLight', FALSE)
    SELF.AddColor(SELF.JCF.GetSystemColor(COLOR:HotLight)               ,'HotLight (RGB)'               ,, FALSE)
    SELF.AddColor(COLOR:GradientActiveCaption                           ,'GradientActiveCaption'        ,'COLOR:GradientActiveCaption', FALSE)
    SELF.AddColor(SELF.JCF.GetSystemColor(COLOR:GradientActiveCaption)  ,'GradientActiveCaption (RGB)'  ,, FALSE)
    SELF.AddColor(COLOR:GradientInactiveCaption                         ,'GradientInactiveCaption'      ,'COLOR:GradientInactiveCaption', FALSE)
    SELF.AddColor(SELF.JCF.GetSystemColor(COLOR:GradientInactiveCaption),'GradientInactiveCaption (RGB)',, FALSE)
    SELF.AddColor(COLOR:MenuHighlight                                   ,'MenuHighlight'                ,'COLOR:MenuHighlight', FALSE)
    SELF.AddColor(SELF.JCF.GetSystemColor(COLOR:MenuHighlight)          ,'MenuHighlight (RGB)'          ,, FALSE)
  !**C11.1**
  SELF.RefreshList
  
JSPaletteClass.FillWebSafeColors  PROCEDURE
ThisColor  LONG
RGB        GROUP,OVER(ThisColor)
Red          BYTE
Green        BYTE
Blue         BYTE
Alpha        BYTE
           END

  CODE
  
  FREE(SELF.PaletteQ)
  CLEAR(ThisColor)
  LOOP RGB.Red = 0h TO 0FFh BY 33h
    LOOP RGB.Green = 0h TO 0FFh BY 33h
      LOOP RGB.Blue = 0h TO 0FFh BY 33h
        SELF.AddColor(ThisColor,,,FALSE)
      END
    END
  END
  SELF.RefreshList
  
JSPaletteClass.FindColor      PROCEDURE(<LONG pColor>,<STRING pSearchText>,BYTE pSelectListBox=TRUE,<*LONG pFoundColor>,<*STRING pName>,<*STRING pDescription>)!,BYTE  
DummyColor   LONG
DummyString  STRING(10)
rFoundColor  &LONG
rName        &STRING
rDescription &STRING
SearchText   LIKE(SELF.PaletteQ.Description)
Ndx          LONG

UseSearchText LIKE(SELF.PaletteQ.Description)
Window WINDOW('Find Color'),AT(,,203,37),CENTER,GRAY,FONT('Segoe UI',9)
    PROMPT('Find:'),AT(5,4,17),USE(?PROMPT1)
    ENTRY(@s200),AT(26,4,174),USE(UseSearchText)
    BUTTON('&OK'),AT(113,19,41,14),USE(?OkButton),DEFAULT
    BUTTON('&Cancel'),AT(159,19,42,14),USE(?CancelButton)
  END

  CODE
  
  IF OMITTED(pColor)
    IF OMITTED(pSearchText) OR pSearchText = ''
      OPEN(Window)
      ACCEPT
        CASE ACCEPTED()
        OF ?OkButton
          IF NOT UseSearchText
            SELECT(?UseSearchText)
            CYCLE
          END
          SearchText = UPPER(UseSearchText)
          POST(EVENT:CloseWindow)
        OF ?CancelButton
          RETURN FALSE
        END
      END
      CLOSE(Window)
    ELSE  
      SearchText = UPPER(pSearchText)
    END
    LOOP Ndx = 1 TO RECORDS(SELF.PaletteQ)
      GET(SELF.PaletteQ,Ndx)
      IF ERRORCODE() 
        BREAK
      END
      IF INSTRING(SearchText,UPPER(SELF.PaletteQ.Name),1,1) OR INSTRING(SearchText,UPPER(SELF.PaletteQ.Description),1,1) OR INSTRING(SearchText,SELF.JCF.WebHex(SELF.PaletteQ.Color),1,1)
         DO SetFound
         RETURN TRUE
      END
    END
  ELSE
    SELF.PaletteQ.Color = pColor
    GET(SELF.PaletteQ,SELF.PaletteQ.Color)
    DO SetFound
    RETURN TRUE
  END
  RETURN FALSE
  
SetFound  ROUTINE

  IF NOT OMITTED(pFoundColor)
    pFoundColor = SELF.PaletteQ.Color
  END
  IF NOT OMITTED(pName)
    pName = SELF.PaletteQ.Name
  END
  IF NOT OMITTED(pDescription)
    pDescription = SELF.PaletteQ.Description
  END
  IF pSelectListBox
     x# = CHOICE(SELF.FEQ)
     
       !SELF.RowCount    = (Recs / SELF.ColumnCount) + CHOOSE(Recs % SELF.ColumnCount)

     SELF.FEQ{PROP:Selected} = INT(POINTER(SELF.PaletteQ)/SELF.ColumnCount) + 1
     SELF.FEQ{PROP:Column} = (POINTER(SELF.PaletteQ) % SELF.ColumnCount) + CHOOSE((POINTER(SELF.PaletteQ) % SELF.ColumnCount)=0,1,0)
     POST(EVENT:NewSelection,SELF.FEQ)
  END
  
JSPaletteClass.Init           PROCEDURE(LONG pFEQ,LONG pColumnWidth,LONG pRowHeight,<STRING pPicture>,LONG pColumnCount=0)
SavePixels    BYTE
OriginalWidth LONG

  CODE
  
  SELF.Initing = TRUE
  SavePixels   = 0{PROP:Pixels}
  
  IF pFEQ{PROP:Type} <> CREATE:list
    RETURN
  END
  0{PROP:Pixels}            =  TRUE
  SELF.FEQ                  =  pFEQ
  OriginalWidth             =  pFEQ{PROP:Width}
  SELF.FEQ{PROP:LineHeight} =  pRowHeight
  IF pColumnWidth = -1
    IF pColumnCount
       pColumnWidth = (SELF.FEQ{PROP:Width} / pColumnCount) - 6
    END
  END
  IF pColumnCount
    SELF.ColumnCount          =  ABS(pColumnCount)
  ELSE
    SELF.ColumnCount          =  SELF.FEQ{PROP:Width} / pColumnWidth ! - 1
  END  
  IF NOT OMITTED(pPicture)
    SELF.FEQ{PROP:FORMAT    } =  SELF.JCF.GetFormatString(SELF.ColumnCount,pColumnWidth,pPicture,FALSE)
  ELSE
    SELF.FEQ{PROP:FORMAT    } =  SELF.JCF.GetFormatString(SELF.ColumnCount,pColumnWidth,,FALSE)
  END  
  !SELF.FEQ{PROP:Height    } =  pRowHeight  
  IF ((pColumnWidth + 1)  * SELF.ColumnCount) + 2 > OriginalWidth
    SELF.ColumnCount -= 1
  END
  !SELF.FEQ{PROP:Width     } =  ((pColumnWidth + 1)  * SELF.ColumnCount) + 2
  SELF.FEQ{PROP:VLBVal    } =  ADDRESS(SELF)
  SELF.FEQ{PROP:VLBProc   } =  ADDRESS(SELF.VLBProc)
  SELF.FEQ{PROPLIST:BarFrame} = COLOR:White

  0{PROP:Pixels}            = SavePixels

  SELF.Initing              =  FALSE
  SELF.RefreshList

JSPaletteClass.LoadAcoSwatch  PROCEDURE(<STRING pFileName>)!,LONG
ST         StringTheory
FileName   CSTRING(FILE:MaxFilePath)  
UShortRef  &USHORT
ULongRef   &ULONG
StringRef  &STRING
Addr       LONG
StringLen  LONG
Version    SHORT
ColorCount SHORT
Ndx        LONG
ColorSpace USHORT
ColorVal1  USHORT
ColorVal2  USHORT
ColorVal3  USHORT
ColorVal4  USHORT
Hue        REAL
Saturation REAL
Brightness REAL
NameLen    LONG
NameRef   &STRING
Name       CSTRING(31)
NameST     StringTheory
C REAL
M REAL
Y REAL
K REAL
RGBColor       LONG
RGB            GROUP,OVER(RGBColor),PRE(RGB)
Red              BYTE               ! These fields are used in the Red, Green, Blue spinners 
Green            BYTE
Blue             BYTE
               END


  CODE

  IF OMITTED(pFileName)  
    IF NOT FILEDIALOG('Select Swatch',FileName,'*.aco',FILE:KeepDir+FILE:LongName)
      RETURN 0
    END
  ELSE
    FileName = CLIP(pFileName)
  END  
  IF NOT ST.LoadFile(FileName)
    MESSAGE('Unable to load file: "' & FileName & '"')
    RETURN 0
  END
  StringRef &= ST.GetValuePtr()
  Addr       = ADDRESS(StringRef)
  StringLen  = LEN(StringRef)
  IF StringLen < 10
    MESSAGE('Nothing in file')
    RETURN 0
  END
  Ndx = 0
  UShortRef &= Addr + Ndx
  Version = SELF.JCF.SwitchEndian16(UShortRef)
  Ndx += 2
  UShortRef &= Addr + Ndx
  ColorCount = SELF.JCF.SwitchEndian16(UShortRef)
  LOOP 
    IF Ndx >= StringLen - 10
      BREAK
    END
    Ndx += 2
    UShortRef &= Addr + Ndx
    ColorSpace = SELF.JCF.SwitchEndian16(UShortRef)
    Ndx += 2
    UShortRef &= Addr + (Ndx)
    ColorVal1 = SELF.JCF.SwitchEndian16(UShortRef)
    Ndx += 2
    UShortRef &= Addr + (Ndx)
    ColorVal2 = SELF.JCF.SwitchEndian16(UShortRef)
    Ndx += 2
    UShortRef &= Addr + (Ndx)
    ColorVal3 = SELF.JCF.SwitchEndian16(UShortRef)
    Ndx += 2
    UShortRef &= Addr + (Ndx)
    ColorVal4 = SELF.JCF.SwitchEndian16(UShortRef)
    CASE ColorSpace
    OF 0 !RGB
      RGB.Red = INT(ColorVal1 / 256)
      RGB.Green = INT(ColorVal2 / 256)
      RGB.Blue = INT(ColorVal3 / 256)
    OF 1 !HSB  
      Hue = ColorVal1 / 182.04
      Saturation = ColorVal2 / 655.35
      Brightness = ColorVal3 / 655.35
      HSLToColor(Hue,Saturation,Brightness,RGBColor)
    OF 2 !CMYK
      C = ROUND((1-(ColorVal1/0FFFFh)) * 100,1)
      M = ROUND((1-(ColorVal2/0FFFFh)) * 100,1)
      Y = ROUND((1-(ColorVal3/0FFFFh)) * 100,1)
      K = ROUND((1-(ColorVal4/0FFFFh)) * 100,1)
      RGBColor = SELF.JCF.CMYK2RGB(C,M,Y,K)
    OF 8 !Grayscale
      RGB.Red   = INT(ColorVal1 / 39.0625)
      RGB.Green = RGB.Red
      RGB.Blue  = RGB.Red
    ELSE
      MESSAGE('Color Space ' & ColorSpace & ' is not yet supported.||"' & FileName & '"')
      RETURN 0   
    END 
    NameRef &= NULL
    Name = ''
    CASE Version 
    OF 2
      Ndx += 2
      ULongRef &= Addr + Ndx
      NameLen = SELF.JCF.SwitchEndian32(ULongRef)
      IF NameLen > 0
        Ndx += 4
        NameRef        &= Addr + Ndx & ':' & NameLen * 2       
        NameST.encoding = st:EncodeUtf16
        NameST.endian   = st:BigEndian
        NameST.SetValue(NameRef)
        NameST.LittleEndian
        NameST.ToAnsi
        Name = NameST.GetValue() 
        Ndx += (NameLen * 2) - 2
      END
    END 
    IF NAME
      SELF.AddColor(RGBColor,Name,,FALSE)
    ELSE
      SELF.AddColor(RGBColor,,,FALSE)
    END
!    ST.Trace('ColorSpace=' & ColorSpace & '  ColorVal1=' & ColorVal1  & '  ColorVal2=' & ColorVal2  & '  ColorVal3=' & ColorVal3  & '  ColorVal4=' & ColorVal4 & '  Name="' & ST.GetValue() & '"  NameLen=' & NameLen )
    
  END
  SELF.RefreshList
  RETURN RECORDS(SELF.PaletteQ)

JSPaletteClass.Records        PROCEDURE

  CODE
  
  RETURN RECORDS(SELF.PaletteQ)

JSPaletteClass.RefreshList    PROCEDURE
Recs LONG
ST   StringTheory
  CODE
  
  Recs             = RECORDS(SELF.PaletteQ)
  SELF.RowCount    = (Recs / SELF.ColumnCount) + CHOOSE(Recs % SELF.ColumnCount)
  !ST.Trace('RefreshList - SELF.RowCount = ' & SELF.RowCount & '  Recs=' & Recs)  
  IF SELF.RowCount < 1
    SELF.RowCount = 1
  END
  SELF.ChangesHash = 0
  DISPLAY(SELF.FEQ)
  
JSPaletteClass.SetShowText     PROCEDURE(BYTE pShowText=TRUE)  

  CODE
  
  SELF.ShowText = pShowText
  SELF.RefreshList
!------------------------------------------------------------------------------------------------------------------------------------------------------
!!! <summary>Private method for virtual listbox</summary>
!!! <returns>String containing cell data</returns>
!======================================================================================================================================================
JSPaletteClass.VLBproc     PROCEDURE(LONG xRow, SHORT xCol)!,STRING,PRIVATE   
ROW:GetRowCount  EQUATE(-1)
ROW:GetColCount  EQUATE(-2)
ROW:IsQChanged   EQUATE(-3)
ReturnColor      LONG
col              LONG  
QRow             LONG
ST               StringTheory
ColorName        STRING(30)
Description      STRING(200)

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
    IF SELF.ChangesHash <> CHANGES(SELF.PaletteQ)
      SELF.ChangesHash = CHANGES(SELF.PaletteQ)
      RETURN TRUE
    END
    RETURN FALSE
  END
  col = ((xCol+5) / 6)  

  IF NOT col
    col = 1
  END   
  IF col > SELF.ColumnCount
    ReturnColor = -1
    Description = '' 
  ELSE
    ReturnColor = SELF.FetchColor(xRow,col,ColorName,Description)
  END

  CASE xCol % 6 
  OF 0 !Tooltip column#
    IF col > SELF.ColumnCount
      RETURN ''
    END
    IF Description
      RETURN Description
    END
    RETURN SELF.JCF.WebHex(ReturnColor)
  OF 1
    IF col > SELF.ColumnCount OR NOT SELF.ShowText
      RETURN ''
    END
    IF ColorName
      RETURN ColorName
    END
    RETURN SELF.JCF.WebHex(ReturnColor)
  OF 2 OROF 4
    RETURN SELF.JCF.GetContrastFontColor(ReturnColor)
  END  
  RETURN ReturnColor
  
  