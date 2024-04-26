/*************************************************************************
  mAnother    Open a new file and add contents of the current file.

  Author:     Christopher Shuffett

  Date:       Apr 25, 2024  (CS) initial version

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
           ,i
    string  fn[255] = CurrFilename()

    PushBlock()
    PushPosition()
    UnMarkBlock()
    MarkLine(1, NumLines())
    fnOK = Ask("New Filename:", fn)

    loop
         if fnOK
             if length(fn) == 0
                 fnOK = false
                 break
             else
                 for i = 1 to length(fn)
                     if fn[i] == '"'
                     or fn[i] == "'"
                     or fn[i] == " "
                         fnOK = false
                         break
                     endif
                 endfor
             endif
         endif

         if fnOK
             if FileExists(fn)
                 warn("Filename already exists")
                 fnOK = Ask("New Filename:", fn)

                 if not fnOK
                     break
                 endif
             else
                 break
             endif
         else
             warn("Invalid filename")
             fnOK = Ask("New Filename:", fn)

             if not fnOK
                 break
             endif
         endif
    endloop

    if fnOK
        msglevel = Set(MsgLevel, _WARNINGS_ONLY_) //Turn off new file message

        if EditFile(fn)
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
        EditFile(fn)
    endif
end

<Ctrl k><a>               mAnother()
