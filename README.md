# simple-pass-manager
Simple shell gpg password manager. 

## Features

* Never stores unecrypted data on drive.
* Handles gpg file creation. 
* Allows user to add and remove sections. 
* Allows user to add data between sections. 
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
Type o to open an existing encrypted pw file.
Type r to read the entire file.
Type s to search for a string.
Type h to search for a section.
Type i to insert new information (e.g a username:password combo.)
Type n to enter a new section.
Type d to delete a section and its contents.
Type f to create and open a new encrypted pw file.
Type q to quit.
Command:
```
When you use 'f' it just creates a new gpg file and you can move on to 
adding sections or passwords with the other options. 
 

## How it works.

File sections and passwords are stored like this: 

```
==== Email ====

email:pass

==== END ====
```

The "END" section marks the end of a given section, and the name "EMAIL" marks
the beginning. When you search for a section, it will output from "EMAIL" to 
"END". You can easily change the END delimiter by editing the script. The first
delimiter, "EMAIL" in this example, is read in by the user when a new section is
created. Unless you want to edit the script even more, using 4 equals signs around
the beginning delimiter is required. E.g. ==== Email ====. This provides for some
searching functionality, deleting functionality, etc, while also avoiding conflicts. 

You can also search for the string "email" and it'll output the whole line: 
>email:pass

Everything is stored in local non-exported shell variables, and thus never touches
the file-system, until it is streamed into a gpg encrypted file. At least, based on
everything I've read, and assuming standard unix/linux tools like sed don't do anything
stupid like write to disk...

Note: If you have more than one section with the same name, and delete a section with that
name, both will be deleted. For now.


## Planned Changes

I'll probably keep adding features to this as time goes on. Any pull requests
are welcomed. Planned features: 

* Include editing the whole file.
* Remove passwords from sections
* Make it POSIX compatible. 
* Warn before deleting more than one section with the same name.
