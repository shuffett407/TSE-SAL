/*************************************************************************
  FilNam2C    Copy the current file's path and name to the clipboard.
  Author:     Christopher Shuffett
  Date:       Apr  4, 2023  (CS) initial version
*************************************************************************/
proc FilNam2C()
    string file_name[255] = CurrFilename()

    PushBlock()

    if CreateTempBuffer()
        MarkChar()
        InsertText(file_name)
        CopyToWinClip()
        AbandonFile()
    endif

    PopBlock()
end

<Shift F11>             FilNam2C()
