# simple-pass-manager
Simple shell gpg password manager. 

##How to: 

Basically, you just create a gpg encrypted file with sections. 
For example, if you wanted a section of "Forum Passwords", 
just do something like this: 

====Forum Passwords=====

When you run the script, it will ask you to specify the gpg file
of the script, ask for the password, decrypt it, prompt for a 
header to search for, output everything after ====Forum Passwords====
but before "END", and output it. 

So put all your passwords inbetween blocks of whatever header you want, 
and wil remember to search for, and the END keyword. You can easily read
the code and modify it to use a different end keyword or symbols or w/e. 

## Planned Changes
I'll probably keep adding features to this as time goes on. Any pull requests
are welcomed. Planned features: 

* Create an encrypted file. 
* Support for username:password delimited single line output from file. 
* Adding and removing passwords to sections. 
