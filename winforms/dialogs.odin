// Created on 25-Nov-2023 11:06 PM

package winforms
import "core:fmt"
import "core:strings"

// Constants
    MAX_PATH :: 260
    MAX_ARR_SIZE :: 32768 + 256 * 100 + 1
    OFN_ALLOWMULTISELECT :: 0x200
    OFN_PATHMUSTEXIST :: 0x800
    OFN_FILEMUSTEXIST :: 0x1000
    OFN_FORCESHOWHIDDEN :: 0x10000000
    OFN_OVERWRITEPROMPT :: 0x2
    BIF_RETURNONLYFSDIRS :: 0x00000001
    BIF_NEWDIALOGSTYLE :: 0x00000040
    BIF_EDITBOX :: 0x00000010
    BIF_NONEWFOLDERBUTTON :: 0x00000200
    BIF_BROWSEINCLUDEFILES :: 0x00004000
    OFN_EXPLORER :: 0x00080000
    bf2 : i32 = 0
    bfalse2 := cast(BOOL)bf2
    dnc :: "\x00\x00"
    nc :: '\x00'
//

// Type Decl
    DialogType :: enum {File_Open, File_Save}

    DialogBase :: struct {
        kind : DialogType,
        title, initDir, selectedPath : string,
        fileStart, extStart : int,
        allowAllFiles: bool,
        filter : string
    }

    FileOpenDialog :: struct {
        using _base: DialogBase,
        multiSel, showHidden : bool,
        selectedFiles : [dynamic]string,

    }

    FileSaveDialog :: struct {
        using _base: DialogBase,
        defExt : string
    }

    FolderBrowserDialog :: struct {
        using _base: DialogBase,
        newFolBtn, showFiles : bool
    }

    OFNHOOKPROC :: distinct #type proc "std"(hwnd: HWND, msg: uint, wpm: WPARAM, lpm: LPARAM) -> UINT_PTR
    BROWSECBPROC :: distinct #type proc "std"(hwnd: HWND, msg: uint, lpm1: LPARAM, lpm2: LPARAM) -> i32

// End Type


file_open_dialog :: proc(titleStr: string = "Open file", initFolder: string = "", description: string = "", ext: string = "" ) -> FileOpenDialog
{
    this : FileOpenDialog
    this.title = titleStr
    this.initDir = initFolder
    this.kind = DialogType.File_Open
    dummy : string = description == "" ? "All Files" : description
    this.filter = ext == "" ? fmt.tprintf("%s\x00*.*\x00\x00", dummy) : fmt.tprintf("%s\x00*%s\x00\x00",dummy, ext)
    return this
}

file_save_dialog :: proc(titleStr: string = "Save As", initFolder: string = "") -> ^FileSaveDialog
{
    this := new(FileSaveDialog)
    this.title = titleStr
    this.initDir = initFolder
    this.kind = DialogType.File_Save
    return this
}

folder_browser_dialog :: proc(titleStr: string = "Save As", initFolder: string = "") -> ^FolderBrowserDialog
{
    this := new(FolderBrowserDialog)
    this.title = titleStr
    this.initDir = initFolder
    return this
}



@private extract_file_names :: proc(this: ^FileOpenDialog, buffer: []WCHAR, start: WORD)
{
    start_pos:= cast(int)start
    dir_path := utf16_to_utf8(buffer[0:(start_pos - 1)]) // First item in buffer is directory path.
    for i in start_pos..<MAX_ARR_SIZE {
        if buffer[i] == 0 {
            slice := buffer[start_pos:i]
            start_pos = i + 1
            append(&this.selectedFiles, fmt.tprintf("%s\\%s", dir_path, utf16_to_utf8(slice)))
            if buffer[start_pos] == 0 do break
        }
    }
}

