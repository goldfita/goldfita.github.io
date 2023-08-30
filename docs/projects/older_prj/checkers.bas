DEFINT A-Z
CONST NEGMAXINT = -32768
CONST FALSE = 0
CONST TRUE = -1
CONST COLCOORDINATE = 1
CONST ROWCOORDINATE = 2
CONST PLAYER1 = 1
CONST PLAYER2 = -1
CONST p1$ = "Player1"
CONST p2$ = "Player2"
CONST MAXPIECES = 12
CONST MAXKINGS = MAXPIECES / 2
CONST MAXROWS = 8
CONST MAXCOLS = 8
CONST xSize = 640
CONST ySize = 480
CONST x! = (xSize - 1) / 8, y! = (ySize - 1) / 8
CONST EMPTEY = 0
CONST NORMALPIECE = 1
CONST KING = 2
CONST MARKEDFORDELETE = 4
CONST ALLPHANTOMS = NOT (NORMALPIECE OR KING OR MARKEDFORDELETE OR NEGMAXINT)
CONST NEWATTRIBUTE = 0
CONST ADDATTRIBUTE = 1
CONST REMOVEATTRIBUTE = 2
CONST black = 0
CONST blue = 1
CONST green = 2
CONST cyan = 3
CONST red = 4
CONST magenta = 5
CONST brown = 6
CONST white = 7
CONST gray = 8
CONST lightBlue = 9
CONST lightGreen = 10
CONST lightCyan = 11
CONST lightRed = 12
CONST lightMagenta = 13
CONST yellow = 14
CONST highIntensityWhite = 15
CONST pOneColor = blue
CONST pTwoColor = green
CONST posBorderColor = lightMagenta
COMMON SHARED player
COMMON SHARED posRow, posCol
COMMON SHARED cheat
DIM SHARED board(1 TO MAXROWS, 1 TO MAXCOLS)
DIM SHARED kingFace(353)
DIM SHARED kingBack(351)

DECLARE FUNCTION decodeKey$ (key$)
DECLARE FUNCTION update (key$)
DECLARE FUNCTION isValidAction (key$)
DECLARE FUNCTION updateBoard (key$)
DECLARE FUNCTION toggleBorder ()
DECLARE FUNCTION isRed (row, col)
DECLARE FUNCTION winner ()
DECLARE FUNCTION boardAttribute ()
DECLARE FUNCTION changePhantomValue (change)
DECLARE FUNCTION posLastPhantom (coordinateType)
DECLARE FUNCTION canMove ()
DECLARE FUNCTION spaceSurroundingChecker (whichCase)
DECLARE FUNCTION isLastPhantom (thisSpace)
DECLARE FUNCTION isSpaceSurroundingChecker (row, col)
DECLARE FUNCTION caseOfSpaceSurroundingChecker (row, col)
DECLARE FUNCTION setPositionToSurroundingChecker (whichCase)
DECLARE FUNCTION traceCase (key$)
DECLARE SUB setPosition (row, col)
DECLARE SUB trace (key$)
DECLARE SUB delete (typeToDelete)
DECLARE SUB rotateBoard ()
DECLARE SUB setFirstAvailablePosition ()
DECLARE SUB togglePlayer ()
DECLARE SUB displayMSG (text$, textColor, border)
DECLARE SUB init ()
DECLARE SUB drawBoard ()
DECLARE SUB drawPositionBorder ()
DECLARE SUB changeBoard (attribute, value)

SCREEN 12, , 0, 0
init
WHILE (keyPress$ <> "QUIT") AND (victory = 0)
  keyPress$ = decodeKey$(INKEY$)
  IF (isValidAction(keyPress$)) THEN
    victory = update(keyPress$)
    drawBoard
  END IF
  drawPositionBorder
WEND
IF victory > 0 THEN
  displayMSG p1$ + " wins!", pOneColor, pOneColor
ELSEIF victory < 0 THEN
  displayMSG p2$ + " wins!", pTwoColor, pTwoColor
ELSE
  displayMSG "Tie!", white, black
END IF

FUNCTION boardAttribute
  boardAttribute = board(posRow, posCol)
END FUNCTION

