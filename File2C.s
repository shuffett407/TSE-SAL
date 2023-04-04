/*************************************************************************
  File2C      Copy the contents of the current file to the clipboard.

  Author:     Christopher Shuffett

  Date:       Apr  4, 2023  (CS) initial version

*************************************************************************/
proc File2C()
    PushBlock()
    UnMarkBlock()
    MarkLine(1, NumLines())
    CopyToWinClip()
    UnMarkBlock()
    PopBlock()
end

<Alt F11>               File2C()
