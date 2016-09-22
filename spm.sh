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
CHKVAR="" #Check if string exists for use in other functions.

# Check if GPG is installed. 

type gpg >/dev/null 2>&1 || { echo $'\n' >&2 "GPG does not appear to be installed, exiting." $'\n'; exit 1; }


#Read in filename of GPG file.

gpg_function(){
  check_mem
  echo "Use tab to search / for completion"
  echo -n "GPG Encrypted Password File Path: "
  read -e pwfile
  PVAR=$(gpg --decrypt $pwfile)
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
   echo $'\n'
   echo 'Welcome to simple-password-manager.'
   echo 'Type '?' or 'help' to print options.'
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
   elif [[ $USRINPUT =~ ^([bB])$ ]] ; then
      insert_block
   elif [[ $USRINPUT =~ ^([kK])$ ]] ; then
      remove_string
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
   elif [[ $USRINPUT =~ ^([?])$ ]] || [[ $USRINPUT == "help" ]]  ; then
      print_options
   elif [[ $USRINPUT =~ ^([qQ])$ ]] ; then
      unset PVAR
      exit
   else
      echo 'Bad input, try again.'
      welcome_function
   fi
}



print_options(){
   echo $'\n'
   echo 'Type 'o' to open a password file.'
   echo 'Type 'r' to read the entire file.'
   echo 'Type 's' to search for a string.'
   echo 'Type 'h' to search for a section.'
   echo 'Type 'i' to insert a single new line. (e.g a username:password combo.)'
   echo 'Type 'b' to insert multiple lines at a time.'
   echo 'Type 'n' to create a new section.'
   echo 'Type 'd' to delete a section and its contents.'
   echo 'Type 'k' to delete a string from a section.'
   echo 'Type 'f' to create and open a new encrypted pw file.'
   echo 'Type 'q' to quit.'
   welcome_function
}


# Check if string exists in pwfile.
string_exists(){
   pattern=$1
   if [[ "$PVAR" == *${pattern}* ]]; then
      CHKVAR=0 #Exists...
   else
      CHKVAR=1
   fi
}

#Check if gpg file is opened, go to welcome if no.
file_opened(){

   if [ -z "$PVAR" ]; then
           echo $'\n'
           echo 'No password file has been opened, type "o"'
           welcome_function
   fi
}

search_function() {
   tmpresult="$SGLOBV"
   file_opened

   if [ $tmpresult -eq '1' ] ; then
	   echo -n 'Type header name to search for: '
           read VAR
           string_exists "==== $VAR ===="
           echo $'\n'
           if [ $CHKVAR -eq 0 ]; then
              AVAR=$(sed -n "/==== $VAR ====/,/$ENDVAR/p" <<< "$PVAR")
              echo "$AVAR"
              again
           else
	      echo 'Header does not exist.'
              again
           fi
   elif [ $tmpresult -eq '0' ] ; then
           echo -n 'Type username to search for: '
           read VVAR
           string_exists "$VVAR"
           if [ $CHKVAR -eq 0 ]; then
              echo $'\n'
              NVAR=$(sed -n "/$VVAR/p" <<< "$PVAR")
              echo "$NVAR"
              again
           else
              echo 'String does not exist.'
              again
           fi
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

   file_opened
   echo -n 'Enter section to insert information into: '
      read VAR
   string_exists "==== $VAR ===="
   if [ $CHKVAR -eq 1 ]; then
      echo $'\n'
      echo "Section does not exist."
      welcome_function
   fi
   backup_function
   echo -n 'Enter string to insert: '
      read NEWPW
   string_exists "$NEWPW"
   if [ $CHKVAR -eq 0 ]; then
      echo $'\n'
      echo "String with this name already exists somewhere in the file..."
      echo -n "Continue anyway? y/n: "
      read ANLVAR
      if [[ $ANLVAR =~ [yY](es)* ]]  ; then
        string_exists "==== $NEWPW ===="
        if [ $CHKVAR -eq 0 ]; then
            echo $'\n'
            echo 'ERROR: PW is the same as a header name. This can'
            echo 'create conflicts where removing a pw removes' 
            echo 'a header name... Operation not complete.'
            welcome_function
        fi
         echo "Continuing Anyway"
      else
         welcome_function
      fi
   fi
   # This reads in the whole file, IFS= disables delimiting by spaces.
   # This preserves leading and trailing whitespaces for formatting purposes.
   # -r allows us to get new lines intead of a single really long line.
   # Everything is pushed into AVAR, after grep does its thing.
   AVAR=$(while IFS= read -r line; do
           echo $line
           echo $line | grep -qx "==== $VAR ===="
           [ $? -eq 0 ] && echo -e "$NEWPW"
         done <<< "$PVAR")

   PVAR="$AVAR"
   get_key
   echo "$PVAR" | gpg -o "$pwfile" --encrypt --recipient "$USEKEY"
   welcome_function
}

