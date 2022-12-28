/*************************************************************************
  Pntshoot    Point-n-Shoot clicking.

  Author:     Christopher Shuffett

  Date:       Nov  27, 2022  (CS) initial version

  Overview:

  This macro inserts or replaces text with the text from a
  single line column block.

  For example, suppose tht you have a form letter and a
  list of names. To create a new letter, you want to mark
  the recipient's name and then replace the word recipient
  in the To heading with the marked text.

  The procedure is
    1) Duplicate the template.
    2) Open the name list and create a new column
       block by dragging with the left mouse button.
    3) Open the form and left click recipient.
       At this point the word will be highlighted
       and a target is displayed where you clicked.
       Click the target to replace recipient with
       the selected name.
    4) If the recipient name needs to be inserted
       again further down in the letter, repeat
       step 3.
    Note: If instead of having the word recipient
    there is an empty space, click where you
    want the name to start and the target will apear
    there.

  For the programmer, this is a handy macro for
  changing or adding a variable name.

  Here are the opperations that can be performed.
      Smart No Slide - Text to the right doesn't
                       slide to the left. It
                       will slide coluns to the
                       right to make room.
      Smart Slide    - Text to the right slides
                       to the left if smaller.
                       Columns to the right slide
                       to the right to make room.
      Insert         - Similar to Alt-K..Alt-K..Alt-C
      Overwrite      - Similar to Alt-K..Alt-K..Alt-Z

*************************************************************************/

constant pntshoot_smart_no_slide  = 1
        ,pntshoot_smart_slide     = 2
        ,pntshoot_insert          = 3
        ,pntshoot_overwrite       = 4

integer pntshoot        = true
       ,pntshoot_type   = pntshoot_smart_no_slide
       ,last_tick

/********************************************************
  Return TRUE if one or more seconds has elapsed since
  last call.  Also account for midnight roll over.
  However, if called just after midnight, may possibly
  return TRUE even though 1 second has not passed since
  the last call.
 ********************************************************/

integer proc OneSecondElapsed()
    integer ticks

    ticks = GetClockTicks()
    if ticks < last_tick or ticks - last_tick > 6
        last_tick = ticks
        return (TRUE)
    endif
    return (FALSE)
end

proc show_target()
    if pntshoot_type == pntshoot_smart_slide
    or pntshoot_type == pntshoot_smart_no_slide
        VGotoXY(WhereX(),WhereY())
        PutChar("@")
        PushBlock()
        MarkWord()

        if isBlockMarked()
            VGotoXY(Query(BlockBegCol) - CurrXoffset() + Query(WindowX1) - 1
                   ,WhereY())
            PutAttr(128 + Query(CursorAttr),
                    Query(BlockEndCol)
                  - Query(BlockBegCol)
                  + 1)
        endif

        PopBlock()
    else
        VGotoXY(WhereX(),WhereY())
        PutChar("@")
    endif
end

proc smart_paste_repl()
    integer a
           ,size_diff
           ,repl_len
           ,end_pos

    GotoBlockBegin()
    a         = Query(BlockEndCol) - Query(BlockBegCol) + 1
    end_pos   = Query(BlockEndCol) + 1
    PopBlock()
    repl_len  = Query(BlockEndCol) - Query(BlockBegCol) + 1
    size_diff = a - repl_len
    end_pos   = end_pos - size_diff
    CopyBlock()
    GotoPos(end_pos)

    while a > 0
        DelChar()
        a = a - 1
    endwhile

    if size_diff < 0               // new block is bigger than old word
    and pntshoot_type == pntshoot_smart_no_slide
        a = 0

        while end_pos <= CurrLineLen()
            if GetText(end_pos,2) == "  "
                GotoPos(end_pos)

                repeat
                    DelChar()
                    a = a + 1
                until (a == Abs(size_diff))
                   or (GetText(CurrPos(),2) <> "  ")

                break
            else
                end_pos = end_pos + 1
            endif
        endwhile
    else
        if size_diff > 0               // new block is smaller than old word
        and pntshoot_type == pntshoot_smart_no_slide
            while end_pos <= CurrLineLen()
                if GetText(end_pos,2) == "  "
                    GotoPos(end_pos)
                    InsertText(Format("":size_diff), _INSERT_)
                    break
                else
                    end_pos = end_pos + 1
                endif
            endwhile
        endif
    endif
end

proc smart_paste_in()
    integer a
           ,found_spaces

    PopBlock()
    CopyBlock()

    if pntshoot_type == pntshoot_smart_no_slide
        GotoBlockEnd()
        Right()
        a = 0
        found_spaces = false

        while (CurrPos() <= CurrLineLen())
          and ((not found_spaces)
           or  (a <
                (Query(BlockEndCol)
               - Query(BlockBegCol)
               + 1)))
            if GetText(CurrPos(),2) == "  "
                DelChar()
                a = a + 1
                found_spaces = true
            else
                if found_spaces
                    break
                else
                    Right()
                endif
            endif
        endwhile
    endif
