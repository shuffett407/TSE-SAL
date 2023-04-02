/*************************************************************************
  TSEvers     When saving file changes, backup the current contents
              before replacing it.

  Author:     Christopher Shuffett

  Date:       Mar  31, 2023  (CS) initial version

  Overview:

  This macro creates a new subfolder underneath the TSEvers folder where
  backups are saved.

  The subfolder naming convention is TSEvers\verYYMMDDHHMMSS.

  If the TSEvers folder does not exist, versioning is disabled!!!

  For Linux, replace the backslashes with forward slashes.

*************************************************************************/

proc TSEvers()
integer file_attr, month, day, year, dow, hrs, minutes, sec, hun
string fullname[255], file_path[255], vers_folder[255]
    fullname = CurrFilename()
    file_attr = FileExists(fullname)

    if not file_attr
        return() // Stop if file has not been previously saved.
    else
        if file_attr & (_READONLY_ | _HIDDEN_ | _SYSTEM_)
            return() // File cannot be saved.
        endif
    endif

    file_path = SplitPath(fullname, _PATH_)
    file_attr = FileExists(file_path + "\TSEvers")

    if not (file_attr & _DIRECTORY_)
        return() // Stop if version folder is not present.
    endif

    GetDate(month, day, year, dow)
    year = year - 2000
    GetTime(hrs, minutes, sec, hun)
    vers_folder = file_path + "\TSEvers\"
        + Format("ver", year : 2 : "0", month : 2 : "0", day : 2 : "0", hrs : 2 : "0", minutes : 2 : "0", sec : 2 : "0")

    if not (FileExists(vers_folder) & _DIRECTORY_)
        Dos ("mkdir " + QuotePath(vers_folder), _DONT_CLEAR_ | _DONT_PROMPT_)
    endif

    CopyFile(fullname, vers_folder + "\" + SplitPath(fullname, _NAME_) + SplitPath(fullname, _EXT_ ), TRUE)
end

proc WhenLoaded()
    Hook(_ON_FILE_SAVE_, TSEvers)
end