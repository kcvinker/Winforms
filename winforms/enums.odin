
// Created on 23-May-2025 13:59

package winforms

// Type of control
ControlKind :: enum
{
	Form,
	Button,
	Calendar,
	Check_Box,
	Combo_Box,
	Date_Time_Picker,
	Group_Box,
	Label,
	List_Box,
	List_View,
	Number_Picker,
	Panel,
	Progress_Bar,
	Radio_Button,
	Text_Box,
	Track_Bar,
	Tree_View,
}

ButtonStyle :: enum {Default, Flat, Gradient,}
ButtonDrawMode :: enum {Default, Text_Only, Bg_Only, Text_And_Bg, Gradient, Grad_And_Text}

// Enum for setting Calendar's view mode.
ViewMode:: enum {Month, Year, Decade, Centuary}

Alignment:: enum {Left, Right}

DropDownStyle:: enum {Tb_Combo, Lb_Combo,}

//GroupBox enum
GroupBoxStyle :: enum {System, Classic, Overriden}


// Controls like window & button wants to paint themselve with a gradient brush.
// In that cases, we need an option for painting in two directions.
// So this enum will be used in controls which had the ebility to draw a gradient bkgnd.
GradientStyle :: enum {Top_To_Bottom, Left_To_Right,}
TextAlignment :: enum {
	Top_Left, Top_Center, Top_Right, Mid_Left, Center, Mid_Right, 
	Bottom_Left, Bottom_Center, Bottom_Right
}
SimpleTextAlignment :: enum {Left, Center, Right}
TicPosition :: enum {Down_Side, Up_Side, Left_Side, 
						Right_Side, Both_Side
					} // For trackbar


TimeMode :: enum {Nano_Sec, Micro_Sec, Milli_Sec}

Time :: struct {_nano_sec : i64,}


SizeIncrement :: struct {width, height : int,}
Area :: struct {width, height : int,}
WordValue :: enum {Low, High}

WeekDays :: enum {Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday }

// Date time time format for DTP control.
// Possible values: long = 1, short = 2, time = 4, custom = 8
DtpFormat:: enum {Long = 1, Short = 2, Time = 4, Custom = 8}

DialogType :: enum {File_Open, File_Save}

SizedPosition :: enum
{
    Left_Edge = 1,
    Right_Edge,
    Top_Edge,
    Top_Left_Corner,
    Top_Right_Corner,
    Bottom_Edge,
    Bottom_Left_Corner,
    Bottom_Right_Corner,
}

SizedReason :: enum
{ // It is not using now.
    On_Restored,
    On_Minimized,
    On_Maximized,
    Other_Restored,
    Other_Maxmizied,
}

MouseButtons :: enum
{
	None = 0,
    Right = 2097152,
    Middle = 4194304,
    Left = 1048576,
    XButton1 = 8388608,
    XButton2 = 16777216,
}

TreeViewAction :: enum {Unknown, By_Keyboard, By_Mouse, Collapse, Expand,}

KeyState :: enum {Released, Pressed,}

FontWeight :: enum 
{
	Light = 300,
    Normal = 400,
    Medium = 500,
    Semi_Bold = 600,
    Bold = 700,
    Extra_Bold = 800,
    Ultra_Bold = 900,
}


// Drawing mode for Form BKG
FormDrawMode :: enum { Default, Flat_Color, Gradient,}

// Form start position
StartPosition :: enum
{
    Top_Left,
    Top_Mid,
    Top_Right,
    Mid_Left,
    Center,
    Mid_Right,
    Bottom_Left,
    Bottom_Mid,
    Bottom_Right,
    Manual,
}

// Form style
FormStyle :: enum { Default, Fixed_Single, Fixed_3D, Fixed_Dialog, Fixed_Tool, Sizable_Tool, }

// Starting state of Form
FormState :: enum {Normal = 1, Minimized, Maximized}

FindHwnd :: enum {lb_hwnd, tb_hwnd}