end

proc shoot_target()
    if pntshoot_type == pntshoot_smart_slide
    or pntshoot_type == pntshoot_smart_no_slide
        PushBlock()
        MarkWord()

        if isBlockMarked()
            smart_paste_repl()
        else
            smart_paste_in()
        endif

        GotoMouseCursor()
    else
        if pntshoot_type == pntshoot_insert
            CopyBlock()
        else
            CopyBlock(_OVERWRITE_)
        endif
    endif
end

proc main()
    integer beg_col
           ,beg_row
           ,end_col
           ,end_row
           ,beg_csr_col
           ,beg_csr_row
           ,last_key
           ,IsrtCsrSiz
           ,OwrtCsrSiz
           ,line_marked

//  if not ProcessHotSpot()
//     MainMenu()
//  endif

    case MouseHotSpot()
     when _NONE_
        Message("I'm unable to access the MainMenu.")
     when _MOUSE_MARKING_
        beg_csr_col = CurrPos()
        beg_csr_row = CurrLine()

        if isBlockMarked()
        or Query(Marking)
            beg_col = Query(BlockBegCol)
            beg_row = Query(BlockBegLine)
            end_col = Query(BlockEndCol)
            end_row = Query(BlockEndLine)

            if isBlockMarked() == _LINE_
            and Query(BlockBegLine) == Query(BlockEndLine)
                if Query(Marking)
                    line_marked = false
                else
                    line_marked = true
                endif
            else
                line_marked = false
            endif

            MouseMarking(_COLUMN_)

            if isBlockMarked() == _NONINCLUSIVE_
            and Query(BlockBegLine) == Query(BlockEndLine)
            and (beg_col <> Query(BlockBegCol)
            or   beg_row <> Query(BlockBegLine)
            or   end_col <> Query(BlockEndCol)
            or   end_row <> Query(BlockEndLine))
                PushPosition()
                GotoBlockBegin()
                beg_col = CurrCol()
                GotoBlockEnd()
                Left()
                UnMarkBlock()
                MarkColumn()
                GotoColumn(beg_col)
                MarkColumn()
                PopPosition()
            endif

            if isBlockMarked() == _LINE_
                if Query(Marking)
                    if (beg_row <> Query(BlockBegLine)
                    or  end_row <> Query(BlockEndLine))
                        MarkLine()
                    endif
                else
                    if Query(BlockBegLine) == Query(BlockEndLine)
                    and not line_marked
                        UnMarkBlock()
                        MarkLine()
                    endif
                endif
            endif
        else
            MouseMarking(_COLUMN_)

            if isBlockMarked() == _NONINCLUSIVE_
                PushPosition()
                GotoBlockBegin()
                beg_col = CurrCol()
                GotoBlockEnd()
                Left()
                UnMarkBlock()
                MarkColumn()
                GotoColumn(beg_col)
                MarkColumn()
                PopPosition()
            endif

            if isBlockMarked() == _LINE_
                UnMarkBlock()
                MarkLine()
            endif
        endif

        if pntshoot
        and isBlockMarked() == _COLUMN_
        and Query(BlockBegLine) == Query(BlockEndLine)
        and (beg_csr_col <> CurrPos()
        or   beg_csr_row <> CurrLine())
        and not isCursorInBlock()
            beg_col = WhereX()
            beg_row = WhereY()
            last_tick = GetClockTicks()

            while not OneSecondElapsed()
                if KeyPressed()
                    goto end_pntshoot
                endif
            endwhile

            IsrtCsrSiz = Set(InsertCursorSize,8)
            OwrtCsrSiz = Set(OverwriteCursorSize,8)
            show_target()
            Set(InsertCursorSize,IsrtCsrSiz)
            Set(OverwriteCursorSize,OwrtCsrSiz)

            while not KeyPressed()
            endwhile

            last_key = GetKey()

            if (last_key  == <LeftBtn>
            or  last_key  == <RightBtn>)
            and beg_col == WhereX()
            and beg_row == WhereY()
            and beg_col == Query(MouseX)
            and beg_row == Query(MouseY)
                if last_key  == <LeftBtn>
                    shoot_target()
                else
                    Set(X1,Query(MouseX)-1)
                    Set(Y1,Query(MouseY)-1)
//                  mRightBtn()
                endif
            else
                UpdateDisplay(_CLINE_REFRESH_ | _REFRESH_THIS_ONLY_)
                PushKey(last_key)
            endif

end_pntshoot: last_tick = 0
        endif
     otherwise
        ProcessHotSpot()
    endcase
end

<LeftBtn>               main()