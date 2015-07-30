#!/bin/sh

#Copyright (C) 2015 JChase2
#This code is free software; you can redistribute it and/or
#modify it under the terms of the GNU Library General Public
#License as published by the Free Software Foundation; either
#version 2 of the License, or (at your option) any later version.

#This library is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#Library General Public License for more details.

again() {
   echo -n 'Search Again? (y/n): '
   read searchagain
   if [[ $searchagain =~ [yY](es)* ]]  ; then
       search_function
   else
       rm temp_pass.txt
       exit
   fi
}


search_function() {
   echo -n 'Press 'h' to search for a header, 's' to output a password line: (s/h): '
   read search
   if [[ $search =~ ^([hH])$ ]] ; then
	   echo -n 'Type header name to search for: '
           read VAR
           sed -n "/$VAR/,/END/p" temp_pass.txt
	   again
   elif [[ $search =~ ^([sS])$ ]] ; then
	   echo -n 'Type username to search for: '
           read VVAR
           sed -n "/^$VVAR/p" temp_pass.txt
           again
   else
     echo 'Try again plz.'
     search_function
   fi
}

echo -n "GPG Encrypted Password File Name: "
read -e pwfile
gpg --output temp_pass.txt --decrypt "$pwfile"
search_function