FUNCTION canMove
  canMove = FALSE
  IF spaceSurroundingChecker(1) THEN canMove = TRUE
  IF spaceSurroundingChecker(2) THEN canMove = TRUE
  IF spaceSurroundingChecker(3) THEN canMove = TRUE
  IF spaceSurroundingChecker(4) THEN canMove = TRUE
END FUNCTION

SUB changeBoard (attribute, value)
  IF NOT isRed(posRow, posCol) THEN
    displayMSG "BUG!  (In sub changeBoard)", yellow, black
    END
  END IF
  SELECT CASE attribute
  CASE NEWATTRIBUTE
    board(posRow, posCol) = value
  CASE ADDATTRIBUTE
    board(posRow, posCol) = boardAttribute OR value
  CASE REMOVEATTRIBUTE
    board(posRow, posCol) = boardAttribute AND NOT value
  END SELECT
END SUB

FUNCTION changePhantomValue (change) STATIC
  IF (newPhantomValue >= 0) AND (newPhantomValue <= MAXPIECES) THEN
    SELECT CASE change
    CASE IS < 0
      changePhantomValue = 2 ^ (newPhantomValue + 2)
      newPhantomValue = newPhantomValue - 1
      EXIT FUNCTION
    CASE 0
      changePhantomValue = 2 ^ (newPhantomValue + 2)
    CASE IS > 0
      newPhantomValue = newPhantomValue + 1
      changePhantomValue = 2 ^ (newPhantomValue + 2)
    END SELECT
  ELSE
    displayMSG "BUG!  (In function changePhantomValue)", yellow, black
    END
  END IF
 
  IF newPhantomValue = 0 THEN changePhantomValue = 0
END FUNCTION

FUNCTION decodeKey$ (key$)
  SELECT CASE UCASE$(key$)
  CASE "Q"
    decodeKey$ = "QUIT"
  CASE CHR$(0) + CHR$(72)
    decodeKey$ = "UP"
  CASE CHR$(0) + CHR$(80)
    decodeKey$ = "DOWN"
  CASE CHR$(0) + CHR$(75)
    decodeKey$ = "LEFT"
  CASE CHR$(0) + CHR$(77)
    decodeKey$ = "RIGHT"
  CASE CHR$(13)
    decodeKey$ = "ENTER"
  CASE CHR$(8)
    decodeKey$ = "BACKSPACE"
  CASE " "
    decodeKey$ = "SPACE BAR"
  CASE "E"
    decodeKey$ = "CHEAT ON"
  CASE "D"
    decodeKey$ = "CHEAT OFF"
  CASE ELSE
    decodeKey$ = ""
  END SELECT
END FUNCTION

SUB delete (typeToDelete)
  FOR row = 1 TO MAXROWS
    FOR col = 1 TO MAXCOLS
      IF typeToDelete AND (board(row, col) AND NOT NEGMAXINT) THEN
        setPosition row, col
        changeBoard NEWATTRIBUTE, EMPTEY
      END IF
    NEXT col
  NEXT row
  WHILE changePhantomValue(-1) > 8: WEND
END SUB

SUB displayMSG (text$, textColor, border)
continueButton$ = "Press Enter to Continue"
longer = LEN(text$)
IF LEN(continueButton$) > longer THEN longer = LEN(continueButton$)
LINE (300 - 4 * longer, 205)-(320 + 4 * longer, 240), black, BF
LINE (300 - 4 * longer, 205)-(320 + 4 * longer, 240), border, B
COLOR textColor
LOCATE 14, 40 - LEN(text$) / 2
PRINT text$
LOCATE 15, 40 - LEN(continueButton$) / 2
PRINT continueButton$
WHILE INPUT$(1) <> CHR$(13): WEND
LINE (300 - 4 * longer, 205)-(320 + 4 * longer, 240), black, BF
END SUB

