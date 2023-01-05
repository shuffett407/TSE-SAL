proc main()
    string delim[1] = ""
    integer olinenum = CurrLine()
    integer tlinepos = CurrPos()
    integer tlinenum = 0
    integer nlinenum = 0
    integer blksaved
    integer tstop = false

    if isBlockMarked()
    and not isBlockInCurrFile()
        PushBlock()
        blksaved = true
    endif

    BegFile()
    delim = GetText(106, 1)
    UnMarkBlock()
    lFind(delim, "l")

    repeat
        if tlinenum <> olinenum
            tlinenum = tlinenum + 1
            nlinenum = nlinenum + 1
        else
            if not tstop
                nlinenum = nlinenum + 1
            endif
        endif

        UnMarkBlock()
        MarkLine()

        if lRepeatFind()
            Right()

            if CurrChar() <> _AT_EOL_
                SplitLine()
            endif

            if tlinenum == olinenum
                if tlinepos < CurrPos()
                    tstop = true
                else
                    if not tstop
                        tlinepos = tlinepos - currlinelen()
                    endif
                endif
             endif

            BegLine()

            if tlinenum <> olinenum
                tlinenum = tlinenum - 1
            endif
        else
            EndLine()

            if tlinenum == olinenum
            and not tstop
                if tlinepos < CurrPos()
                    tstop = true
                endif
            endif

            BegLine()
            Down()
            UnMarkBlock()
            MarkLine()

            if lFind(delim, "gl")
                Right()
                SplitLine()

                if tlinenum + 1 == olinenum
                    if tlinepos < CurrPos()
                        Up()
                        tlinepos = tlinepos + CurrLineLen()
                        tlinenum = olinenum
                        tstop = true
                    else
                        tlinepos = tlinepos - CurrLineLen()
                        Up()
                    endif
                else
                    Up()
                endif

                EndLine()
                JoinLine()
                BegLine()
            endif
        endif
    until not Down()

    GotoLine(nlinenum)
    GotoPos(tlinepos)
    ScrollToCenter()
    UnMarkBlock()

    if blksaved
        PopBlock()
    endif
end