@private open_dialog_helper :: proc(this: ^FileOpenDialog, hwnd: HWND = nil)-> bool
{

    if this.allowAllFiles {
        this.filter = fmt.tprintf("%sAll files\x00*.*\x00", this.filter)
    }

    // This is a hack. Windows will ignore the initial directory path if it...
    // contains a space. But if path ends with a '\' it will work. So here...
    // we are checking for white space and put the '\' at the end.
    if strings.contains(this.initDir, " ") && this.initDir[len(this.initDir) - 1] != '\\' {
        this.initDir = fmt.tprintf("%s\\", this.initDir)
    }

    buffer : [MAX_ARR_SIZE]WCHAR

    ofn : OPENFILENAMEW
    ofn.hwndOwner = hwnd
    ofn.lStructSize = size_of(ofn)
    ofn.lpstrFilter = to_wchar_ptr(this.filter)
    ofn.lpstrFile = &buffer[0]
    ofn.lpstrInitialDir = this.initDir == "" ? nil : to_wchar_ptr(this.initDir)
    ofn.lpstrTitle = to_wchar_ptr(this.title)
    ofn.nMaxFile = MAX_ARR_SIZE
    ofn.nMaxFileTitle = MAX_PATH
    ofn.lpstrDefExt = direct_cast(0, ^WCHAR)
    ofn.Flags = OFN_PATHMUSTEXIST | OFN_FILEMUSTEXIST
    if this.multiSel do ofn.Flags = ofn.Flags | OFN_ALLOWMULTISELECT | OFN_EXPLORER
    if this.showHidden do ofn.Flags = ofn.Flags | OFN_FORCESHOWHIDDEN
    ret := cast(int)GetOpenFileName(&ofn)
    // ptf("GetOpenFileName Errors : %d\n", GetLastError())
    if ret > 0 {
        if this.multiSel {
            extract_file_names(this, buffer[:], ofn.nFileOffset)
            return true
        } else {
            this.selectedPath = utf16_to_utf8(buffer[:])
            return true
        }
    }
    return false
}

@private save_dialog_helper :: proc(this: ^FileSaveDialog, hwnd: HWND) -> bool
{
    buffer : [MAX_PATH]WCHAR
    ofn : OPENFILENAMEW
    ofn.hwndOwner = hwnd
    ofn.lStructSize = size_of(ofn)
    ofn.lpstrFilter = to_wchar_ptr(this.filter)
    ofn.lpstrFile = &buffer[0]
    ofn.lpstrInitialDir = this.initDir == "" ? nil : to_wchar_ptr(this.initDir)
    ofn.lpstrTitle = to_wchar_ptr(this.title)
    ofn.nMaxFile = MAX_PATH
    ofn.nMaxFileTitle = MAX_PATH
    ofn.lpstrDefExt = direct_cast(0, ^WCHAR)
    ofn.Flags = OFN_PATHMUSTEXIST | OFN_OVERWRITEPROMPT
    ret := cast(int) GetSaveFileName(&ofn)
    if ret != 0 {
        this.fileStart = int(ofn.nFileOffset)
        this.extStart = int(ofn.nFileExtension)
        this.selectedPath = wstring_to_string(&buffer[0])
        return true
    }
    return false
}

@private folder_browser_helper :: proc(this: ^FolderBrowserDialog, hwnd: HWND = nil) -> bool
{
    buffer : [MAX_ARR_SIZE]WCHAR
    bi : BROWSEINFOW
    bi.hwndOwner = hwnd
    bi.lpszTitle = to_wchar_ptr(this.title)
    bi.ulFlags = BIF_RETURNONLYFSDIRS | BIF_NEWDIALOGSTYLE
    if this.newFolBtn do bi.ulFlags = bi.ulFlags | BIF_NONEWFOLDERBUTTON
    if this.showFiles do bi.ulFlags = bi.ulFlags | BIF_BROWSEINCLUDEFILES
    pidl : LPITEMIDLIST = SHBrowseForFolder(&bi)
    if pidl != nil {
        res := cast(int)SHGetPathFromIDList(pidl, &buffer[0])
        if res != 0 {
            CoTaskMemFree(pidl)
            this.selectedPath = wstring_to_string(&buffer[0])
            return true
        } else {
            CoTaskMemFree(pidl)
        }
    }
    return false
}

dialog_show :: proc(di: ^$T, hw: HWND = nil) -> bool
{
    when T == FileOpenDialog {
        return open_dialog_helper(di, hw)
    } else when T == FileSaveDialog {
        return save_dialog_helper(di, hw)
    } else when T == FolderBrowserDialog {
        return folder_browser_helper(di, hw)
    }
    return false
}

dialog_set_filters :: proc(di: ^DialogBase, ftypes: ..string)
{
    sb := strings.builder_make()
    strings.write_string(&sb, fmt.tprintf("%s\x00", ftypes[0])) // First item is the description
    extCount := len(ftypes)
    for i in 1..<extCount {
        if i == extCount - 1 {
            strings.write_string(&sb, fmt.tprintf("*%s\x00\x00", ftypes[i])) // It is the last extension
        } else {
            strings.write_string(&sb, fmt.tprintf("*%s;", ftypes[i]))
        }
    }
    di.filter = strings.to_string(sb)
}

dialog_set_filter :: proc(di: ^DialogBase, description, ftype: string)
{
    di.filter = fmt.tprintf("%s\x00*%s\x00", description, ftype)
}

dialog_append_filter :: proc(di: ^DialogBase, description, ftype: string)
{
    di.filter = fmt.tprintf("%s%s\x00*%s\x00", di.filter, description, ftype)
}

dialog_destroy :: proc(this: ^FileOpenDialog)
{
    if this.multiSel do delete(this.selectedFiles)
}