SUB drawBoard
  CONST radius = 15
  CONST deleteColor = yellow
  CONST phantomColor = cyan
 
  FOR i = 0 TO MAXROWS
    LINE (0, INT(i * y!))-(xSize - 1, INT(i * y!)), brown
  NEXT i
  FOR i = 0 TO MAXCOLS
    LINE (INT(i * x!), 0)-(INT(i * x!), ySize - 1), brown
  NEXT i
  FOR row = 0 TO MAXROWS - 1
    FOR col = 0 TO MAXCOLS - 1
      IF isRed(row + 1, col + 1) THEN
        LINE (INT(col * x! + 1), INT(row * y! + 1))-(INT((col + 1) * x! - 1), INT((row + 1) * y! - 1)), red, BF
        IF (board(row + 1, col + 1) AND KING) = 0 THEN
          IF board(row + 1, col + 1) < 0 THEN
            CIRCLE (INT(col * x! + xSize / 16), INT(row * y! + ySize / 16)), radius, pOneColor
            PAINT (INT(col * x! + xSize / 16), INT(row * y! + ySize / 16)), pOneColor, pOneColor
          ELSEIF board(row + 1, col + 1) > 0 THEN
            CIRCLE (INT(col * x! + xSize / 16), INT(row * y! + ySize / 16)), radius, pTwoColor
            PAINT (INT(col * x! + xSize / 16), INT(row * y! + ySize / 16)), pTwoColor, pTwoColor
          END IF
        ELSEIF board(row + 1, col + 1) AND KING THEN
          IF ((board(row + 1, col + 1) > 0) AND (player = PLAYER1)) OR ((board(row + 1, col + 1) < 0) AND (player = PLAYER2)) THEN
            PUT (INT(col * x! + xSize / 16 - 15), INT(row * y! + ySize / 16 - 21)), kingFace, PSET
          ELSE
            PUT (INT(col * x! + xSize / 16 - 16), INT(row * y! + ySize / 16 - 16)), kingBack, PSET
          END IF
        END IF
        IF board(row + 1, col + 1) AND MARKEDFORDELETE THEN
          LINE (INT(col * x! + 1), INT(row * y! + 1))-(INT((col + 1) * x! - 1), INT((row + 1) * y! - 1)), deleteColor
          LINE (INT((col + 1) * x! - 1), INT(row * y! + 1))-(INT(col * x! + 1), INT((row + 1) * y! - 1)), deleteColor
        ELSEIF board(row + 1, col + 1) AND ALLPHANTOMS THEN
          LINE (INT(col * x!), INT(row * y!))-(INT((col + 1) * x!), INT((row + 1) * y!)), phantomColor, B
        END IF
      END IF
    NEXT col
  NEXT row
  drawPositionBorder
 
  IF cheat THEN
    tempRow = posRow: tempCol = posCol
    FOR i = 1 TO 4
      IF (changePhantomValue(0) AND ABS(posRow - posLastPhantom(ROWCOORDINATE)) = 2) OR (changePhantomValue(0) = 0) THEN
        IF setPositionToSurroundingChecker(i) THEN
          LINE (INT((posCol - 1) * x!), INT((posRow - 1) * y!))-(INT(posCol * x!), INT(posRow * y!)), highIntensityWhite, B
          setPosition tempRow, tempCol
        END IF
      END IF
    NEXT i
    setPosition tempRow, tempCol
  END IF
END SUB

SUB drawPositionBorder
  theTime! = TIMER
  SELECT CASE theTime! - INT(theTime!)
  CASE IS <= .25
    LINE (INT((posCol - 1) * x!), INT((posRow - 1) * y!))-(INT(posCol * x!), INT(posRow * y!)), posBorderColor, B
    EXIT SUB
  CASE IS <= .5
    LINE (INT((posCol - 1) * x!), INT((posRow - 1) * y!))-(INT(posCol * x!), INT(posRow * y!)), black, B
    EXIT SUB
  CASE IS <= .75
    LINE (INT((posCol - 1) * x!), INT((posRow - 1) * y!))-(INT(posCol * x!), INT(posRow * y!)), posBorderColor, B
    EXIT SUB
  CASE ELSE
    LINE (INT((posCol - 1) * x!), INT((posRow - 1) * y!))-(INT(posCol * x!), INT(posRow * y!)), black, B
  END SELECT
END SUB