ColorOptions :: enum {
    Default_Color,
    Color_4 = 4,
    Color_8 = 8,
    Color_16 = 16,
    Color_24 = 24 ,
    Color32 = 32,
    Color_DDB = 0x000000FE,
}

ImageTypes :: enum {Normal_Image, Small_Image, State_Image}

// Border style for Label.
// Possible values: no_border, single_line, sunken_border
LabelBorder:: enum {No_Border, Single_Line, Sunken_Border, }

LVItemAlignment :: enum {Left, Top}

ListViewStyle:: enum {Large_Icon, Report, Small_Icon, List, Tile, }
ColumnAlignment:: enum {Left, Right, Center,}
HeaderAlignment:: enum {Left, Right, Center,}

MenuType :: enum {Base_Menu, Menu_Item, Popup, Context_Menu, Seprator}
MenuState :: enum u32 {Enabled, Unchecked = 0, Unhilite = 0, Disabled = 3, Checked = 8, Hilite = 128 }
MenuEvents :: enum {On_Click, On_Popup, On_Closeup, On_Focus}

//NumberPicker enums
StepOprator :: enum {Add, Sub}
ButtonAlignment :: enum {Right, Left}

//ProgressBar enums
BarStyle :: enum {Block, Marquee}
BarAlign :: enum {Horizontal, Vertical}
BarTheme :: enum {System_Color, Custom_Color }

//TextBox enums
// Text case for Textbox control.
// Possible values: default, lower_case, upper_case
TextCase:: enum {Default, Lower_Case, Upper_Case}

// Text case for Textbox control.
// Possible values: default, number_only, password_char
TextType:: enum {Default, Number_Only, Password_Char}

// Text alignment for Textbox control.
// Possible values: left, center, right
TbTextAlign:: enum {Left, Center, Right}

//TrackBar enums
// Define drawing style for channel.
ChannelStyle::enum {classic, outline,}

//TrayIcon enums
TrayMenuTrigger :: enum u8 {None, Left_Click, Left_Double_Click = 2, Right_Click = 4, Any_Click = 7}
BalloonIcon :: enum {None, Info, Warning, Error, Custom} 

//TreeView enums
ChildData:: enum {Child_Auto = -2, Child_Callback = -1, Zero = 0, One = 1,}
NodeOp:: enum {Add_Node, Insert_Node, Add_Child, Insert_Child,}




KeyEnum :: enum
{
    Modifier = -65_536,
    None = 0,
    Left_Button, Right_Button, Cancel, Middle_Button, Xbutton1, Xbutton2,
    Back_Space = 8, Tab,
    Clear = 12, Enter,
    Shift = 16, Ctrl, Alt, Pause, Caps_Lock,
    Escape = 27,
    Space = 32, Page_Up, Page_Down, End, Home, Left_Arrow, Up_Arrow, Right_Arrow, Down_Arrow,
    Select, Print, Execute, Print_Screen, Insert, Del, Help,
    D0, D1, D2, D3, D4, D5, D6, D7, D8, D9,
    A = 65,
    B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z,
    Left_Win, Right_Win, Apps,
    Sleep = 95,
    Numpad0, Numpad1, Numpad2, Numpad3, Numpad4, Numpad5, Numpad6, Numpad7, Numpad8, Numpad9,
    Multiply, Add, Seperator, Subtract, Decimal, Divide,
    F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11, F12, F13, F14, F15, F16, F17, F18, F19, F20, F21, F22, F23, F24,
    Num_Lock = 144, Scroll,
    Left_Shift = 160, Right_Shift, Left_Ctrl, Right_Ctrl, Left_Menu, Right_Menu,
    Browser_Back, Browser_Forward, Brower_Refresh, Browser_Stop, Browser_Search, Browser_Favorites, Browser_Home,
    Volume_Mute, Volume_Down, Volume_Up,
    Media_Next_Track, Media_Prev_Track, Media_Stop, Media_Play_Pause, Launch_Mail, Select_Media,
    Launch_App1, Launch_App2,
    Colon = 186, Oem_Plus, Oem_Comma, Oem_Minus, Oem_Period, Oem_Question, Oem_Tilde,
    Oem_Open_Bracket = 219, Oem_Pipe, Oem_Close_Bracket, Oem_Quotes, Oem8,
    Oem_Back_Slash = 226,
    Process = 229,
    Packet = 231,
    Attn = 246, Cr_Sel, Ex_Sel, Erase_Eof, Play, Zoom, No_Name, Pa1, Oem_Clear,  // start from 400
}




