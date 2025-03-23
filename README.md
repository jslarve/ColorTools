# ColorExplorer
This is a sample application to showcase various unconventional things (some ridiculous<g>) that you can do with Clarion.
NOTE: This demo does require [Capesoft StringTheory](https://www.capesoft.com/docs/StringTheory3/StringTheory.htm) in some places.

Also NOTE: Some of these classes could be in varying states of completion.

Classes included with this demo:

1. [JSClassyFuncs](JSClassyFuncs.inc) - Various utility methods
2. [JSColorClass](JSColorClass.inc) - Does stuff with colors
3. [JSPalletClass](JSPaletteClass.inc) - Does stuff with collections of colors
4. [JSSelectSpinnerClass](JSSelectSpinnerClass.inc) - Select part of a hex number and scroll it like a spinner.

## JSClassyFuncs Class Documentation

### Methods Overview:

- **ARGBTOClarionColor(Long pColor) : Long**  
  Converts an ARGB color value to Clarion's native color format.

- **BNOT(Long pBitmap, Long pMask) : Long**  
  Performs bitwise NOT operation on bitmap using mask.

- **FixClarionLabel(String pLabel) : String**  
  Sanitizes input labels to ensure they comply with Clarion's legal character set.

- **GetContrastFontColor(Long pColor) : Long**  
  Calculates suitable contrasting (black or white) font color for a given background color.

- **GetFormatString(Long pColumns, Long pColumnWidth=2, Byte pExtraColumn=FALSE) : String**  
  Constructs a FORMAT() string for Clarion listboxes.

- **GetSystemColor(Long pIndexColor) : Long**  
  Retrieves a Clarion compatible color based on system color index.

- **HEX(Long pLong, Long pLen=6) : String**  
  Converts a Long integer into its hexadecimal string representation.

- **HexToClarionColor(String pHex, Long pIsClarion) : Long**  
  Converts hexadecimal color strings into Clarion-compatible color values.

- **InvalidateWindow()**  
  Triggers a refresh/redraw of the current window area.

- **KeepChars(String pBuffer, String pChars, Byte pCaseSensitive=TRUE) : String**  
  Returns a string containing only characters specified in a filter.

- **MoveParentFEQ(Long pParentFEQ, Long pXShift, Long pYShift, Byte pMoveType=0)**  
  Moves or shifts a window control and all its children by specified coordinates.

- **RGB2CMYK(Byte pR, Byte pG, Byte pB, *Byte pC, *Byte pM, Byte pY, Byte pK)**  
  Converts RGB color values to their equivalent CMYK values.

- **CMYK2RGB(Byte pC, Byte pM, Byte pY, Byte pK) : Long**  
  Converts CMYK color values into a Clarion-compatible RGB value.

- **StringIsBinary(String pS) : Long**  
  Determines if a string contains binary data based on null-byte occurrence.

- **SwitchEndian16(UShort pIN) : UShort**  
  Converts 16-bit integer values between big and little-endian byte orders.

- **SwitchEndian32(ULong pIN) : ULong**  
  Converts 32-bit integer values between big and little-endian byte orders.

- **WebHex(Long pColor) : String**  
  Converts Clarion color values into web-compatible hex color strings.

## JSColorClass Documentation

### Methods Overview:

- **AnalyzeColor(LONG pColor)**  
  Analyzes a given color and populates color details (HSL, RGB, hex values) into an internal structure (InfoString). It also populates a queue (ColorQ) with gradient variations based on hue, saturation, lightness, and RGB components for UI display.

- **ExpandHexColor(STRING pHex)**  
  Expands a short hex color (#abc) into a full 6-digit hex color (#aabbcc).

- **GetColorAt(LONG pCol, LONG pRow) : LONG**  
  Returns the color value stored at a given row and column from the internal color buffer.

- **GetContrastFontColor(LONG pColor) : LONG**  
  Determines and returns a font color (typically black or white) offering maximum contrast against the specified background color.

- **HEX(LONG pLong, LONG pLen=6) : STRING**  
  Returns the hex representation of a given color value padded to specified length (default 6 digits).

- **Init(LONG pFEQ, LONG pColumns=24, LONG pRows=24, LONG pCellWidth=2, LONG pCellHeight=2)**  
  Initializes a virtual listbox control for displaying colors, specifying dimensions, cell size, and formatting. Internally creates a color buffer and sets up callback routines.

- **ReduceHexColor(*CSTRING pHex) : BYTE**  
  Reduces a 6-digit hex color (#aabbcc) to a short 3-digit hex color (#abc) when possible. Returns TRUE if reduction succeeds.

- **RGBColor(BYTE pRed, BYTE pGreen, BYTE pBlue) : LONG**  
  Returns a combined color (LONG) value from given individual RGB byte components.

- **WebHex(LONG pColor) : STRING**  
  Returns the web-compatible hexadecimal string (#RRGGBB) representation of a given Clarion color value.

## JSPaletteClass Methods

### Methods Overview:

- **AddColor(LONG pColor, <STRING pName>, <STRING pDescription>, BYTE pRefresh=TRUE)**  
  Adds a new color entry to the palette with optional name and description. Optionally refreshes the list.

- **DeleteColor(LONG pIndex=0, LONG pColor=0)**  
  Removes a color from the palette by index or color value.

- **FetchColor(LONG pRow, LONG pColumn, <STRING pColorName>, <STRING pDescription>) : LONG**  
  Retrieves the color at the specified row and column, optionally returning its name and description. Returns the color value.

- **LoadAcoSwatch(<STRING pFileName>) : LONG**  
  Loads color entries from an Adobe Photoshop (.aco) swatch file. Returns the number of colors loaded.

- **Records() : LONG**  
  Returns the total number of color records currently in the palette.

