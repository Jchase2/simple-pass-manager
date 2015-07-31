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

#Exit or retry dialog.
again() {
   echo -n 'Search Again? (y/n): '
   read searchagain
   if [[ $searchagain =~ [yY](es)* ]]  ; then
       search_function
   else
       rm $txtpath
       if [ -d "$dnetmpfs" ]; then
          umount dnetmpfs && rm -R dnetmpfs
       fi
      exit
   fi
}


#Searching
search_function() {
   echo -n 'Press 'h' to search for a header, 's' to output a password line: (s/h): '
   read search
   if [[ $search =~ ^([hH])$ ]] ; then
	   echo -n 'Type header name to search for: '
           read VAR
           sed -n "/$VAR/,/END/p" $txtpath
	   again
   elif [[ $search =~ ^([sS])$ ]] ; then
	   echo -n 'Type username to search for: '
           read VVAR
           sed -n "/^$VVAR/p" $txtpath
           again
   else
     echo 'Try again plz.'
     search_function
   fi
}

#Check ram usage.
check_ram(){
   cat /proc/meminfo >> meminfodne.txt 
   AVAR=$(sed -n "/MemFree:/p" meminfodne.txt)
   AVAR=$(tr -d -c 0-9 <<< $AVAR)
   rm meminfodne.txt
   echo "$AVAR"
}

#Check /tmp to see if it's a tmpfs
check_tmp(){
   line=$(df -T /tmp)
   line=$(sed -n '/tmpfs/p' <<< $line)
   if [ -z "$line" ] ; then
      local result='0'
      echo "$result"
   else
      result='1'
      echo "$result"
   fi 
}

#Check /dev/shm to see if it's a tmpfs
check_shm(){
   line=$(df -T /dev/shm)
   line=$(sed -n '/tmpfs/p' <<< $line)
   if [ -z "$line" ] ; then 
      local aresult='0' 
      echo "$aresult"
   else 
      local aresult='1' 
      echo "$aresult"
   fi 
}

#Read in filename of GPG file.
echo -n "GPG Encrypted Password File Name: "
read -e pwfile

#Check ram usage to make sure there's plenty so we do not spill into swap on drive. 
memresult=$( check_ram )
if [ $memresult -le 50000 ] ; then
   echo "Not enough memory, might overflow into disk via swap."
   exit
else
   echo "Memory test passed."
fi

#Look for tmpfs, if none create one.
tmpresult=$( check_tmp )
if [ $tmpresult -eq 0 ] ; then
   echo "/tmp is not a tmpfs, checking /dev/shm"
   shmresult=$( check_shm )
   if [ $shmresult -eq 0 ] ; then
      echo "No tmpfs found, creating temporary tmpfs."
      mkdir dnetmpfs
      mount -t tmpfs -o size=10m tmpfs dnetmpfs
      txtpath='dnetmpfs/temp_file.txt'
   else
      txtpath='/dev/shm/temp_file.txt'
   fi
else
   txtpath='/tmp/temp_file.txt'
fi
gpg --output $txtpath --decrypt "$pwfile"
search_function

