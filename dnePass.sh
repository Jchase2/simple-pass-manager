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
       rm $txtpath
       if [ -d "$dneramfs" ]; then
          echo 'One more sudo to remove the ramfs.'
          sudo umount dneramfs && rm -R dneramfs
       fi
      exit
   fi
}


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

echo -n "GPG Encrypted Password File Name: "
read -e pwfile
tmpresult=$( check_tmp )
if [ $tmpresult -eq 0 ] ; then
   echo "/tmp is not a tmpfs, checking /dev/shm"
   shmresult=$( check_shm )
   if [ $shmresult -eq 0 ] ; then
      echo 'No tmpfs found on your system. We need to create one using root.'
      mkdir dneramfs
      sudo mount -t ramfs -o size=10m ramfs dneramfs
      txtpath='dneramfs/temp_file.txt'
   else
      txtpath='/dev/shm/temp_file.txt'
   fi
else
   txtpath='/tmp/temp_file.txt'
fi
gpg --output $txtpath --decrypt "$pwfile"
search_function

