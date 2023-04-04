/*************************************************************************
  mAnother    Open a new file and add contents of the current file.

  Author:     Christopher Shuffett

  Date:       Apr  4, 2023  (CS) initial version

  Overview:

  Create a new file by cloning the current file.

*************************************************************************/

proc mAnother()
    integer msglevel
           ,currln = CurrLine()
           ,currps = CurrPos()
           ,currX = WhereX()
           ,currY = WhereY()
           ,fnOK
    string  fn[255] = CurrFilename()

    BufferVideo()
    PushBlock()
    PushPosition()
    UnMarkBlock()
    MarkLine(1, NumLines())
    fnOK = Ask("New Filename:", fn)

    while fnOK and FileExists(fn)
         warn("Filename already exists")
         fnOK = Ask("New Filename:", fn)
    endwhile

    if fnOK
        msglevel = Set(MsgLevel, _WARNINGS_ONLY_) //Turn off new file message

        if EditThisFile(fn)
            CopyBlock()
            GotoLine(currln)
            UpdateDisplay()

            while currY <> WhereY()
                Scrollup()
                UpdateDisplay()
            endwhile

            GotoPos(currps)
            UpdateDisplay()

            while currX <> WhereX()
                ScrollRight()
                UpdateDisplay()
            endwhile
        endif

        Set(MsgLevel, msglevel)
    endif

    UnMarkBlock()
    PopPosition()
    PopBlock()

    if fnOK
        EditThisFile(fn)
    endif

    UnBufferVideo()
end

<Alt Ins>               mAnother()