SUB init
  player = PLAYER1
  cheat = FALSE
  FOR col = 1 TO MAXCOLS
    FOR row = 1 TO MAXROWS
      IF isRed(row, col) THEN
        setPosition row, col
        IF row < 4 THEN changeBoard NEWATTRIBUTE, NORMALPIECE OR NEGMAXINT
        IF row > 5 THEN changeBoard NEWATTRIBUTE, NORMALPIECE
        IF (row = 4) OR (row = 5) THEN changeBoard NEWATTRIBUTE, EMPTEY
      END IF
    NEXT row
  NEXT col
  
  PAINT (0, 0), red
  CIRCLE (100, 100), 15, green
  PAINT (100, 100), green, green
  CIRCLE (100, 87), 15, magenta
  PAINT (100, 87), magenta, magenta
  LINE (100, 100)-(100, 110), magenta
  LINE (85, 85)-(85, 100), magenta
  LINE (115, 85)-(115, 100), magenta
  CIRCLE (93, 105), 3, red, , , .8
  CIRCLE (107, 105), 3, red, , , .8
  PAINT (93, 105), red, red
  PAINT (107, 105), red, red
  CIRCLE (100, 112), 6, blue, , , .15
  LINE (100, 114)-(100, 115), magenta
  GET (85, 72)-(115, 115), kingFace

  CIRCLE (100, 190), 15, magenta
  PAINT (100, 180), magenta, magenta
  CIRCLE (100, 194), 17, green, , , .8
  PAINT (100, 194), green, green
  LINE (85, 185)-(85, 200), magenta
  LINE (115, 185)-(115, 200), magenta
  LINE (85, 200)-(115, 200), magenta
  PAINT (100, 195), magenta, magenta
  GET (83, 175)-(117, 209), kingBack
  CLS

  setFirstAvailablePosition
  displayMSG p1$ + "'s Turn", pOneColor, pOneColor
  drawBoard
END SUB

FUNCTION isLastPhantom (thisSpace)
  IF changePhantomValue(0) <= (thisSpace AND ALLPHANTOMS) THEN
    isLastPhantom = TRUE
  ELSE
    isLastPhantom = FALSE
  END IF
END FUNCTION

FUNCTION isRed (row, col)
  isRed = FALSE
  IF (row > 0) AND (row <= MAXROWS) THEN
    IF (col > 0) AND (col <= MAXCOLS) THEN
      IF (row + col) MOD 2 = 0 THEN isRed = TRUE
    END IF
  END IF
END FUNCTION

FUNCTION isSpaceSurroundingChecker (row, col)
  IF changePhantomValue(0) = 0 THEN EXIT FUNCTION
  phantomRow = posLastPhantom(ROWCOORDINATE)
  phantomCol = posLastPhantom(COLCOORDINATE)
  IF (ABS(row - phantomRow) > 2) OR (ABS(col - phantomCol) > 2) THEN EXIT FUNCTION
  IF (row = phantomRow) OR (col = phantomCol) THEN EXIT FUNCTION
 
  FOR i = 1 TO 4
    whichCase = spaceSurroundingChecker(i)
    isSpaceSurroundingChecker = i
    IF whichCase THEN
      SELECT CASE i
      CASE 1
        IF (phantomRow - whichCase = row) AND (phantomCol - whichCase = col) THEN EXIT FUNCTION
      CASE 2
        IF (phantomRow - whichCase = row) AND (phantomCol + whichCase = col) THEN EXIT FUNCTION
      CASE 3
        IF (phantomRow + whichCase = row) AND (phantomCol - whichCase = col) THEN EXIT FUNCTION
      CASE 4
        IF (phantomRow + whichCase = row) AND (phantomCol + whichCase = col) THEN EXIT FUNCTION
      END SELECT
    END IF
  NEXT i
  isSpaceSurroundingChecker = 0
END FUNCTION

FUNCTION isValidAction (key$)
SELECT CASE key$
CASE "QUIT"
  isValidAction = TRUE
CASE "UP"
  isValidAction = TRUE
CASE "DOWN"
  isValidAction = TRUE
CASE "LEFT"
  isValidAction = TRUE
CASE "RIGHT"
  isValidAction = TRUE
CASE "ENTER"
  isValidAction = TRUE
CASE "BACKSPACE"
  isValidAction = TRUE
CASE "SPACE BAR"
  isValidAction = TRUE
CASE "CHEAT ON"
  isValidAction = TRUE
CASE "CHEAT OFF"
  isValidAction = TRUE
CASE ELSE
   isValidAction = FALSE
END SELECT
END FUNCTION

