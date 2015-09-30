#!/bin/bash

#Copyright (C) 2015 JChase2
#This code is free software; you can redistribute it and/or
#modify it under the terms of the GNU Library General Public
#License as published by the Free Software Foundation; either
#version 2 of the License, or (at your option) any later version.

#This library is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#Library General Public License for more details.

# Variables invokation and description.

GLOBV="" #Stores initial user input.
SGLOBV="" #Choice of header or string for search function.
ENDVAR="END" #End of block delimiter.
USEKEY="" # Name of private key to encrypt with.
CHKSTR="" #Check if string exists for use in other functions.

#Read in filename of GPG file.

gpg_function(){
  check_mem
  echo "Use tab to search / for completion"
  echo -n "GPG Encrypted Password File Path: "
  read -e pwfile
  PVAR=$(gpg --decrypt $pwfile)
  echo $'\n'
  welcome_function
}

# Creates a backup directory and creates
# a backup upon pw file change.

backup_function(){
  if [ ! -d pwbackup ] ; then
    mkdir pwbackup
  fi
  cp -a -- "$pwfile" "pwbackup/$pwfile-$(date +"%Y%m%d-%H%M%S")"
  if [ $? -gt 0 ]; then # If cp exits with non-zero return.
    echo "Backup Failed."
  else
    echo "Successful Backup."
  fi
}

#welcome function
welcome_function(){
   echo 'Welcome to simple-password-manager.'
   echo 'Type 'o' to open an existing encrypted pw file.'
   echo 'Type 'r' to read the entire file.'
   echo 'Type 's' to search for a string.'
   echo 'Type 'h' to search for a section.'
   echo 'Type 'i' to insert new information (e.g a username:password combo.)'
   echo 'Type 'n' to enter a new section.'
   echo 'Type 'd' to delete a section and its contents.'
   echo 'Type 'f' to create and open a new encrypted pw file.'
   echo 'Type 'q' to quit.'
   read -r -p "Command: " GLOBV
   input_function
}

again(){
   echo -n 'Search Again? (y/n): '
   read searchagain
   if [[ $searchagain =~ [yY](es)* ]]  ; then
      echo 'Type 's' to search for a string.'
      echo 'Type 'h' to search for a header.'
      read -r -p "Command: " GLOBV
      input_function
   else
      welcome_function
   fi
}


input_function(){
   USRINPUT="$GLOBV"
   if [[ $USRINPUT  =~ ^([sS])$ ]] ; then
      SGLOBV=0
      search_function
   elif [[ $USRINPUT =~ ^([hH])$ ]] ; then
      SGLOBV=1
      search_function
   elif [[ $USRINPUT =~ ^([iI])$ ]] ; then
      new_pw
   elif [[ $USRINPUT =~ ^([oO])$ ]] ; then
      gpg_function
   elif [[ $USRINPUT =~ ^([fF])$ ]] ; then
      new_file
   elif [[ $USRINPUT =~ ^([nN])$ ]] ; then
      add_section
   elif [[ $USRINPUT =~ ^([rR])$ ]] ; then
      read_file
   elif [[ $USRINPUT =~ ^([dD])$ ]] ; then
      remove_section
   elif [[ $USRINPUT =~ ^([qQ])$ ]] ; then
      unset PVAR
      exit
   else
      echo 'Bad input, try again.'
      welcome_function
   fi
}

# Check if string exists in pwfile.
string_exists(){
   pattern=$1
   if [[ "$PVAR" == *${pattern}* ]]; then
      CHKVAR=0
   else
      CHKVAR=1
   fi
}

search_function() {
   tmpresult="$SGLOBV"

   if [ $tmpresult -eq '1' ] ; then
	   echo -n 'Type header name to search for: '
           read VAR
           string_exists "$VAR"
           echo $'\n'
           AVAR=$(sed -n "/$VAR/,/$ENDVAR/p" <<< "$PVAR")
           echo "$AVAR"
           again
   elif [ $tmpresult -eq '0' ] ; then
           echo -n 'Type username to search for: '
           read VVAR
           string_exists "$VVAR"
           echo $'\n'
           NVAR=$(sed -n "/$VVAR/p" <<< "$PVAR")
           echo "$NVAR"
           again
   else
     echo "This shouldn't happen."
     welcome_function
   fi
}

check_mem(){
   cat /proc/meminfo >> meminfodne.txt
   AVAR=$(sed -n "/MemFree:/p" meminfodne.txt)
   AVAR=$(tr -d -c 0-9 <<< $AVAR)
   rm meminfodne.txt
   if [ "$AVAR" -lt 100000 ] ; then
     echo "You have less than 100mb of ram left. Having a low amount of free ram may"
     echo -n "cause data to overflow into swap on the drive. Would you like to continue? y/n: "
       read YN
     if [[ $YN =~ [yY](es)* ]]  ; then
        echo "Continuing anyway."
     else
       exit
     fi
   else
      echo "Memory ok."
   fi
}

new_pw(){
   echo -n 'Enter section to insert information into: '
      read VAR
   string_exists "$VAR"
   if [ $CHKVAR -eq 1 ]; then
      echo $'\n'
      echo "Unable to find section."
      echo $'\n'
      welcome_function
   fi
   backup_function
   echo -n 'Enter string to insert: '
      read NEWPW

   # This reads in the whole file, IFS= disables delimiting by spaces.
   # This preserves leading and trailing whitespaces for formatting purposes.
   # -r allows us to get new lines intead of a single really long line.
   # Everything is pushed into AVAR, after grep does its thing.
   AVAR=$(while IFS= read -r line; do
           echo $line
           echo $line | grep -q "$VAR"
           [ $? -eq 0 ] && echo -e "$NEWPW"
         done <<< "$PVAR")

   PVAR="$AVAR"
   get_key
   echo "$PVAR" | gpg -o "$pwfile" --encrypt --recipient "$USEKEY"
   welcome_function
}


new_file(){
   echo -n "Enter file name: "
   read pwfile
   get_key
   echo "---simple-pass-manager file---" | gpg -o "$pwfile" --encrypt --recipient "$USEKEY"
   PVAR=$(gpg --decrypt $pwfile)
   echo $'\n'
   welcome_function
}

read_file(){
  echo -e "$PVAR" | less 
  welcome_function
}

get_key(){
   echo 'List of your secret Keys: '
   gpg --list-secret-keys
   echo $'\n'
   echo -n 'Type in user ID (name) of key to use from list above: '
   read USEKEY
}

add_section(){
   echo -n "Enter Section Name: "
      read USRSEC
   string_exists "$USRSEC"
   if [ $CHKVAR -eq 0 ]; then
      echo $'\n'
      echo "Section or PW with this name already exists."
      echo -n "Continue anyway? y/n: "
      read ANLVAR
      if [[ $ANLVAR =~ [yY](es)* ]]  ; then
         echo "Continuing Anyway"
      else
         welcome_function
      fi
   fi
   backup_function
   PVAR+=$'\n'
   PVAR+="==== "$USRSEC" ===="
   PVAR+=$'\n'
   PVAR+="==== "$ENDVAR" ===="
   get_key
   echo "$PVAR" | gpg -o "$pwfile" --encrypt --recipient "$USEKEY"
   welcome_function
}

remove_section(){
  echo -n 'Type header of section to remove: '
  read VAR
  string_exists "$VAR"
  echo $'\n'
  backup_function
  PVAR=$(sed "/==== $VAR ====/,/$ENDVAR/d" <<< "$PVAR")
  get_key
  echo "$PVAR" | gpg -o "$pwfile" --encrypt --recipient "$USEKEY"
  welcome_function
}

welcome_function

