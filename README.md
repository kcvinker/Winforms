# Winforms
A simple GUI library for Odin programming language.

It is built upon win32 API functions. So it needs Windows 64 bit to run.
Currently, it's a work in progress project.

## Control List
Button, Calendar, CheckBox, ComboBox, DateTimePicker, GroupBox, Label, ListBox, TextBox
NumberPicker (Updown Control), ProgressBar, RadioButton, TrackBar, TreeView, MenuBar

## Screenshot

![image](/winforms2311.jpg)



## Example --

This is the code used to create the window and controls in the above image.

```rust

package main

import "core:fmt"
import "core:mem"
import "base:runtime"
import  ui "winforms"

// Global declarations
    print :: fmt.println
    ptf :: fmt.printf
    pgb : ^ui.ProgressBar // We are using pgb & tk in inner procs. So these must be globals.
    tk : ^ui.TrackBar
    tmr: ^ui.Timer
    ti : ^ui.TrayIcon
//

MakeWindow :: proc()
{
    using ui
    frm := new_form( txt = "Odin is fun")
    frm.width = 1100
    frm.height = 500
    frm.font = new_font("Tahoma", 13)

    // When we click on somewhere, it prints the mouse coordintes.
    // Handy at design time because, you can easily know the points for a new control.
    print_points(frm)
    create_handle(frm)

    // Let's create a tray icon.
    ti = new_tray_icon("Winforms tray icon!", "winforms-icon.ico") // Icon is located in repo.
    frm.onMouseClick = frmClickProc // Show a balloon text when clicking on form.

    // Let's add a context menu for our tray icon.
    tray_add_context_menu(ti, .Right_Click, "Windows", "Linux", "ReactOS")
    ti.contextMenu.menus[0].onClick = proc(c: ^MenuItem, ea: ^EventArgs) {print("Windows menu selected")}

    // Let's add a timer to this form which ticks in every 400 ms.
    // And our timer_ontick proc will be called on each tick.
    tmr = form_addTimer(frm, 400, timer_ontick)

    // Let's add a menubar and some menu items.
    mbar := new_menubar(frm, "File", "Edit", "Format")
    menubar_add_items(mbar, mbar.menus[0], "New Work", "New Client", "Exit")
    menubar_add_items(mbar, mbar.menus[1], "New Client", "Copy", "Delete")
    menubar_add_items(mbar, mbar.menus[2], "Font", "Line Space", "Para Spce")
    menubar_add_items(mbar, mbar.menus[0].menus[0], "Contract Work", "Carriage Work", "Transmission Work")
    mbar.menus[0].menus[1].onClick = newclient_menuclick // Set the event handler

    // Create some buttons.
    b1 := new_button(frm, "Normal", 10, 10, 110, 35 )
    b2 := new_button(frm, "Flat Color", cright(b1) + 20, 10, 120, 35 )
    set_property(b2, CommonProps.Back_Color, 0x94d2bd) // New function.
    b2.onMouseClick = b2_click_proc // On b2 click, we can start the timer.

    b3 := new_button(frm, "Gradient", cright(b2) + 20, 10, 110, 35 )
    button_set_gradient_colors(b3, 0xfb8500, 0xffbe0b)

    // A combo box
    cmb := new_combobox(frm, cright(b3) + 20, 10, autoc = true)
    combo_add_items(cmb, "Windows", "MacOS", "Linux", "ReactOS")
    set_property(cmb, ComboProps.Selected_Index, 0)

    // A DateTimePicker
    dtp := new_datetimepicker(frm, cright(cmb) + 20, 10, autoc = true)

    // A GroupBox
    gb := new_groupbox(frm, "Format Options", 10, cbottom(b1) + 20, w=230, h=110, autoc = true)

    // A Label
    lb1 := new_label(frm, "Line_Space", gbx(gb, 10), gby(gb, 40), autoc = true)

    // NumberPicker aka UpDown control or Spinner
    np1 := new_numberpicker(frm, cright(lb1) + 15, gby(gb, 35), autoc = true, deciPrec = 2, step = 0.25)
    np1.foreColor = 0x9d0208

    lb2 := new_label(frm, "Col Width", gbx(gb, 10), cbottom(lb1) + 20, autoc = true)
    np2 := new_numberpicker(frm, np1.xpos, cbottom(np1) + 15)
    np2.buttonOnLeft = true
    np2.backColor = 0xcaffbf

    gb2 := new_groupbox(frm, "Compiler Options", 10, cbottom(gb) + 20, w = 210, h = 200, autoc = true)

    // A CheckBox
    cb := new_checkbox(frm, "Show Timings", gbx(gb2, 10), gby(gb2, 40), autoc = true)
    cb2 := new_checkbox(frm, "No Entry Point", gbx(gb2, 10), cbottom(cb) + 20, autoc = true)

    // A RadioButton
    rb1 := new_radiobutton(frm, "SubSystem:Windows", gbx(gb2, 10), cbottom(cb2) + 20)
    rb1.foreColor = 0xd90429
    create_control(rb1)
    rb2 := new_radiobutton(frm, "SubSystem:Console", gbx(gb2, 10), cbottom(rb1) + 10)

    // A ListBox
    lbx := new_listbox(frm, cright(gb) + 10, cbottom(b1) + 10, autoc = true)
    listbox_add_items(lbx, "Windows", "MacOS", "Linux", "ReactOS")
    set_property(cb2, CheckBoxProps.Checked, true)

    // A ListView. (For now, Details view is possible.)
    lv := new_listview(frm, cright(lbx) + 10, cbottom(b3) + 10, 340, 150, "Windows", "MacOS", "Linux", 100, 120, 100)
    listview_add_row(lv, "XP", "Mountain Lion", "RedHat")
    listview_add_row(lv, "Vista", "Mavericks", "Mint")
    listview_add_row(lv, "Win7", "Mavericks", "Ubuntu")
    listview_add_row(lv, "Win8", "Catalina", "Debian")
    listview_add_row(lv, "Win10", " Big Sur", "Kali")

    // Adding a context menu for list view
    control_add_contextmenu(lv, "Compile", "Link Only", "Make DLL", "Make Console")
    lv.contextMenu.menus[0].onClick = contextmenu_click // Handler for "Compile" menu

    // A TextBox
    tb := new_textbox(frm, cright(gb2) + 10, cbottom(lbx) + 20, autoc = true)

    // A ProgressBar
    pgb = new_progressbar(frm, lv.xpos, cbottom(lv) + 15, lv.width, 30, autoc = true, perc = true)

    // A TrackBar
    tk = new_trackbar(frm, lv.xpos, cbottom(pgb) + 20, 200, 50)
    tk.customDraw = true
    tk.onValueChanged = track_change_proc

    // A TreeView
    tv := new_treeview(frm, cright(lv) + 20, dtp.ypos, 250, 220, autoc = true)
    treeview_add_nodes(tv, "Windows", "MacOS", "Linux", "ReactOS")
    treeview_add_childnodes(tv, 0, "XP", "Vista", "Win7", "Win8", "Win10", "Win11")
    treeview_add_childnodes(tv, 1, "Mountain Lion", "Mavericks", "Catalina", " Big Sur", "Monterey")
    treeview_add_childnodes(tv, 2, "RedHat", "Mint", "Ubuntu", "Debian", "Kali")

    // A Calendar
    cal := new_calendar(frm, tv.xpos, cbottom(tv) + 20, true)

    // Event handling procs
    track_change_proc :: proc(c : ^ui.Control, e : ^ui.EventArgs) {
        ui.progressbar_set_value(pgb, tk.value)
    }

    newclient_menuclick :: proc(sender: ^ui.MenuItem, e: ^ui.EventArgs) {
        print("New Client selected")
    }

    contextmenu_click :: proc(sender: ^ui.MenuItem, e: ^ui.EventArgs) {
        ptf("%s option is selected\n", sender.text)
    }

    b2_click_proc :: proc(c : ^ui.Control, e : ^ui.EventArgs) {
        ui.timer_start(tmr)
    }

    timer_ontick :: proc(f: ^ui.Control, e: ^ui.EventArgs) {
        print("Timer ticked")
    }

    frmClickProc :: proc(c: ^ui.Control, ea: ^ui.EventArgs) {
        tray_show_balloon(ti, "Winforms", "Info from Winforms", 3000)
    }

    // All set, now we can display the form!
    start_mainloop(frm)
}

main :: proc()
{
    track: mem.Tracking_Allocator
    mem.tracking_allocator_init(&track, context.allocator)
    context.allocator = mem.tracking_allocator(&track)
    defer mem.tracking_allocator_destroy(&track)
    MakeWindow()
    ui.show_memory_report(&track)
}

```

## How to use --
1. Download or clone repo.
2. Copy the folder **winforms** and paste it in project folder.
3. Import **winforms** in your main file. Done !!! 👍

## Note
To enable visual styles for your application, you need to use a manifest file.
Here you can see a **app.exe.manifest** file in this repo. You can copy paste it in your project folder. Then rename it. The name must be your exe file's name. Here in my case, my exe file is **app.exe**. So my manifest file's name is **app.exe.manifest**. However, you can use a reource file and put an entry for this manifest file in it. Then you can compile the app with the manifest data embedded into your exe.
