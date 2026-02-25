# Winforms
A simple GUI library for Odin programming language.

It is built upon win32 API functions. So it needs Windows 64 bit to run.
Currently, it's a work in progress project.

## License
This project is licensed under the MIT License.

## Control List
Button, Calendar, CheckBox, ComboBox, DateTimePicker, GroupBox, Label, ListBox, TextBox
NumberPicker (Updown Control), ProgressBar, RadioButton, TrackBar, TreeView, MenuBar, TrayIcon

## Screenshot

![image](/winforms2311.jpg)



## Example --

This is the code used to create the window and controls in the above image.

```rust


package main

import "base:runtime"
import "core:fmt"
import "core:mem"
import ui "winforms"


// Global declarations
print :: fmt.println
ptf :: fmt.printf
pgb: ^ui.ProgressBar
tk: ^ui.TrackBar
frm: ^ui.Form
tmr: ^ui.Timer
ti: ^ui.TrayIcon

//

MakeWindow :: proc() {

	frm = ui.new_form(txt = "Odin is fun")
	frm.width = 1100
	frm.height = 500
	// frm.font = new_font("Tahoma", 13)
	ui.print_points(frm)

	ui.create_handle(frm)
	frm.createChilds = true
	// Let's create a tray icon.
	ti = ui.new_tray_icon("Winforms tray icon!", "winforms-icon.ico")
	// frm.onClick = frmClickProc // Show a balloon text when clicking on form.

	// // Let's add a context menu for our tray icon. "|" is for separator.
	ui.tray_add_context_menu(ti, false, .Any_Click, "Windows", "|", "Linux", "ReactOS")
	ti.contextMenu.menus[0].onClick = proc(c: rawptr, ea: ^ui.EventArgs) {print(
			"Windows menu selected",
		)}


	// // Let's add a timer to this form which ticks in every 400 ms.
	// // And our timer_ontick proc will be called on each tick.
	tmr = ui.form_addTimer(frm, 400, timer_ontick)

	mbar := ui.new_menubar(frm, false, "File", "Edit", "Format")


	// // Add some sub menus. "|" is for separator.
	ui.menubar_add_items(mbar, mbar.menus[0], "New Work", "New Client", "|", "Exit")
	ui.menubar_add_items(mbar, mbar.menus[1], "New Client", "Copy", "Delete")
	ui.menubar_add_items(mbar, mbar.menus[2], "Font", "Line Space", "Para Spce")
	ui.menubar_add_items(
		mbar,
		mbar.menus[0].menus[0],
		"Contract Work",
		"Carriage Work",
		"Transmission Work",
	)
	mbar.menus[0].menus[1].onClick = newclient_menuclick
	mbar.menus[0].menus[1].menuState = .Checked
	b1 := ui.new_button(frm, "Normal", 10, 10, 110, 35)
	b1.onClick = open_file_proc

	b2 := ui.new_button(frm, "Flat Color", ui.cright(b1) + 20, 10, 120, 35)
	ui.set_property(b2, ui.CommonProps.Back_Color, 0x94d2bd)
	b2.onClick = b2_click_proc

	b3 := ui.new_button(frm, "Gradient", ui.cright(b2) + 20, 10, 110, 35)
	ui.button_set_gradient_colors(b3, 0xfb8500, 0xffbe0b)

	cmb := ui.new_combobox(frm, ui.cright(b3) + 20, 10)
	ui.combo_add_items(cmb, "Windows", "MacOS", "Linux", "ReactOS")
	ui.set_property(cmb, ui.ComboProps.Selected_Index, 0)

	dtp := ui.new_datetimepicker(frm, ui.cright(cmb) + 20, 10)
	gb := ui.new_groupbox(frm, "Format Options", 10, 80, w = 230, h = 110) //, style=.Classic)
	lb1 := ui.new_label(frm, "Line_Space", ui.gbx(gb, 10), ui.gby(gb, 40))
	// set_property(lb1, CommonProps.Back_Color, 0xddAA45)
	np1 := ui.new_numberpicker(frm, ui.cright(lb1) + 15, ui.gby(gb, 35), deciPrec = 2, step = 1.5)
	np1.foreColor = 0x9d0208
	lb2 := ui.new_label(frm, "Col Width", ui.gbx(gb, 10), ui.cbottom(lb1) + 12)
	np2 := ui.new_numberpicker(frm, np1.xpos, ui.cbottom(np1) + 15)
	np2.buttonOnLeft = true
	np2.backColor = 0xcaffbf

	gb2 := ui.new_groupbox(frm, "Compiler Options", 10, ui.cbottom(gb) + 20, w = 210, h = 200)
	cb := ui.new_checkbox(frm, "Show Timings", ui.gbx(gb2, 10), ui.gby(gb2, 40))
	cb2 := ui.new_checkbox(frm, "No Entry Point", ui.gbx(gb2, 10), ui.cbottom(cb) + 20)

	rb1 := ui.new_radiobutton(frm, "SubSystem:Windows", ui.gbx(gb2, 10), ui.cbottom(cb2) + 20)
	rb1.foreColor = 0xd90429
	rb2 := ui.new_radiobutton(frm, "SubSystem:Console", ui.gbx(gb2, 10), ui.cbottom(rb1) + 10)

	lbx := ui.new_listbox(frm, ui.cright(gb) + 10, ui.cbottom(b1) + 10)
	ui.listbox_add_items(lbx, "Windows", "MacOS", "Linux", "ReactOS")
	ui.set_property(cb2, ui.CheckBoxProps.Checked, true)

	lv := ui.new_listview(
		frm,
		ui.cright(lbx) + 10,
		ui.cbottom(b3) + 10,
		340,
		150,
		"Windows",
		"MacOS",
		"Linux",
		100,
		120,
		100,
	)
	ui.listview_add_row(lv, "XP", "Mountain Lion", "RedHat")
	ui.listview_add_row(lv, "Vista", "Mavericks", "Mint")
	ui.listview_add_row(lv, "Win7", "Mavericks", "Ubuntu")
	ui.listview_add_row(lv, "Win8", "Catalina", "Debian")
	ui.listview_add_row(lv, "Win10", " Big Sur", "Kali")

	ui.control_add_contextmenu(lv, false, "Compile", "Link Only", "|", "Make Console")
	lv.contextMenu.menus[0].onClick = contextmenu_click // Handler for "Compile" menu
	lv.contextMenu.menus[0].menuState = ui.MenuState.Checked
	// lv.contextMenu._ownDraw = true

	tb := ui.new_textbox(frm, ui.cright(gb2) + 10, ui.cbottom(lbx) + 20)

	pgb = ui.new_progressbar(frm, lv.xpos, ui.cbottom(lv) + 15, lv.width, 30, perc = true)
	tk = ui.new_trackbar(frm, lv.xpos, ui.cbottom(pgb) + 20, 200, 50)
	// tk.customDraw = true
	tk.onValueChanged = track_change_proc

	tv := ui.new_treeview(frm, ui.cright(lv) + 20, dtp.ypos, 250, 220)
	ui.treeview_add_nodes(tv, "Windows", "MacOS", "Linux", "ReactOS")
	ui.treeview_add_childnodes(tv, 0, "XP", "Vista", "Win7", "Win8", "Win10", "Win11")
	ui.treeview_add_childnodes(
		tv,
		1,
		"Mountain Lion",
		"Mavericks",
		"Catalina",
		"Big Sur",
		"Monterey",
	)
	ui.treeview_add_childnodes(tv, 2, "RedHat", "Mint", "Ubuntu", "Debian", "Kali")

	cal := ui.new_calendar(frm, tv.xpos, ui.cbottom(tv) + 20)

	track_change_proc :: proc(c: rawptr, e: ^ui.EventArgs) {
		ui.progressbar_set_value(pgb, tk.value)
	}

	newclient_menuclick :: proc(sender: rawptr, e: ^ui.EventArgs) {
		print("New Client selected")
	}

	contextmenu_click :: proc(sender: rawptr, e: ^ui.EventArgs) {
		// ptf("%s option is selected\n", sender.text)
	}

	open_file_proc :: proc(c: rawptr, e: ^ui.EventArgs) {
		ptf("Open File button clicked: %d", context.user_index)
		idir: string = "D:\\Work\\Shashikumar\\2023\\Jack Ryan"

		ofd := ui.file_open_dialog(initFolder = idir, filterStr = "PDF Files|*.pdf")
		// ofd.multiSel = true
		x := ui.dialog_show(ofd, frm.handle)
		ptf("Dialog result: %s\n", ofd.selectedPath)
		ui.dialog_destroy(ofd)


	}

	b2_click_proc :: proc(c: rawptr, e: ^ui.EventArgs) {
		// ui.timer_start(tmr)
		print("duuuup")
	}

	timer_ontick :: proc(f: rawptr, e: ^ui.EventArgs) {
		print("Timer ticked")
	}

	frmClickProc :: proc(c: ^ui.Control, ea: ^ui.EventArgs) {
		ui.tray_show_balloon(ti, "Winforms", "Info from Winforms", 3000)
	}

	ui.start_mainloop(frm)


}

main :: proc() {
	// BOOL1:: distinct i32
	// v1 : BOOL1 = 1
	// ptf("v1: %32b", v1)
	track: mem.Tracking_Allocator
	// temp_track: mem.Tracking_Allocator

	mem.tracking_allocator_init(&track, context.allocator)
	// mem.tracking_allocator_init(&temp_track, context.temp_allocator)

	context.allocator = mem.tracking_allocator(&track)
	// context.user_index = 225
	// x := 23
	// context.user_ptr = &x
	defer mem.tracking_allocator_destroy(&track)
	MakeWindow()
	ui.show_memory_report(&track)
	// print("===================================================================")
	// ui.show_memory_report(&temp_track)
	// ptf("size of long %d\n", size_of(long))
}

```

## How to use --
1. Download or clone repo.
2. Copy the folder **winforms** and paste it in project folder.
3. Import **winforms** in your main file. Done !!! 👍

## Note
To enable visual styles for your application, you need to use a manifest file.
Here you can see a **app.exe.manifest** file in this repo. You can copy paste it in your project folder. Then rename it. The name must be your exe file's name. Here in my case, my exe file is **app.exe**. So my manifest file's name is **app.exe.manifest**. However, you can use a reource file and put an entry for this manifest file in it. Then you can compile the app with the manifest data embedded into your exe.
