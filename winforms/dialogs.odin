// Created on 25-Nov-2023 11:06 PM

package winforms
import "core:fmt"
import "base:runtime"
// import "core:strings"
import "core:mem"

// Constants
    MAX_PATH :: 260
    MAX_ARR_SIZE :: 65535
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
    
    

    DialogBase :: struct {
        kind : DialogType,
        title, initDir, selectedPath : string,
        fileStart, extStart : int,
        allowAllFiles: bool,
        filter : ^DString
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


    OFNHOOKPROC :: distinct #type proc "stdcall"(hwnd: HWND, msg: uint, wpm: WPARAM, lpm: LPARAM) -> UINT_PTR
    BROWSECBPROC :: distinct #type proc "stdcall"(hwnd: HWND, msg: uint, lpm1: LPARAM, lpm2: LPARAM) -> i32

// End Type

make_filter_string :: proc(this: ^DialogBase, filterString: string, alloc:= context.allocator)
{
    this.filter = newDString(alloc, len(filterString) + 2)
    dstring_append(this.filter, filterString, alloc)
    dstring_replace(this.filter, "|", "\x00", alloc)
    dstring_append(this.filter, "\x00\x00", alloc)
    ptf("Filter string ptr: %p\n", this.filter.data)
}

// Create new FileOpenDialog. 
// NOTE: The filterStr uses '|' as separator between description and extensions.
// Example1: "Image Files|*.png|Text Files|*.txt"
// Example2: "Document Files|*.doc;*.docx;*.pdf"
// Example1 uses multiple filters with multiple description.
// Example2 uses multiple extensions in a single filter.
file_open_dialog :: proc(titleStr: string = "Open file", 
                         initFolder: string = "", 
                         filterStr: string = "All Files|*.*") -> ^FileOpenDialog
{
    this := new(FileOpenDialog)
    this.title = titleStr
    this.initDir = initFolder
    this.kind = DialogType.File_Open
    make_filter_string(this, filterStr)
    return this
}

// Create new FileSaveDialog. 
// NOTE: The filterStr uses '|' as separator between description and extensions.
file_save_dialog :: proc(titleStr: string = "Save As", 
                         initFolder: string = "",
                         filterStr: string = "All Files|*.*") -> ^FileSaveDialog
{
    this := new(FileSaveDialog)
    this.title = titleStr
    this.initDir = initFolder
    this.kind = DialogType.File_Save
    make_filter_string(this, filterStr)
    return this
}

folder_browser_dialog :: proc(titleStr: string = "Save As", 
                              initFolder: string = "") -> ^FolderBrowserDialog
{
    this := new(FolderBrowserDialog)
    this.title = titleStr
    this.initDir = initFolder
    return this
}



@private extract_file_names :: proc(this: ^FileOpenDialog, 
                                    buffer: []WCHAR, 
                                    start: WORD,
                                    alloc: runtime.Allocator)
{
    context = global_context
    start_pos:= cast(int)start

    // This will be freed by the caller when they free the arena allocator.
    // First item in buffer is directory path.
    dir_path := utf16_to_utf8(buffer[0:(start_pos - 1)], alloc) 
    for i in start_pos..<MAX_ARR_SIZE {
        if buffer[i] == 0 {
            slice := buffer[start_pos:i]
            start_pos = i + 1
            append(&this.selectedFiles, fmt.aprintf("%s\\%s", 
                                                     dir_path, 
                                                     utf16_to_utf8(slice, alloc), 
                                                     context.allocator))
            if buffer[start_pos] == 0 do break
        }
    }
}

@private isPathContainsWhiteSpace :: proc(initfolder: string) -> bool
{
    idirlen := len(initfolder)
    if idirlen > 0 && initfolder[idirlen - 1] != '\\' {
        for i := (idirlen - 1); i > 1; i -= 1 {
            if initfolder[i] == '\\' do return false
            if initfolder[i] == ' ' do return true
        }
    }
    return false
}

@private calc_arena_size :: proc(this: ^$T, init_size: int) -> int
{
    arena_size : int = (init_size * 2)
    when T == FolderBrowserDialog {
        if len(this.title) > 0 do arena_size += (len(this.title) + 1) * 2
    } else {
        if this.filter.len > 0 do arena_size += (this.filter.len + 1) * 2
        if len(this.initDir) > 0 do arena_size += (len(this.initDir) + 1) * 2
        if len(this.title) > 0 do arena_size += (len(this.title) + 1) * 2
    }    
    return arena_size
}

@private open_dialog_helper :: proc(this: ^FileOpenDialog, hwnd: HWND = nil)-> bool
{
    /* We are using arena allocator here to allocate memory for the dialog buffers.
       This memory will be freed when the dialog is closed. But caller must call 
       dialog_destroy function after calling this. 
    */
    context = global_context    
    buffer : [dynamic]WCHAR
    def_size : int = this.multiSel? MAX_ARR_SIZE : MAX_PATH
    arena_size : int = calc_arena_size(this, def_size + 20) // Extra 20 chars for safety

    mem_block := make([]byte, arena_size)
    arena : mem.Arena
    mem.arena_init(&arena, mem_block)
    arena_alloc := mem.arena_allocator(&arena)
    defer delete(mem_block)

    if this.multiSel {
        buffer = make([dynamic]WCHAR, MAX_ARR_SIZE, arena_alloc)
    } else {
        buffer = make([dynamic]WCHAR, MAX_PATH, arena_alloc)
    }       

    // This is a hack. Windows will ignore the initial directory path if it...
    // contains a space in it's last part. But if path ends with a '\' it will work. So here...
    // we are checking for white space and put the '\' at the end.
    if isPathContainsWhiteSpace(this.initDir) {
        this.initDir = fmt.aprintf("%s\\", this.initDir, allocator = arena_alloc)
    }
    ofn : OPENFILENAMEW
    ofn.hwndOwner = hwnd
    ofn.lStructSize = size_of(ofn)
    ofn.lpstrFilter = to_wchar_ptr(dstring_to_string(this.filter), arena_alloc)
    ofn.lpstrFile = &buffer[0]
    ofn.lpstrInitialDir = this.initDir == "" ? nil : to_wchar_ptr(this.initDir, arena_alloc)
    ofn.lpstrTitle = to_wchar_ptr(this.title, arena_alloc)
    ofn.nMaxFile = MAX_ARR_SIZE
    ofn.nMaxFileTitle = MAX_PATH
    ofn.lpstrDefExt = dir_cast(0, ^WCHAR)
    ofn.Flags = OFN_PATHMUSTEXIST | OFN_FILEMUSTEXIST
    if this.multiSel do ofn.Flags = ofn.Flags | OFN_ALLOWMULTISELECT | OFN_EXPLORER
    if this.showHidden do ofn.Flags = ofn.Flags | OFN_FORCESHOWHIDDEN
    ret := cast(int)GetOpenFileName(&ofn)    
    if ret > 0 {
        if this.multiSel {
            // We are using arena allocator to store the dir path and file names.
            extract_file_names(this, buffer[:], ofn.nFileOffset, arena_alloc)
            return true
        } else {
            this.selectedPath = utf16_to_utf8(buffer[:], context.allocator)
            return true
        }
    }    
    return false
}

@private save_dialog_helper :: proc(this: ^FileSaveDialog, hwnd: HWND) -> bool
{
    if isPathContainsWhiteSpace(this.initDir) {
        this.initDir = fmt.tprintf("%s\\", this.initDir)
    }
    arena_size : int = calc_arena_size(this, MAX_PATH)   
    mem_block := make([]byte, arena_size)
    arena : mem.Arena
    mem.arena_init(&arena, mem_block)
    arena_alloc := mem.arena_allocator(&arena)
    defer delete(mem_block)

    buffer := make([dynamic]WCHAR, MAX_PATH, arena_alloc)
    ofn : OPENFILENAMEW
    ofn.hwndOwner = hwnd
    ofn.lStructSize = size_of(ofn)
    ofn.lpstrFilter = to_wchar_ptr(dstring_to_string(this.filter), arena_alloc)
    ofn.lpstrFile = &buffer[0]
    ofn.lpstrInitialDir = this.initDir == "" ? nil : to_wchar_ptr(this.initDir, arena_alloc)
    ofn.lpstrTitle = to_wchar_ptr(this.title, arena_alloc)
    ofn.nMaxFile = MAX_PATH
    ofn.nMaxFileTitle = MAX_PATH
    ofn.lpstrDefExt = dir_cast(0, ^WCHAR)
    ofn.Flags = OFN_PATHMUSTEXIST | OFN_OVERWRITEPROMPT
    ret := cast(int) GetSaveFileName(&ofn)
    if ret != 0 {
        this.fileStart = int(ofn.nFileOffset)
        this.extStart = int(ofn.nFileExtension)
        this.selectedPath = wstring_to_string(&buffer[0], context.allocator)
        return true
    }
    // free_all(context.temp_allocator)
    return false
}

@private folder_browser_helper :: proc(this: ^FolderBrowserDialog, hwnd: HWND = nil) -> bool
{
    arena_size : int = calc_arena_size(this, MAX_PATH)   
    mem_block := make([]byte, arena_size)
    arena : mem.Arena
    mem.arena_init(&arena, mem_block)
    arena_alloc := mem.arena_allocator(&arena)
    defer delete(mem_block)

    buffer := make([dynamic]WCHAR, MAX_PATH, arena_alloc)
    bi : BROWSEINFOW
    bi.hwndOwner = hwnd
    bi.lpszTitle = to_wchar_ptr(this.title, arena_alloc)
    bi.ulFlags = BIF_RETURNONLYFSDIRS | BIF_NEWDIALOGSTYLE
    if this.newFolBtn do bi.ulFlags = bi.ulFlags | BIF_NONEWFOLDERBUTTON
    if this.showFiles do bi.ulFlags = bi.ulFlags | BIF_BROWSEINCLUDEFILES
    pidl : LPITEMIDLIST = SHBrowseForFolder(&bi)
    if pidl != nil {
        res := cast(int)SHGetPathFromIDList(pidl, &buffer[0])
        if res != 0 {
            CoTaskMemFree(pidl)
            this.selectedPath = wstring_to_string(&buffer[0], context.allocator)
            return true
        } else {
            CoTaskMemFree(pidl)
        }
    }
    // free_all(context.temp_allocator)
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

dialog_set_filters :: proc(this: ^DialogBase, filterStr: string)
{
    if this.filter != nil do dstring_destroy(this.filter)
    make_filter_string(this, filterStr)    
}



dialog_destroy :: proc(this: ^$T)
{
    when T == FileOpenDialog {        
        if this.multiSel {
            for f in this.selectedFiles {
                delete(f)
            }
            delete(this.selectedFiles)
        }
        dstring_destroy(this.filter)
    } else when T == FileSaveDialog {
        dstring_destroy(this.filter)
    } 
    delete(this.selectedPath)
    free(this)
}