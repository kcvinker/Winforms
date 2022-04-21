

package main

import "core:fmt" 
import "core:mem"
//import "core:runtime"

import  ui "winforms"

// Global declarations

    Control :: ui.Control
    Form :: ui.Form
    MouseEventArgs :: ui.MouseEventArgs
    EventArgs :: ui.EventArgs
    KeyEventArgs :: ui.KeyEventArgs

    print :: fmt.println
    ptf :: fmt.printf
    pt :: fmt.print


    frm : ui.Form
    lv : ui.ListView
    
//

MakeWindow :: proc() {   
    // Old code 
    
    using ui
    { // FORM
        frm = new_form(txt = "Odin is fun")    
        frm.font = new_font("Tahoma", 13)         
        frm.width = 700  
        frm.mouse_click = frm_click      
        create_form(&frm)
    }     
    
    lv = new_listview(&frm)    
    lv.width = 450
    lv.show_grid_lines = true
    create_listview(&lv)
    listview_add_column(&lv, "col1", 150)
    listview_add_column(&lv, "col2", 100)
    listview_add_column(&lv, "col3", 80)

    li1 := new_listview_item("Item One")
    li2 := new_listview_item("Item Two")

    listview_add_item(&lv, &li1)
    listview_add_item(&lv, &li2)
    
    //print(U32MAX) if a == b {}
    
  
    start_form()  
    
}

main :: proc() {
    track: mem.Tracking_Allocator
    mem.tracking_allocator_init(&track, context.allocator)
    context.allocator = mem.tracking_allocator(&track)
    MakeWindow()
    for _, v in track.allocation_map { ptf("%v leaked %v bytes\n", v.location, v.size) }
    for bf in track.bad_free_array { ptf("%v allocation %p was freed badly\n", bf.location, bf.memory) }  
    
}

form_load :: proc(s : ^Control, e : ^EventArgs) {
   // ui.control_set_focus(tb)
    print("loaded")
   
}

clicked := 0

frm_click :: proc(c : ^Control, e : ^EventArgs) {
    print("form clicked with new select call operator")
    
}
