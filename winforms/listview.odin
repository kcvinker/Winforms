
/*
	Created on : 20-Feb-2022 9:00:25 AM
		Name : ListView type
		*/

	package winforms

	//import "core:runtime"

	// Constants

	// Constants End

	ListView :: struct {
		using control : Control,

	}

	new_listview :: proc{lv_ctor1, lv_ctor2}
	@private lv_ctor :: proc(f : ^Form, x, y, w, h : int) -> ListView {
		lv : ListView

		return lv
	}

	@private lv_ctor1 :: proc(f : ^Form) -> ListView {
		lv := lv_ctor(f, 10, 10, 200, 180)
		return lv
	}

	@private lv_ctor2 :: proc(f : ^Form, x, y, w, h : int) -> ListView {
		lv := lv_ctor(f, x, y, w, h)
		return lv
	}



	@private label_wnd_proc :: proc "std" (hw : Hwnd, msg : u32, wp : Wparam, lp : Lparam, 
                                                    sc_id : UintPtr, ref_data : DwordPtr) -> Lresult {
    context = runtime.default_context()
    lv := control_cast(ListView, ref_data)

    	switch msg { 
		}
		return DefSubclassProc(hw, msg, wp, lp)
	}