CommonProps :: enum{Back_Color, Font, Fore_Color, Enabled, Height, Text, Visible, Width, Xpos, Ypos}
CalendarProps :: enum{Value = int(max(CommonProps)) + 1, View_Mode, Old_View, Show_Week_Num, No_Today_Circle, No_Today, No_Trailing_Dates, Short_Day_Names}
CheckBoxProps :: enum{Checked = int(max(CalendarProps)) + 1, Text_Alignment, Auto_Size}
ComboProps :: enum{Combo_Style = int(max(CheckBoxProps)) + 1, Visible_Item_Count, Selected_Index, Selected_Item}
DTPProps :: enum{Format = int(max(ComboProps)) + 1, Format_String, Right_Align, Four_Digit_Year, Value, Show_Updown}
FormProps :: enum{Start_Pos = int(max(DTPProps)) + 1, Style, Minimize_Box, Window_State}
GroupBoxProps :: enum{Back_Color = int(max(FormProps)) + 1, Font, Height, Text, Width}
LabelProps :: enum{Auto_Size = int(max(GroupBoxProps)) + 1, Border_Style, Text_Alignment, Multi_Line}
ListBoxProps :: enum{ Has_Sort = int(max(LabelProps)) + 1, No_Selection, Multi_Selection, Multi_Column, Key_Preview,
						Selected_Item, Selected_Index, Hot_Index, Hot_Item}
ListViewProps :: enum{ Item_Alignment = int(max(ListBoxProps)) + 1, Column_Alignment, View_Style, Hide_Selection,
						Multi_Selection, Has_Check_Boxes, Full_Row_Select, Show_Grid_Lines, One_Click_Activate,
						No_Track_Select, Edit_Label, No_Header, Header_Back_Color, Header_Height, Header_Clickable}
NumberPickerProps :: enum{ Button_On_Left = int(max(ListViewProps)) + 1, Text_Alignment, Min_Range, Max_Range,
							Has_Separator, Auto_Rotate, Hide_Caret, Value, Format_String, Decimal_Precision,
							Track_Mouse_Leave, Step}
ProgressBarProps :: enum{Min_Value = int(max(NumberPickerProps)) + 1, Max_Value, Step, Style, Orientation,
							Value, Show_Percentage}
RadioButtonProps :: enum{Text_Alignment = int(max(ProgressBarProps)) + 1, Checked, Check_On_Click, Auto_Size}
TextBoxProps :: enum{Text_Alignment = int(max(RadioButtonProps)) + 1, Multi_Line, Text_Type, Text_Case,
						Hide_Selection, Read_Only, Cue_Banner}
TrackBarProps :: enum {Tic_Pos = int(max(TextBoxProps)) + 1, No_Tick, Channel_Color, Tic_Color, Tic_Width,
						Min_Range, Frequency, Page_S_Ize, Line_Size, Tic_Length, Default_Tics, Value,
						Vertical, Reversed, Sel_Range, No_Thumb, Tool_Tip, Custom_Draw, Free_Move,
						Sel_Color, Channel_Style }
TreeViewProps :: enum{No_Lines = int(max(TrackBarProps)) + 1, No_Buttons, Has_Check_Boxes, Full_Row_Select,
						Editable, Show_Selection, Hot_Tracking, Selected_Node, Image_List, Line_Color }