FUNCTION posLastPhantom (coordinateType)
  FOR row = 1 TO MAXROWS
    FOR col = 1 TO MAXCOLS
      IF (board(row, col) AND ALLPHANTOMS) <> 0 THEN
        IF isLastPhantom(board(row, col)) THEN
          IF coordinateType = ROWCOORDINATE THEN
            posLastPhantom = row
          ELSEIF coordinateType = COLCOORDINATE THEN
            posLastPhantom = col
          END IF
          EXIT FUNCTION
        END IF
      END IF
    NEXT col
  NEXT row
END FUNCTION

SUB rotateBoard
  FOR col = 1 TO MAXCOLS
    FOR row = 1 TO MAXROWS / 2
      IF isRed(row, col) THEN
        temp = board(MAXROWS + 1 - row, MAXCOLS + 1 - col)
        setPosition MAXROWS + 1 - row, MAXCOLS + 1 - col
        changeBoard NEWATTRIBUTE, board(row, col)
        setPosition row, col
        changeBoard NEWATTRIBUTE, temp
      END IF
    NEXT row
  NEXT col
END SUB

SUB setFirstAvailablePosition
  IF changePhantomValue(0) THEN
    setPosition posLastPhantom(ROWCOORDINATE), posLastPhantom(COLCOORDINATE)
    IF NOT canMove THEN
      displayMSG "BUG!  (In sub setFirstAvailablePosition)", yellow, yellow
      END
    END IF
    FOR i = 1 TO 4
      IF setPositionToSurroundingChecker(i) THEN EXIT SUB
    NEXT i
  ELSE
    FOR row = 1 TO MAXROWS
      FOR col = 1 TO MAXCOLS
        IF (board(row, col) AND (NORMALPIECE OR NEGMAXINT)) * player > 0 THEN
          setPosition row, col
          EXIT SUB
        END IF
      NEXT col
    NEXT row
  END IF
END SUB

SUB setPosition (row, col)
  IF isRed(row, col) THEN
    posRow = row
    posCol = col
  ELSE
    displayMSG "Bug!  (In sub setPosition)", yellow, yellow
    END
  END IF
END SUB

FUNCTION setPositionToSurroundingChecker (whichCase)
  setPositionToSurroundingChecker = FALSE
  change = spaceSurroundingChecker(whichCase)
             
  IF change THEN
    SELECT CASE whichCase
    CASE 1
      setPosition posRow - change, posCol - change
    CASE 2
      setPosition posRow - change, posCol + change
    CASE 3
      setPosition posRow + change, posCol - change
    CASE 4
      setPosition posRow + change, posCol + change
    END SELECT
    setPositionToSurroundingChecker = TRUE
    EXIT FUNCTION
  END IF
END FUNCTION

FUNCTION spaceSurroundingChecker (whichCase)
  spaceSurroundingChecker = 0
       
  dx = 0: dy = 0
  SELECT CASE whichCase
  CASE 1: dx = -1: dy = -1
  CASE 2: dx = 1: dy = -1
  CASE 3: dx = -1: dy = 1
  CASE 4: dx = 1: dy = 1
  END SELECT
  IF isRed(posRow + dy, posCol + dx) THEN
    IF board(posRow + dy, posCol + dx) = EMPTEY THEN
      spaceSurroundingChecker = 1
      IF (changePhantomValue(0) = 8) AND (ABS(posLastPhantom(ROWCOORDINATE) - posRow) = 2) THEN spaceSurroundingChecker = 0
      IF changePhantomValue(0) > 8 THEN
        IF ABS(posLastPhantom(ROWCOORDINATE) - posRow) = 2 THEN spaceSurroundingChecker = 0
        IF posLastPhantom(ROWCOORDINATE) = posRow THEN spaceSurroundingChecker = 0
      END IF
    END IF
  END IF
  IF isRed(posRow + 2 * dy, posCol + 2 * dx) THEN
    IF (board(posRow + dy, posCol + dx) AND MARKEDFORDELETE) = 0 THEN
      IF ((board(posRow + dy, posCol + dx) > 0) AND (player = PLAYER2)) OR ((board(posRow + dy, posCol + dx) < 0) AND (player = PLAYER1)) THEN
        IF board(posRow + 2 * dy, posCol + 2 * dx) = EMPTEY THEN spaceSurroundingChecker = 2
        IF (board(posRow + 2 * dy, posCol + 2 * dx) AND (ALLPHANTOMS OR MARKEDFORDELETE)) <> EMPTEY THEN
          IF NOT isLastPhantom(board(posRow + 2 * dy, posCol + 2 * dx)) THEN spaceSurroundingChecker = 2
        END IF
      END IF
    END IF
  END IF
  IF whichCase > 2 THEN
    IF changePhantomValue(0) THEN
      IF (board(posLastPhantom(ROWCOORDINATE), posLastPhantom(COLCOORDINATE)) AND KING) = 0 THEN spaceSurroundingChecker = 0
    ELSEIF (boardAttribute AND KING) = 0 THEN
      spaceSurroundingChecker = 0
    END IF
  END IF
