DataDef text_data
    "Given$a$text$file$of$many$lines,$where$fields$within$a$line$"
    "are$delineated$by$a$single$'dollar'$character,$write$a$program"
    "that$aligns$each$column$of$fields$by$ensuring$that$words$in$each$"
    "column$are$separated$by$at$least$one$space."
    "Further,$allow$for$each$word$in$a$column$to$be$either$left$"
    "justified,$right$justified,$or$center$justified$within$its$column."
end

proc mAlignCenter(var integer row_count, var integer col_width)
    integer i

    for i = 1 to row_count
        GotoLine(i)
        GotoPos(1)
        InserTtext(Format("" : (col_width - CurrLineLen()) shr 1), _INSERT_)
    endfor
end

proc mAlignRight(var integer row_count, var integer col_width)
    integer i

    for i = 1 to row_count
        GotoLine(i)
        GotoPos(1)
        InserTtext(Format("" : col_width - CurrLineLen()), _INSERT_)
    endfor
end

proc main()
    integer i, return_file, input_file, work_file, output_file, col_width, row_count, done_processing
    return_file = GetBufferId() // Current file or line should be empty
    work_file = CreateTempBuffer()
    output_file = CreateTempBuffer()
    input_file = CreateTempBuffer()
    InsertData(text_data)
    row_count = NumLines()

    repeat
        MarkAll()
        GotoBufferId(work_file)
        EmptyBuffer()
        CopyBlock()
        lReplace("\$.*$", "$", "gnx") // Removes text following first delimiter
        lReplace("^ ", "", "gnx")     // Removes leading spaces
        lReplace(" *\$$", "", "gnx")  // Removes trailing spaces
        col_width = LongestLineInBuffer()
        // Uncomment one of the following lines to change the alignment type. Default is left justified.
        //   mAlignCenter(row_count, col_width)
        //   mAlignRight(row_count, col_width)
        MarkColumn(1, 1, row_count, col_width + 1)
        GotoBufferId(output_file)
        MoveBlock()
        GotoColumn(CurrPos() + col_width + 1)
        GotoBufferId(input_file)
        done_processing = True

        for i = 1 to row_count
            GotoLine(i)

            if CurrChar(1) <> _AT_EOL_
                MarkLine(i, i)

                if lReplace("^.*\$", "", "xl1") // Remove text preceding next column
                    done_processing = False
                else
                    lReplace("^.*$", "", "xl1") // Remove text to end of line
                endif
            endif
        endfor
    until done_processing

    AbandonFile(input_file)
    AbandonFile(work_file)
    GotoBufferId(output_file)
    MarkAll()
    GotoBufferId(return_file)
    MoveBlock()
    UnMarkBlock()
    AbandonFile(output_file)
end
