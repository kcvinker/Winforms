
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
                def_btn : MsgBoxDefButton = .Button1    // See below for more info about MsgBoxDefButton.
                ) -> MsgResult

MsgResult :: enum { None, // 0 .. 7
                    Okay, 
                    Canel, 
                    Abort, 
                    Retry, 
                    Ignore, 
                    Yes, 
                    No } 

MsgBoxButtons :: enum { Okay,               // Single 'Okay' button
                        Ok_Cancel,          // Okay & Cancel buttons
                        Abort_Retry_Ignore, // Abort, Retry, Ignore buttons
                        Yes_No_Cancel,      // Yes, No, Cancel buttons
                        Yes_No,             // Yes & No buttons
                        Retry_Cancel }      // Retry & Cancel buttons

MsgBoxIcons :: enum {   None = 0,           // No Icon
                        Hand = 16,          // A hand icon
                        Stop = 16,          // A stop icon
                        Error = 16,         // An error icon
                        Question = 32,      // A question icon
                        Exclamation = 48,   // An exclamation icon
                        Warning = 48,       // A warning icon
                        Asterisk = 64,      // An asterisk icon
                        Information = 64, } // An information icon

MsgBoxDefButton :: enum {   Button1 = 0,    // First button will be the default button
                            Button2 = 256,  // Second button will be the default button
                            Button3 = 512}  // Third button will be the default button

