# simple-pass-manager
Simple shell gpg password manager. 

## Features

* Never stores passwords unencrypted on drive.
* Shell completion.
* Display sections or individual username:password lines. 

##How to: 

Create a password file with sections identified by headers. 
For example: 

=== Email ==

email:pass

=== END ===

When you run the script, it will ask you to specify the gpg file
of the script, then invoke gpg to decrypt it. After that, it will prompt 
you to check weather you want to search for a specific line to print, or
a section. If you select 's' for a single line, you type the first name
in the line, for example "email", and it'll print the whole line. If you
select 'h' for header, then it will print the entire section. 

The end of a section should be delimited with END. You can edit the script to
change the end delimiter. 

## Planned Changes

I'll probably keep adding features to this as time goes on. Any pull requests
are welcomed. Planned features: 

* Create encrypted file w/ standardized format. (maybe) 
* Add passwords to sections
* Remove passwords from sections
* Add sections
* Remove sections

