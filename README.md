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

![image](https://user-images.githubusercontent.com/8840907/151600029-5207b2e9-cdd0-4bdd-a0a8-a596c31f1ad4.png)



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
2. Copy the folder **winforms** and paste it in project folder.
3. Import **winforms** in your main file. Done !!! 👍

## Note
To enable visual styles for your application, you need to use a manifest file.
Here you can see a **app.exe.manifest** file in this repo. You can copy poste it in your project folder. Then rename it. The name must be your exe file's name. Here in my case, my exe file is **app.exe**. So my manifest file's name is **app.exe.manifest**. However, you can use a reource file and put an entry for this manifest file in it. Then you can compile the app with the manifest data embedded into your exe. 