END FUNCTION

FUNCTION toggleBorder STATIC
  toggleBorder = NOT toggleBorder
END FUNCTION

SUB togglePlayer
  player = -player
  rotateBoard
END SUB

SUB trace (key$)
  thisRow = posRow
  thisCol = posCol
  col = thisCol
  row = thisRow
  IF key$ = "RIGHT" OR key$ = "LEFT" THEN
    col = col + 2 * traceCase(key$)
  ELSE
    row = row + 2 * traceCase(key$)
  END IF
   
  WHILE (row <> thisRow) OR (col <> thisCol)
    IF (key$ = "LEFT") AND ((row = 1) AND (col < 1)) THEN
      row = MAXROWS: col = MAXCOLS
    ELSEIF (key$ = "UP") AND ((row < 1) AND (col = 1)) THEN
      row = MAXROWS: col = MAXCOLS
    ELSEIF (key$ = "RIGHT") AND ((row = MAXROWS) AND (col > MAXROWS)) THEN
      row = 1: col = 1
    ELSEIF (key$ = "DOWN") AND ((row > MAXROWS) AND (col = MAXCOLS)) THEN
      row = 1: col = 1
    ELSE
      IF row < 1 THEN row = MAXROWS: col = col - 1
      IF row > MAXROWS THEN row = 1: col = col + 1
      IF col < 1 THEN col = MAXCOLS: row = row - 1
      IF col > MAXCOLS THEN col = 1: row = row + 1
    END IF
    IF isRed(row, col) AND changePhantomValue(0) THEN
      setPosition posLastPhantom(ROWCOORDINATE), posLastPhantom(COLCOORDINATE)
      whichCase = isSpaceSurroundingChecker(row, col)
        IF whichCase THEN
          IF NOT setPositionToSurroundingChecker(whichCase) THEN
            displayMSG "BUG!  (In sub trace)", yellow, yellow
          ELSE
            EXIT SUB
          END IF
        END IF
        setPosition thisRow, thisCol
    ELSEIF isRed(row, col) THEN
      IF ((board(row, col) > 0) AND (player = PLAYER1)) OR ((board(row, col) < 0) AND (player = PLAYER2)) THEN
        setPosition row, col
        EXIT SUB
      END IF
    END IF
    IF key$ = "RIGHT" OR key$ = "LEFT" THEN
      col = col + traceCase(key$)
    ELSE
      row = row + traceCase(key$)
    END IF
  WEND
END SUB

FUNCTION traceCase (key$)
  SELECT CASE key$
  CASE "RIGHT", "DOWN"
    traceCase = 1
  CASE "LEFT", "UP"
    traceCase = -1
  CASE ELSE
    displayMSG "Bug!  (In function traceCase)", yellow, yellow
    END
  END SELECT
END FUNCTION

FUNCTION update (key$)
  SELECT CASE key$
  CASE "QUIT"
  CASE "UP", "DOWN", "LEFT", "RIGHT"
    trace (key$)
  CASE "ENTER", "BACKSPACE", "SPACE BAR"
    IF (updateBoard(key$)) THEN
      IF posRow = 1 THEN
        IF (boardAttribute > 0) AND (player = PLAYER1) THEN changeBoard ADDATTRIBUTE, KING
        IF (boardAttribute < 0) AND (player = PLAYER2) THEN changeBoard ADDATTRIBUTE, KING
      END IF
      togglePlayer
      delete (MARKEDFORDELETE OR ALLPHANTOMS)
      theWinner = winner
      IF theWinner = 0 THEN setFirstAvailablePosition
    END IF
    IF (theWinner = 0) AND changePhantomValue(0) THEN setFirstAvailablePosition
  CASE "CHEAT ON"
    cheat = TRUE
  CASE "CHEAT OFF"
    cheat = FALSE
  CASE ELSE
    displayMSG "BUG!  (In function update)", yellow, yellow
    END
  END SELECT
  update = theWinner
