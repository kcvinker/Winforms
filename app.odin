

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
    tv : ui.TreeView
    n2_1 : ui.TreeNode
    n2 : ui.TreeNode
    
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
    { // tree view
        tv = new_treeview(&frm)
        tv.has_checkboxes = true
        tv.back_color = 0xC6C6FF
        tv.fore_color = 0x008000
        tv.line_color = red
        create_treeview(&tv)
        // treeview_create_image_list(&tv, 2)
        // image_list_add_icon(tv.image_list, "shell32.dll", 167, false)
        // image_list_add_icon(tv.image_list, "shell32.dll", 42, false)

        n1 := new_treenode("Vinod", 0, 0, 0x0000FF)
            n1_1 := new_treenode("Translator", 1)
            n1_2 := new_treenode("Get Love", 1)
        n2 = new_treenode("Vinayak", 0, 1)
            n2_1 = new_treenode("Married man", 1)
            n2_2 := new_treenode("Jobless", 1)

        treeview_add_node(&tv, &n1)
            treeview_add_node(&tv, &n1_1, &n1)
            treeview_add_node(&tv, &n1_2, &n1)
        treeview_add_node(&tv, &n2)
            treeview_add_node(&tv, &n2_1, &n2)
            treeview_add_node(&tv, &n2_2, &n2)
        //ptf("n2 handle - %d\n", n2.handle)
       // ptf("n2 index - ")

    }  
    
    //print(U32MAX)
    
  
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

frm_click :: proc(c : ^Control, e : ^EventArgs) {
    //ui.control_set_back_color(&tv, 0x00FF00)
    //  n2.fore_color = 0x00FFFF
    //  n2.back_color = 0xFF8000
    // ui.treeview_set_node_color(&tv, &n2)
}
