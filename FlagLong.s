/*
 * This macro checks the lengths for each of the lines in the current window
 * and displays a highlighted character in the corner of the window to indicate
 * that there is text not shown beyond the right edge of the window.
 */

integer
proc isOffScreen()
    integer result = (FALSE)
          , start = CurrLine() - CurrRow() + 1
          , i

    PushPosition()
    GotoColumn(CurrCol() + Query(WindowCols) - CurrCol() + CurrXoffset())

    for i = 0 to Query(WindowRows) - 1
        GotoLine(start + i)

        if CurrPos() < CurrLineLen()
            result = (TRUE)
            break
        endif
    endfor

    PopPosition()
    return(result)
end

proc mSetVideoPosition(integer col, integer row)
    if NumWindows() == 1
        VGotoXY(col + 1, row)
    else
        VGotoXY(col - 1, row + 1)
    endif
end

proc mFlagLongLines()
    integer flag_pos, flag_line

    UpdateDisplay()

    if NumWindows() == 1
        flag_pos  = Query(WindowCols) + GetLineNumberLength() - iif(Query(Displayboxed),1,0)
        flag_line = 1
    else
        flag_pos  = Query(WindowCols) + GetLineNumberLength() + 1
        flag_line = 0
    endif

    if isOffScreen()
        mSetVideoPosition(flag_pos, flag_line)

//Display character to indicate that text is present past the right edge of the window.
        WriteLine(">")

        mSetVideoPosition(flag_pos, flag_line)

//Sets the character's foreground and bacground color
        PutAttr(224, 1)
    endif
end

proc WhenLoaded()
//  When CopyBlock expands the line, macro fires ok
//  When Undo shrinks the line, macro does not fire
    Hook(_AFTER_UPDATE_DISPLAY_, mFlagLongLines)
end