insert_block(){

  file_opened
  ABLOCK=""
  BBLOCK=""
  CHECKRESULTS=""
  LINECOUNT=0
  SAVERESULT=""
  echo $'\n'
  echo 'Insert data one line at a time, type "quit" and press enter to stop.'
  echo $'\n'
  while [ "$ABLOCK" != "quit" ]; do
    LINECOUNT=$((LINECOUNT+1))
    echo -n "Line "$LINECOUNT": "
    read -e ABLOCK
    if [ "$ABLOCK" != "quit" ]; then
      BBLOCK+=$'\n'$ABLOCK
    fi 
  done
  echo -n "Would you like to review input?: "
  read CHECKRESULTS
  if [[ "$CHECKRESULTS" =~ [yY](es)* ]]; then
    echo "$BBLOCK" | less
    echo -n "Save changes?: "
    read SAVERESULT
    if [[ "$SAVERESULT" =~ [yY](es)* ]]; then
      PVAR+=$'\n'$BBLOCK
      welcome_function
    fi
  fi
  PVAR+=$'\n'$BBLOCK
  welcome_function 
}

new_file(){
   echo -n "Enter file name: "
   read pwfile
   get_key
   echo "---simple-pass-manager file---" | gpg -o "$pwfile" --encrypt --recipient "$USEKEY"
   PVAR=$(gpg --decrypt $pwfile)
   welcome_function
}

read_file(){
  file_opened
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
   file_opened
   echo -n "Enter Section Name: "
      read USRSEC

   string_exists "==== $USRSEC ===="

   # Not allowing creation of duplicate headers because deleting
   # one will automatically delete the other...
   if [ $CHKVAR -eq 0 ]; then
      echo $'\n'
      echo "A section with this name already exists."
      welcome_function
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
  file_opened
  echo -n 'Type header of section to remove: '
  read VAR
  string_exists "==== $VAR ===="
  if [ $CHKVAR -eq 0 ]; then
     echo $'\n'
     backup_function
     PVAR=$(sed "/==== $VAR ====/,/$ENDVAR/d" <<< "$PVAR")
     get_key
     echo "$PVAR" | gpg -o "$pwfile" --encrypt --recipient "$USEKEY"
     welcome_function
  else
     echo $'\n'
     echo "Section not found."
     welcome_function
  fi
}

remove_string(){
 file_opened
 echo -n 'Type name of string to remove: '
  read VAR
  string_exists "$VAR"
  if [ $CHKVAR -eq 0 ]; then
     echo $'\n'
     backup_function
     PVAR=$(sed -e  "s/\<$VAR\>//g" <<< "$PVAR")
     get_key
     echo "$PVAR" | gpg -o "$pwfile" --encrypt --recipient "$USEKEY"
     welcome_function
  else
     echo $'\n'
     echo "String not found."
     welcome_function
  fi
}

welcome_function