END FUNCTION

FUNCTION updateBoard (key$)
  updateBoard = FALSE
  IF key$ = "ENTER" THEN
    IF changePhantomValue(0) AND (ABS(posRow - posLastPhantom(ROWCOORDINATE)) = 1) THEN
      changeBoard NEWATTRIBUTE, board(posLastPhantom(ROWCOORDINATE), posLastPhantom(COLCOORDINATE)) AND NOT ALLPHANTOMS
      updateBoard = TRUE
    ELSEIF canMove THEN
      IF changePhantomValue(0) THEN
        tempRow = posRow: tempCol = posCol
        setPosition ((posLastPhantom(ROWCOORDINATE) + posRow) / 2), ((posLastPhantom(COLCOORDINATE) + posCol) / 2)
        changeBoard ADDATTRIBUTE, MARKEDFORDELETE
        setPosition tempRow, tempCol
        changeBoard ADDATTRIBUTE, (board(posLastPhantom(ROWCOORDINATE), posLastPhantom(COLCOORDINATE)) AND NOT ALLPHANTOMS) OR changePhantomValue(1)
      ELSE
        changeBoard ADDATTRIBUTE, boardAttribute OR changePhantomValue(1)
      END IF
    ELSEIF changePhantomValue(0) THEN
      tempRow = posRow: tempCol = posCol
      setPosition ((posLastPhantom(ROWCOORDINATE) + posRow) / 2), ((posLastPhantom(COLCOORDINATE) + posCol) / 2)
      changeBoard ADDATTRIBUTE, MARKEDFORDELETE
      setPosition tempRow, tempCol
      changeBoard NEWATTRIBUTE, board(posLastPhantom(ROWCOORDINATE), posLastPhantom(COLCOORDINATE)) AND NOT ALLPHANTOMS
      updateBoard = TRUE
    ELSE
      BEEP
    END IF
  ELSEIF key$ = "SPACE BAR" THEN
    IF changePhantomValue(0) THEN
      changeBoard NEWATTRIBUTE, board(posLastPhantom(ROWCOORDINATE), posLastPhantom(COLCOORDINATE)) AND NOT ALLPHANTOMS
      IF ABS(posLastPhantom(ROWCOORDINATE) - posRow) > 1 THEN
        tempRow = posRow: tempCol = posCol
        setPosition ((posLastPhantom(ROWCOORDINATE) + posRow) / 2), ((posLastPhantom(COLCOORDINATE) + posCol) / 2)
        changeBoard ADDATTRIBUTE, MARKEDFORDELETE
        setPosition tempRow, tempCol
      END IF
      updateBoard = TRUE
    END IF
  ELSEIF (key$ = "BACKSPACE") AND changePhantomValue(0) THEN
    setPosition posLastPhantom(ROWCOORDINATE), posLastPhantom(COLCOORDINATE)
    changeBoard REMOVEATTRIBUTE, changePhantomValue(-1)
    IF changePhantomValue(0) THEN
      tempRow = posRow: tempCol = posCol
      setPosition ((posLastPhantom(ROWCOORDINATE) + posRow) / 2), ((posLastPhantom(COLCOORDINATE) + posCol) / 2)
      changeBoard REMOVEATTRIBUTE, MARKEDFORDELETE
      setPosition tempRow, tempCol
      IF (boardAttribute AND ALLPHANTOMS) = 0 THEN changeBoard NEWATTRIBUTE, EMPTEY
    END IF
  END IF
END FUNCTION

FUNCTION winner
  pOne = PLAYER2
  pTwo = PLAYER1
  FOR row = 1 TO MAXROWS
    FOR col = 1 TO MAXCOLS
      IF board(row, col) > 0 THEN pOne = 0
      IF board(row, col) < 0 THEN pTwo = 0
    NEXT col
  NEXT row
  winner = pOne OR pTwo
END FUNCTION

