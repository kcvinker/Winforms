/*
ProgressBar doumentation
Created on : 25-May-22 12:49:28 PM
*/



ProgressBar :: struct {
    using control : Control,		// Inheriting from Control
    min_value,						// Minimum value
    max_value : int,				// Maximum value
    step : int,						// step value to increment
    style : BarStyle,				// enum {Block, Marquee}
    orientation : BarAlign,			// enum {Horizontal, Vertical}
    value : int,					// value of ProgressBar
    speed : i32,                    // Speed of marquee animation. Default is 30 (Updated in each 30 milliseconds)
    show_percentage: bool,          // Show a percentage value upon progress bar
    state: ProgressBarState         // Not implemented
}

// Enums
BarStyle :: enum {Block, Marquee}
BarAlign :: enum {Horizontal, Vertical}


// Constructor
new_progressbar :: proc(parent : ^Form) -> ProgressBar
new_progressbar :: proc(parent : ^Form, x, y, w, h : int) -> ProgressBar

// Functions
create_control :: proc(c : ^Control) // To create a ProgressBar

// Increment progress bar value one step. You need to set the step value
progressbar_increment :: proc(pb : ^ProgressBar)

// Start marquee animation in progress bar.
progressbar_start_marquee :: proc(pb : ^ProgressBar, speed : int = 30)

// Pause marquee animation in progress bar
progressbar_pause_marquee :: proc(pb : ^ProgressBar)

// Restart marquee animation in a paused progress bar
progressbar_restart_marquee :: proc(pb : ^ProgressBar)

// Stop marquee animation in progress bar.
progressbar_stop_marquee :: proc(pb : ^ProgressBar)

// Change the style of progress bar.
// Default style is BarSTyle.Block.
progressbar_change_style :: proc(pb : ^ProgressBar, style: BarStyle)

// Set the value for progress bar. Only applicable for block styles
progressbar_set_value :: proc(pb : ^ProgressBar, ival : int)

// Example - (This code assumes that frm is already declared)
pgb := new_progressbar(&frm, 50, 50, 200, 25) // Create new progress bar struct
pgb.step = 5 // Set the step as 5.
create_control(&pgb) // create the progress bar handle.
