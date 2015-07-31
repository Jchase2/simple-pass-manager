# simple-pass-manager
Simple shell gpg password manager. 

## Features

* Never stores passwords unencrypted on drive.
  Uses tmpfs's on the system or if one isn't found, 
  creates one. 
* Shell completion.
* Display sections or individual username:password lines. 

## Recommended use. 

This is recommended for single user systems, as a multi-user
system may allow another user to read a temporarily file in
a shared tmpfs directory. It *could* be safely used on a multi-user
system, but at present that requires root and you'd have to remove 
the checks for /tmp and /dev/shm first. This problem maybe solved
in the future, or maybe I'll rewrite it in C some-time to solve this, 
but for now as a shell sript these are limitations that we seem to be
stuck with given the requirement of never storing passwords on the disk.

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

* Automatic encrypted pw file backup.
* Create encrypted file w/ standardized format. (maybe) 
* Add passwords to sections
* Remove passwords from sections
* Add sections
* Remove sections

