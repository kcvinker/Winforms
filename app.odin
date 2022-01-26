

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
    b1 : ui.Button 
    tb : ui.TextBox
    lb : ui.Label
    cb : ui.CheckBox
    mb : ui.ComboBox
    dp : ui.DateTimePicker
    //gb : ui.GroupBox
    lbx : ui.ListBox

//

main :: proc() {   
    // Old code 
    track: mem.Tracking_Allocator
    mem.tracking_allocator_init(&track, context.allocator)
    context.allocator = mem.tracking_allocator(&track)
    using ui
    { // FORM
        frm = new_form(txt = "Odin is fun")    
        frm.font = new_font("Tahoma", 13)         
        frm.width = 700
        frm.mouse_click = btn_clk    
        create_form(&frm)
    }       

    { // TEXTBOX
        tb = new_textbox(&frm)    
        tb.text = "Simple tb"   
        create_textbox(&tb)
    }       

    { // LABEL
        lb = new_label(&frm, "Just a label")
        lb.ypos = 50
        lb.xpos = 10
        //lb.back_color = 0x000000
        lb.fore_color = 0x00D56A
        create_label(&lb)
    }
    { // CHECKBOX
        cb = new_checkbox(&frm, "Select Me", 110, 25)
        cb.xpos = 130
        cb.ypos = 50
        //cb.text_alignment = .right
        cb.fore_color = 0x0000FF
        //cb.back_color = 0xFF8000
        // cb.back_color = 0x00FF00
        create_checkbox(&cb)  
    }
    
    { // COMBOBOX 1
        mb = new_combobox(&frm)
        mb.xpos = 220
        mb.ypos = 10
        // mb.combo_style = .lb_combo
        mb.back_color = 0xFFC3A0
        mb.fore_color = 0x0000A0
        //mb.combo_style =.lb_combo   
        combo_add_items(&mb, "Vinod", "Vinayak", "Malu", "സിനിമ", 150, 25.1, 1000, b1.handle)
        // add_combo_item(&mb, 4568)
        //mb.list_closed = cbMleave   
        create_combo(&mb)
    }

    { // COMBO 2
         //ptf("combo hwnd - %s\n", fmt.tprint(mb.handle))
        cmb := new_combobox(&frm)
        cmb.xpos = 380
        cmb.ypos = 10
        cmb.combo_style = .lb_combo
        combo_add_items(&cmb, "Vinod", "Vinayak", "Malu", "സിനിമ", 150, 25.1, 1000, b1.handle)
        create_combo(&cmb)
    }
        
    { // BUTTON1
         b1 = new_button(&frm, "Color Btn", 10, 100)
        // b1.xpos = 10
        // b1.ypos = 100
        b1.back_color = 0x800080
        b1.fore_color = 0xFFFFFF
        create_button(&b1)
    }      

    { // Button 2
        b2 := new_button(&frm, "Gradient Btn", 10, 150,)
        set_button_gradient(&b2, 0xDCE35B, 0x45B649)
        create_button(&b2)

        b3 := new_button(&frm, "Normal Btn", 10, 200,)        
        create_button(&b3)
    }
    { // DTP
        dp = new_datetimepicker(parent= &frm, w=140, h=25, x=170, y=100)
        // dp.xpos = 170
        // dp.ypos = 100
        // dp.text_changed = dtp_tb
        dp.format = .custom
        //dp.show_updown = true
        dp.format_string = "dd-MM-yyyy"
        //dp.short_day_names = true
        //dp.right_align = true
        create_datetimepicker(&dp)
    }

    // old code
    {
        lbx = new_listbox(&frm)
        lbx.xpos = 320
        lbx.ypos = 50
        lbx.multi_selection = true
        lbx.key_preview = true
        lbx.hide_selection = true
    // lbx.selection_changed = dtp_tb
    }
    
    listbox_add_items(&lbx, "Odin", "Learning", "Started", "And It's awesome")
    create_listbox(&lbx)

    
  
    start_form() 
    for _, v in track.allocation_map { ptf("%v leaked %v bytes\n", v.location, v.size) }
    for bf in track.bad_free_array { ptf("%v allocation %p was freed badly\n", bf.location, bf.memory) }  
    
}


test_proc :: proc(s : ^Control, e : ^MouseEventArgs) {          
    print("Your event worked successfully...")    
   
    print("----------------------------------------") 
}

btn_clk :: proc(s : ^Control, e : ^EventArgs) {  
    print("form moved to  this loc")
    //print(ui.listbox_get_selection_indices(&lbx))
    print("selected item - " )
    ui.listbox_clear_selection(&lbx)
    //ui.listbox_delete_item(&lbx, 2)
    //ui.listbox_insert_item(&lbx, 3, "Sunny Leon")
   
    
} 


mup :: proc(s : ^Control, e : ^MouseEventArgs) {  
    //f.msg_box("You clicked on button")
    print("Mouse up  on worked")
} 

cbMenter :: proc(s : ^Control, e : ^EventArgs) {
   
    print("------------mouse entered on group box-----------------------------")

}

cbMmove :: proc(s : ^Control, e : ^MouseEventArgs) {  
    print("cb mouse moving...")
}

cbMleave :: proc(s : ^Control, e : ^EventArgs) {
   
}
dtp_tb :: proc(s : ^Control, e : string) {
    print(" this is dtp value - ", e)
}


