

// Created on : 18-May-22 06:54:39 AM
package winforms
import "core:strings"
//import "core:fmt"

/*
    This module contains functions for read & write ini files.
*/

ini_readkey :: proc(file_path, sec_name, key_name : string, alloc := context.allocator ) -> string {
    fpath := strings.clone_to_cstring(file_path, context.temp_allocator)
    secn := strings.clone_to_cstring(sec_name, context.temp_allocator)
    keyn := strings.clone_to_cstring(key_name, context.temp_allocator)
    buffer: [512]byte = ---
    written := GetPrivateProfileString(secn, keyn, nil, raw_data(&buffer), len(buffer), fpath)
    result := string(buffer[:written])
    return strings.clone(result, alloc)
}