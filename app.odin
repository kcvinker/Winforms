

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
    lb1 : ui.Label
    lbx : ui.ListBox
    tk : ui.TrackBar
    tb : ui.TextBox
    cmb : ui.ComboBox
    btn : ui.Button

//

MakeWindow :: proc() {
    // Old code

    using ui
    { // FORM
        frm = new_form(txt = "Odin is fun")
        frm.font = new_font("Tahoma", 13)
        // frm.width = 700
        frm.left_mouse_down = frm_mouse_down
        // frm.right_click = frm_right_click
        create_form(&frm)
    }

    // lv = new_listview(&frm)
    // lv.width = 450
    // lv.show_grid_lines = true
    // lv.has_checkboxes = true
    // lv.view_style = ListViewStyle.List
    //lv.view_mode = ListViewViews.List
    //lv.edit_label =


	// dtp = new_datetimepicker(&frm, lv.width + 20, 50, 180, 30)
	// dtp.format = DtpFormat.Custom
	// dtp.format_string = "HH:mm:ss"


    // lb1 = new_label(&frm, 541, 149, "Learning Odin")
    // lbx = new_listbox(&frm, 15, 200)
    // listbox_add_items(&lbx, "Edwidge Danticat", "Herodotus", "Franz Kafka", "Fannie Flagg")
    //lbx.multi_selection = true

    npk := new_numberpicker(&frm, 50, 50, 100, 27)
    // npk.hide_selection = true
    npk.back_color = 0xccff66
    npk.track_mouse_leave = true
    npk.mouse_enter = np_mouse_enter
    npk.mouse_leave = np_mouse_leave


    tk = new_trackbar(&frm, 25, 110, 206, 40)
    // tk.cust_draw = true
    // tk.channel_style = ChannelStyle.classic
    tk.sel_range = true
    // tk.channel_color = 0xff00fc
    // tk.tic_color = 0x00bb44


    tb = new_textbox(&frm, 120, 24, 200, 55)
    tb.fore_color = 0x005534

    cmb = new_combobox(&frm, 130, 25, 50, 185)
    combo_add_items(&cmb, "Vinod", "Vinayak", "Vineetha")
    //cmb.combo_style = DropDownStyle.Lb_Combo
    // cmb.mouse_enter = combo_mouse_enter
    // cmb.mouse_leave = combo_mouse_leave

    cmb.back_color = 0xccff66
    // cmb.fore_color = 0x00ff66

    btn = new_button(&frm, "Click Me", 100, 28, 50, 230)
    btn.mouse_click = btn_click




    create_controls(&npk, &tk, &tb, &cmb, &btn)

    //cS := new_listview_column("Salaries", 70, ColumnAlignment.right)

    // listview_add_column(&lv, "✔", 50)
    // listview_add_column(&lv, "Names", 130)

    // listview_add_column(&lv, "Jobs", 80 )
    // listview_add_column(&lv, "Age", 50)
    // listview_add_column(&lv, "Salaries", 70)





    // listview_add_row(&lv, "", "Vinod", "Translator", 39, 40000)
    // listview_add_row(&lv, "", "Vinayak", "DTP staff", 32, 15000)
    // listview_add_row(&lv, "", "Malu", "House wife", 26, 1000)
    // listview_add_row(&lv, "Vinod")
    // listview_add_row(&lv, "Vinayak")
    // listview_add_row(&lv, "Malu")

    // print("lv handle", lv.handle)
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
    //print("form clicked with new select call operator")  541, 149

}

frm_mouse_down :: proc(c : ^Control, e : ^MouseEventArgs) {
    ui.print_point(e)
    ind := ui.combo_get_selected_index(&cmb)
    print(ind)
}

np_mouse_enter :: proc(c : ^Control, e : ^EventArgs) {
    print("np mouse entered")
}

np_mouse_leave :: proc(c : ^Control, e : ^EventArgs) {
    print("np mouse levae")
}

btn_click :: proc(c : ^Control, e : ^EventArgs) {
    print("We can change combo style now")
    ui.set_prop(&cmb, "selected_item", "Vinod")
    // ui.testproc(&cmb, cmb.back_color)
}

combo_mouse_enter :: proc(c : ^Control, e : ^EventArgs) { print("combo mouse entered in main ") }
combo_mouse_leave :: proc(c : ^Control, e : ^EventArgs) { print("combo mouse leaved in main ") }
