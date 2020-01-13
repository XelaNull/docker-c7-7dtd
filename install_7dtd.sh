#!/bin/bash
export INSTALL_DIR=/data/7DTD

# Ensure critical environmental variables are present
if [[ -z $STEAMCMD_LOGIN ]] || [[ -z $STEAMCMD_PASSWORD ]] || [[ -z $STEAMCMD_APP_ID ]]|| [[ -z $INSTALL_DIR ]]; then
  echo "Missing one of the environmental variables: STEAMCMD_LOGIN, STEAMCMD_PASSWORD, STEAMCMD_APP_ID, INSTALL_DIR"
  exit 1
fi
set -e

# Erase Existing Application directory
# rm -rf $INSTALL_DIR

# Set up the installation directory
[[ ! -d $INSTALL_DIR/.local ]] && mkdir -p $INSTALL_DIR/.local; 
[[ ! -d $INSTALL_DIR/Mods ]] && mkdir -p $INSTALL_DIR/Mods;
chown steam:steam $INSTALL_DIR $INSTALL_DIR/.local /home/steam -R
ln -s $INSTALL_DIR/.local /home/steam/.local

# Set up extra variables we will use, if they are present
[ -z "$STEAMCMD_NO_VALIDATE" ]   && validate="validate"
[ -n "$STEAMCMD_BETA" ]          && beta="-beta $STEAMCMD_BETA"
[ -n "$STEAMCMD_BETA_PASSWORD" ] && betapassword="-betapassword $STEAMCMD_BETA_PASSWORD"

echo "Starting Steam to perform application install"
su steam -c "/home/steam/steamcmd.sh +login $STEAMCMD_LOGIN $STEAMCMD_PASSWORD \
  +force_install_dir $INSTALL_DIR +app_update $STEAMCMD_APP_ID \
  $beta $betapassword $validate +quit"
  
# Create 7DTD ServerMod Manager Installer
echo 'export INSTALL_DIR=/data/7DTD; cd $INSTALL_DIR; [[ -d $INSTALL_DIR/7dtd-servermod ]] && rm -rf 7dtd-servermod' > /install_servermodmgr.sh
echo 'git clone https://github.com/XelaNull/7dtd-servermod.git && \' >> /install_servermodmgr.sh
echo 'cd 7dtd-servermod && chmod a+x install_mods.sh && ./install_mods.sh $INSTALL_DIR' >> /install_servermodmgr.sh
chmod a+x /install_servermodmgr.sh 
/install_servermodmgr.sh 

chown steam:steam $INSTALL_DIR /home/steam -R
#echo "Stopping 7DTD to kick off new world generation (if name changes)" && /stop_7dtd.sh
echo "Completed Installation."; touch /7dtd.initialized; 
IPADDRESS=`/sbin/ifconfig | grep broad | awk '{print \$2}'`;
echo "Your server should now be accessible at: http://$IPADDRESS/7dtd"; exec "$@"