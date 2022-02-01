
/*
    Created on : 01-Feb-2022 18:44 6:44:54 PM
    Name : MsgBox documentaion.    
*/

// There are 7 overloads for msg_box function. 
// You can pass 'any' value which can convert as a string through 'fmt.tprint()'

msg_box :: proc(msg : string)
msg_box :: proc(msg : string, title : string) 
msg_box :: proc(msg : any) 
msg_box :: proc(msg : any, title : string)

msg_box :: proc(msg : any, 
                title : string, 
                msg_btn : MsgBoxButtons     // See below for more info about MsgBoxButtons.
                ) -> MsgResult              // See below for more info about MsgResult.

msg_box :: proc(msg : any, 
                title : string, 
                msg_btn : MsgBoxButtons, 
                ms_icon : MsgBoxIcons ) -> MsgResult 
msg_box :: proc(msg : any, 
                title : string, 
                msg_btn : MsgBoxButtons, 
                ms_icon : MsgBoxIcons,                  // See below for more info about MsgBoxIcons.
                def_btn : MsgBoxDefButton = .button1    // See below for more info about MsgBoxDefButton.
                ) -> MsgResult

MsgResult :: enum { none, // 0 .. 7
                    okay, 
                    canel, 
                    abort, 
                    retry, 
                    ignore, 
                    yes, 
                    no } 

MsgBoxButtons :: enum { okay,               // Single 'Okay' button
                        ok_cancel,          // Okay & Cancel buttons
                        abort_retry_ignore, // Abort, Retry, Ignore buttons
                        yes_no_cancel,      // Yes, No, Cancel buttons
                        yes_no,             // Yes & No buttons
                        retry_cancel }      // Retry & Cancel buttons

MsgBoxIcons :: enum {   none = 0,           // No Icon
                        hand = 16,          // A hand icon
                        stop = 16,          // A stop icon
                        error = 16,         // An error icon
                        question = 32,      // A question icon
                        exclamation = 48,   // An exclamation icon
                        warning = 48,       // A warning icon
                        asterisk = 64,      // An asterisk icon
                        information = 64, } // An information icon

MsgBoxDefButton :: enum {   button1 = 0,    // First button will be the default button
                            button2 = 256,  // Second button will be the default button
                            button3 = 512}  // Third button will be the default button

