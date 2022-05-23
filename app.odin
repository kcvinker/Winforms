

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
	dtp : ui.DateTimePicker
    
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
    lv.has_checkboxes = true
    //lv.view_mode = ListViewViews.List
    //lv.edit_label = 
    
	
	dtp = new_datetimepicker(&frm, lv.width + 20, 50, 180, 30)
	dtp.format = DtpFormat.Custom
	dtp.format_string = "HH:mm:ss"
	create_controls(&lv, &dtp)
	
    

    //cS := new_listview_column("Salaries", 70, ColumnAlignment.right)
    
    listview_add_column(&lv, "✔", 50)
    listview_add_column(&lv, "Names", 130)
    
    listview_add_column(&lv, "Jobs", 80 )
    listview_add_column(&lv, "Age", 50)
    listview_add_column(&lv, "Salaries", 70)
    
   

    

    listview_add_row(&lv, "", "Vinod", "Translator", 39, 40000)
    listview_add_row(&lv, "", "Vinayak", "DTP staff", 32, 15000)
    listview_add_row(&lv, "", "Malu", "House wife", 26, 1000)
    
    print("lv handle", lv.handle) 
    // lang := ini_readkey(`E:\OneDrive Folder\OneDrive\Programming\Odin\Winforms\af.ini`, "Controls", "ename")
   
    // defer delete(lang)

    //lv_get_coulmn_count(&lv)
   // listview_set_column_order(lv, 1, 2, 3, 4, 0 )
    
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
    //print("form clicked with new select call operator")
    
    
}
