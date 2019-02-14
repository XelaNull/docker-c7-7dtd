#!/bin/bash
export INSTALL_DIR=/data/7DTD

# Ensure critical environmental variables are present
if [[ -z $STEAMCMD_LOGIN ]] || [[ -z $STEAMCMD_PASSWORD ]] || [[ -z $STEAMCMD_APP_ID ]]|| [[ -z $INSTALL_DIR ]]; then
  echo "Missing one of the environmental variables: STEAMCMD_LOGIN, STEAMCMD_PASSWORD, STEAMCMD_APP_ID, INSTALL_DIR"
  exit 1
fi
set -e

# Erase Existing Application directory
rm -rf $INSTALL_DIR

# Set up the installation directory
[[ ! -d $INSTALL_DIR ]] && mkdir -p $INSTALL_DIR/html; 
chown steam:steam $INSTALL_DIR /home/steam -R

# Set up extra variables we will use, if they are present
[ -z "$STEAMCMD_NO_VALIDATE" ]   && validate="validate"
[ -n "$STEAMCMD_BETA" ]          && beta="-beta $STEAMCMD_BETA"
[ -n "$STEAMCMD_BETA_PASSWORD" ] && betapassword="-betapassword $STEAMCMD_BETA_PASSWORD"

echo "Starting Steam to perform application install"
sudo -u steam /home/steam/steamcmd.sh +login $STEAMCMD_LOGIN $STEAMCMD_PASSWORD \
  +force_install_dir $INSTALL_DIR +app_update $STEAMCMD_APP_ID \
  $beta $betapassword $validate +quit

cd $INSTALL_DIR
git clone https://github.com/XelaNull/7dtd-servermod.git
cd 7dtd-servermod && chmod a+x install_mods.sh && \
cp index.php $INSTALL_DIR/html/
./install_mods.sh $INSTALL_DIR

chown steam:steam $INSTALL_DIR /home/steam -R
echo "Stopping 7DTD to kick off new world generation (if name changes)" && /stop_7dtd.sh
echo "Completed Installation."; touch /7dtd.initialized; exec "$@"