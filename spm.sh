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

#Read in filename of GPG file.

GLOBV=""
SGLOBV=""
ENDVAR="END"

gpg_function(){
  echo $'\n'
  echo -n "GPG Encrypted Password File Name: "
  read -e pwfile
  PVAR=$(gpg --decrypt $pwfile)
  echo $'\n'
  welcome_function
}

backup_function(){
  cp $pwfile pwfile.bak
  if [ $? -gt 0 ]; then
    echo "Backup Failed."
  else
    echo "Successful Backup."
  fi
  welcome_function
}

#welcome function
welcome_function(){
echo 'Welcome to simple-password-manager.'
echo 'Type 's' to search for a string.'
echo 'Type 'h' to search for a header.'
echo 'Type 'n' to enter a new section.'
echo 'Type 'b' to backup(copy) the encrypted file.'
echo 'Type 'o' to open a different encrypted pw file.'
echo 'Type 'r' to read the entire file.'
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
elif [[ $USRINPUT =~ ^([bB])$ ]] ; then
   backup_function
elif [[ $USRINPUT =~ ^([oO])$ ]] ; then
   gpg_function
elif [[ $USRINPUT =~ ^([nN])$ ]] ; then
   add_section
elif [[ $USRINPUT =~ ^([rR])$ ]] ; then
   read_file
elif [[ $USRINPUT =~ ^([qQ])$ ]] ; then
   unset PVAR
   exit
else
   echo 'Bad input, try again.'
   welcome_function
fi
}

search_function() {
   tmpresult="$SGLOBV"
   if [ $tmpresult -eq '1' ] ; then
	   echo -n 'Type header name to search for: '
           read VAR
           echo $'\n'
           AVAR=$(sed -n "/$VAR/,/$ENDVAR/p" <<< "$PVAR")
           echo "$AVAR"
           echo $'\n'
           again
   elif [ $tmpresult -eq '0' ] ; then
           echo -n 'Type username to search for: '
           read VVAR
           echo $'\n'
           NVAR=$(sed -n "/$VVAR/p" <<< "$PVAR")
           echo "$NVAR"
           echo $'\n'
           again
   else
     echo "This shouldn't happen."
     welcome_function
   fi
}

#new_file(){

#}

read_file(){

  echo -e "$PVAR" | less 
  welcome_function

}

add_section(){

   echo -n "Enter Section Name: "
   read USRSEC
   PVAR+=$'\n'
   PVAR+="==== "$USRSEC" ===="
   PVAR+=$'\n'
   PVAR+="==== "$ENDVAR" ===="
   gpg -e "$PVAR"
   welcome_function
}

#remove_section(){

#}



gpg_function

