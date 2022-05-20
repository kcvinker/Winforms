

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
    create_control(&lv)
    listview_add_column(&lv, "Names", 150)
    listview_add_column(&lv, "Jobs", 100)
    listview_add_column(&lv, "Age", 80)
    listview_add_column(&lv, "Salaries", 100)

   // li1 := new_listview_item("Item One")
    //li2 := new_listview_item("Item Two")

    // listview_add_item(&lv, &li1)
    // listview_add_item(&lv, &li2)

    // listview_add_row(&lv, "Vinod", "Translator", 39, 40000)
    // listview_add_row(&lv, "Vinayak", "DTP staff", 32, 15000)

    listview_add_row(&lv, "Vinod")
    listview_add_row(&lv, "Vinayak")

    listview_add_subitems(&lv, 0, "Translator", 39, 40000)
    listview_add_subitems(&lv, 1, "DTP staff", 32, 15000)
    
    //print(U32MAX) if a == b {}
    // lang := ini_readkey(`E:\OneDrive Folder\OneDrive\Programming\Odin\Winforms\af.ini`, "Controls", "ename")
    // print("ini text - ", lang)
    // defer delete(lang)

    //lv_get_coulmn_count(&lv)
    
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
