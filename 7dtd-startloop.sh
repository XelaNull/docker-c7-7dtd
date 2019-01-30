#!/bin/bash

# ONLY RUN THIS SCRIPT IF WE HAVENT RUN IT BEFORE
[[ -f /startloop.touch ]] && exit

# DELAY START TO GIVE 7DTD SERVER A CHANCE TO START
sleep 30;

# ONLY SET VARIABLES IF THEY DONT ALREADY EXIST
[[ -z $7DTD_AUTOREVEAL_MAP ]] && export 7DTD_AUTOREVEAL_MAP=true
[[ -z $INSTALL_DIR ]] && export INSTALL_DIR=/data/7DTD
export RADIATION_BORDER_WIDTH=350

# LOOP UNTIL FIRST PLAYER JOINS SERVER
while true
do
  # Player connected, entityid=171, name=PlayerName, steamid=1111111111, steamOwner=1111111111, ip=xxxxxxx
  PLAYERNAME=`grep 'Player connected' $INSTALL_DIR/7dtd.log | head -1 | awk '{print $7}' | cut -d, -f1 | cut -d= -f2`
  [[ ! -z $PLAYERNAME ]] && break;
  # Sleep for 2 seconds, then repeat
  sleep 2
done

# ENABLE MAP RENDERING OF VISITED LOCATIONS
/7dtd-sendcmd.sh "rendermap\renablerendering\r"

# MAKE FIRST PLAYER AN ADMIN
/7dtd-sendcmd.sh "admin add $PLAYERNAME 0\r"

# CALCULATE START/STOP COORDINATES BASED ON MAP SIZE
MAPSIZE=`grep 'name="WorldGenSize"' $INSTALL_DIR/serverconfig.xml | awk '{print $3'} | cut -d'"' -f2`
ENDING_COORD=`expr $MAPSIZE / 2 - $RADIATION_BORDER_WIDTH`; 
STARTING_COORD=`expr $ENDING_COORD * -1`

# RUN THE RENDER MAP loop script
[[ $7DTD_AUTOREVEAL_MAP = true ]] && /7dtd-rendermap.sh $PLAYERNAME $STARTING_COORD $ENDING_COORD

# CREATE TOUCH FILE SO WE DON'T RUN THIS MORE THAN ONCE
touch /startloop.touch