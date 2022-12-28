DataDef text_data
    "Given$a$text$file$of$many$lines,$where$fields$within$a$line$"
    "are$delineated$by$a$single$'dollar'$character,$write$a$program"
    "that$aligns$each$column$of$fields$by$ensuring$that$words$in$each$"
    "column$are$separated$by$at$least$one$space."
    "Further,$allow$for$each$word$in$a$column$to$be$either$left$"
    "justified,$right$justified,$or$center$justified$within$its$column."
end

proc main()
    integer i, return_file, input_file, work_file, output_file, output_col, row_count, done_processing

    return_file = GetBufferId() // Current file or line should be empty
    work_file = CreateTempBuffer()
    output_file = CreateTempBuffer()
    output_col = 1
    input_file = CreateTempBuffer()
    InsertData(text_data)
    row_count = NumLines()
    MarkAll()

    repeat
        GotoBufferId(work_file)
        EmptyBuffer()
        CopyBlock()
        lReplace("\$.*$","","gnx") // Remove text following first delimiter
        MarkColumn(1,1,row_count,LongestLineInBuffer() + 1)
        GotoBufferId(output_file)
        GotoColumn(output_col)
        MoveBlock()
        output_col = LongestLineInBuffer() + 2
        GotoBufferId(input_file)
        done_processing = True

        for i = 1 to row_count
            GotoLine(i)
            MarkLine(i,i)

            if lReplace("^.*\$","","xl1") // Remove text preceding next column
                done_processing = False
            else
                lReplace("^.*$","","xl1") // Remove text to end of line
            endif
        endfor

        if not done_processing
            MarkAll()
        endif
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