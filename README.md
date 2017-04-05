# simple-pass-manager
Simple shell gpg password manager. 
[A DnE MbN project.](http://mbn.darknedgy.net/DnE_Labs/simple-pass-manager)

## Features

* Wrapper for managing passwords via GPG.
* Never stores unecrypted data on drive.
* Handles gpg file creation. 
* Allows user to organize passwords / info by section.  
* Allows user to add and remove lines (single or multiple).  
* Allows user to search for sections or individual lines. 
* Allows user to read entire contents of the "file". 

##Requirements

This script relies on GPG and was written and tested using BASH.
You should also have an existing GPG key. 
It may work on other shells, although I haven't tested this much. 

## How To:

When you launch it, you get a prompt. Type "help" or "?" to get a list of commands.
Just type the letter of whatever function you want to use. First you either
have to open an existing encrypted pw file by typing 'o', or create a new 
encrypted pw file by typing 'f'. You'll need an existing GPG key set up for this. 

Then you should add a section or sections to put pw strings between... I recommend 
formatting your username and passwords like this: 

>username:password

For additional information, like reset questions and answers, you have two options. First,
you could use really long strings like this: 

>username:password:aQuestion:answer:question2:answer2:pincode:4857489393:whatever:whatever

Which works fine. A less ugly way to do it, however, is to just insert a block of lines 
(type b or B), each beginning with the same thing, like this:  

> email:username:pass

> email:securityquestion:answer

> email:pincode:pw

When you search for a string, if you just type "email" in this example, all instances 
of email will be printed. This is generally easier to read, but it really comes down to 
personal preference. 

Here's the menu:

```
Type 'o' to open a password file.
Type 'r' to read the entire file.
Type 's' to search for a string.
Type 'h' to search for a section.
Type 'l' to list all sections / headers.
Type 'i' to insert a single new line. (e.g a username:password combo.)
Type 'b' to insert multiple lines at a time.
Type 'n' to create a new section.
Type 'd' to delete a section and its contents.
Type 'k' to delete a string from a section.
Type 'f' to create and open a new encrypted pw file.
Type 'q' to quit.
```

## How it works.

It's basically just a wrapper around GPG with functionality to search for, 
add, and remove information in various ways.

Sections and passwords are stored like this: 

```
==== Email ====
username:password
==== END ====
```

The "END" section marks the end of a given section, and the title marks the beginning. 
When you search for a section, it will output from the title delimiter to 
"END". The first delimiter, "EMAIL" in this example, is read in by the user when 
a new section is created. If you manually edit a PW file, make sure you use 4 
equal signs and a space between delimiters, otherwise you'll run into bugs using
this script.  

You can also search for the string "email" and it'll output any lines beginning with "email": 
>email:pass

Everything is stored in local non-exported shell variables, and thus never touches
the file-system until it is streamed into a gpg encrypted file. At least, based on
everything I've read, and assuming standard unix/linux tools like sed don't do anything
stupid like write to disk... I doubt non-exported variables ever randomly get pushed into
swap while there's enough ram. (The script makes sure there's at least 100MB of free ram.)

## Planned Changes

I'll probably keep adding features to this as time goes on. Any pull requests
are welcomed. 

* Rewrite insert function to be slightly more structured for delimiting. (Potentially?) 
* Improve sorting based on delimiters for lines. (Potentially?) 
* Improve header searching by allowing user to list headers during search dialogue.  
* Test on other shells. 
* GPG key creation (maybe). 
* Make user input section when removing a line, only remove from that section. 
* Only prompt to overwrite encrypted file when specified, exiting, or opening a new file. 
* Build in a password generator. 
