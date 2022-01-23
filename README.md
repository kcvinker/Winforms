# Winforms
A simple GUI library for Odin programming language.

It is built upon win api functions. So it needs Windows 64 bit to run.
Currently, it's a work in progress project.

## Control List
1. Form
2. Button
3. Calendar
4. CheckBox
5. ComboBox
6. DateTimePicker
7. GroupBox
8. Label
9. ListBox
10. TextBox

## Screenshot

![image](https://user-images.githubusercontent.com/8840907/150694385-a5b824ab-7df2-4714-9e4f-11a604b5a7df.png)

## Example --

```rust
import ui "winforms"
frm : ui.Form
main :: proc() {
    using ui
    frm = new_form("My New Odin Form") 
    frm.mouse_click = form_click
    create_form(&frm)

    // You can create other controls here.

    start_form() // From now, you can see the form is up & running.
}

form_click :: proc(sender : ^ui.Control, ea : ^ui.EventArgs) {
    ui.msg_box("Hi, I am from winforms !") 
}
```

## How to use --
1. Download or clone repo.
2. Copy the folder **winforms** and paste it in project's root folder.
3. Import **winforms** in your main file. Done !!! 👍
