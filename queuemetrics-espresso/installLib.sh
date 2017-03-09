#
# $Id: installLib.sh,v 1.7 2013/09/11 12:26:04 mirkox Exp $
#
#


#
# Replace property in file
#

function rv() {
 FILE=$1
 KEY=$2
 VAL=$3

 if [ -f $FILE ]; then
  sed -i s^$KEY=.*^"$KEY=$VAL"^ $FILE
 fi
}

function add() {
 FILE=$1
 KEY=$2
 VAL=$3

 if [ -f $FILE ]; then
  echo "$KEY=$VAL" >> $FILE
 fi

}

function addrawline() {
 FILE=$1
 LINE=$2

 if [ -f $FILE ]; then
  echo "$LINE" >> $FILE
 fi
}

function rext() {
  FILE=$1
  EXT=$2
  PRIO=$3
  VAL=$4
  
  if [ -f $FILE ]; then
    sed -i s^"exten => $EXT,$PRIO,.*"^"exten => $EXT,$PRIO,$VAL"^ $FILE
  fi
  
}

function rextN() {
    FILE=$1
    EXT=$2
    CMD=$3
    VAL=$4

    if [ -f $FILE ]; then
      sed -i s^"exten => $EXT,n,$CMD.*"^"exten => $EXT,n,$VAL"^ $FILE
    fi
}


#
# Everything okay
#

function allOK() {

cat <<"EOF"

-----------------------------------------------------------
 _______ __     ________              __             __ __ 
|_     _|  |_  |  |  |  |.-----.----.|  |--.-----.--|  |  |
 _|   |_|   _| |  |  |  ||  _  |   _||    <|  -__|  _  |__|
|_______|____| |________||_____|__|  |__|__|_____|_____|__|

-----------------------------------------------------------

EOF


}


