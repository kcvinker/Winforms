
// Created on 15-12-2025 15:10:00 by kcvinker
package winforms

import "base:runtime"
// import "core:strings"
import "core:mem"

DString :: struct 
{    
    data      : [dynamic]u8,   // raw buffer
    len       : int,    // used length
    capacity  : int     // allocated capacity
}

newDStringWithCapacity :: proc(alloc: runtime.Allocator, cap: int) -> ^DString 
{
    ds := new(DString, alloc)
    ds.data = make([dynamic]u8, cap, cap, alloc)
    ds.len = 0
    ds.capacity = cap
    return ds
}

newDStringWithString :: proc(allocator: runtime.Allocator, str: string) -> ^DString 
{   
    stlen := len(str)
    ds := newDStringWithCapacity(allocator, stlen)
    for i:= 0; i < stlen; i +=1 {
        ds.data[i] = str[i]
    }
    ds.len = stlen
    return ds
}

newDString :: proc{newDStringWithCapacity, newDStringWithString}

dstring_destroy :: proc(ds: ^DString) 
{
    // ptf("DString destroy called, data ptr: %p\n", ds.data)
    delete(ds.data)
    free(ds)
}

dstring_append :: proc(ds: ^DString, str: string, alloc: runtime.Allocator) 
{
    if ds.data == nil {
        return
    } else {
        strLen := len(str)
        newLen := ds.len + strLen
        if newLen > ds.capacity {
            print("Reallocating DString buffer")
            newCap := max(ds.capacity * 2, newLen)
            newData := make([dynamic]u8, newLen, newCap, alloc)
            if ds.len > 0 do copy(newData[0:ds.len], ds.data[0:ds.len])
            delete(ds.data)
            ds.data = newData
            ds.capacity = newCap
        }
        ptf("strlen %d, dslen: %d\n", strLen, ds.len)
        for i in 0 ..< strLen {
            ds.data[ds.len + i] = str[i]
        }
        ds.len = newLen
    }    
}

dstring_replace :: proc(ds: ^DString, oldStr: string, newStr: string, alloc: runtime.Allocator) 
{
    if ds.data == nil || ds.len == 0 do return
    oldstr_len := len(oldStr)
    newstr_len := len(newStr)
    if oldstr_len == 1 && newstr_len == 1 {
        dstring_replace_char(ds, oldStr[0], newStr[0])
        return
    }
    // print("DString replace called, data ptr")
    src := ds.data[:ds.len]

    // --------------------------------------------------
    // Step 1: count matches
    // --------------------------------------------------
    count := 0
    i := 0
    for i + oldstr_len <= ds.len {
        if match_at(src, i, oldStr) {
            count += 1
            i += oldstr_len
        } else {
            i += 1
        }
    }

    if count == 0 do return

    // --------------------------------------------------
    // Step 2: same-length → in-place replace
    // --------------------------------------------------
    if oldstr_len == newstr_len {
        i = 0
        for i + oldstr_len <= ds.len {
            if match_at(src, i, oldStr) {
                copy(ds.data[i:i+newstr_len], newStr)
                i += oldstr_len
            } else {
                i += 1
            }
        }
        return
    }

    // --------------------------------------------------
    // Step 3: allocate new buffer
    // --------------------------------------------------
    new_total_len := ds.len + count * (newstr_len - oldstr_len)
    new_data := make([dynamic]u8, new_total_len, alloc)

    // --------------------------------------------------
    // Step 4: copy + replace
    // --------------------------------------------------
    src_i := 0
    dst_i := 0

    for src_i < ds.len {
        if src_i + oldstr_len <= ds.len && match_at(src, src_i, oldStr) {
            copy(new_data[dst_i:dst_i+newstr_len], newStr)
            dst_i += newstr_len
            src_i += oldstr_len
        } else {
            new_data[dst_i] = src[src_i]
            dst_i += 1
            src_i += 1
        }
    }

    // --------------------------------------------------
    // Step 5: replace buffer
    // --------------------------------------------------
    delete(ds.data)
    ds.data = new_data
    ds.len = new_total_len
}

dstring_clear :: proc(ds: ^DString) 
{
    if ds.data != nil do ds.len = 0
}

dstring_to_string :: proc(ds: ^DString) -> string 
{
    if ds.data == nil || ds.len == 0 do return ""
    return string(ds.data[0:ds.len])
}

@private dstring_replace_char :: proc(ds: ^DString, oldChar: u8, newChar: u8) 
{
    if ds.data == nil || ds.len == 0 do return
    for i in 0 ..< ds.len {
        if ds.data[i] == oldChar do ds.data[i] = newChar
    }
}

@private match_at :: proc(data: []u8, pos: int, needle: string) -> bool 
{
    if pos + len(needle) > len(data) do return false
    for i in 0..<len(needle) {
        if data[pos+i] != needle[i] do return false
    }
    return true
}