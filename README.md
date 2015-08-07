# simple-pass-manager
Simple shell gpg password manager. 

## Features

* Never stores unecrypted data on drive.
* Handles gpg file creation. 
* Allows uer to add new password sections. 
* Allows user to search for sections or individual lines. 
* Allows user to read entire contents of the "file". 

##Requirements

This script relies on GPG and was written and tested using BASH.
In the future I'll likely try to make it POSIX compatible so it
will work with more shells. It also assumes you have an already
existing key, although we may handle key creation in the future. 


## How To:

When you launch it, it presents you with a simple self-explanatory menu.

```
Welcome to simple-password-manager.
Type 'o' to open an existing encrypted pw file.
Type 'r' to read the entire file.
Type 's' to search for a string.
Type 'h' to search for a section.
Type 'n' to enter a new section.
Type 'f' to create and open a new encrypted pw file.
Type 'q' to quit.
```
When you use 'f' it just creates a new gpg file and you can move on to 
adding sections or passwords with the other options. 
 

## How it works.

File sections and passwords are stored like this: 

=== Email ==

email:pass

=== END ===

The "END" section marks the end of a given section, and the name "EMAIL" marks
the beginning. When you search for a section, it will output from "EMAIL" to 
"END". You can easily change the END delimiter by editing the script. The first
delimiter, "EMAIL" in this example, is read in by the user when a new section is
created. 

You can also search for the string "email" and it'll output the whole line: 
>email:pass

Everything is stored in local non-exported shell variables, and thus never touches
the file-system, until it is streamed into a gpg encrypted file. 


## Planned Changes

I'll probably keep adding features to this as time goes on. Any pull requests
are welcomed. Planned features: 

* Add passwords to sections
* Remove passwords from sections
* Remove sections
* Make it POSIX compatible. 
