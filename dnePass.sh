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
   echo -n 'Press 's' to searc: '
   read search
   sed -n "/$search/,/END/p" temp_pass.txt
   again
}

echo -n "GPG Encrypted Password File Name: "
read -e pwfile
gpg --output temp_pass.txt --decrypt "$pwfile"
search_function

