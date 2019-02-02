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
[[ ! -d $INSTALL_DIR ]] && mkdir -p $INSTALL_DIR/html; cp /index.php $INSTALL_DIR/html/
chown steam:steam $INSTALL_DIR /home/steam -R

# Set up extra variables we will use, if they are present
[ -z "$STEAMCMD_NO_VALIDATE" ]   && validate="validate"
[ -n "$STEAMCMD_BETA" ]          && beta="-beta $STEAMCMD_BETA"
[ -n "$STEAMCMD_BETA_PASSWORD" ] && betapassword="-betapassword $STEAMCMD_BETA_PASSWORD"

echo "Starting Steam to perform application install"
sudo -u steam /home/steam/steamcmd.sh +login $STEAMCMD_LOGIN $STEAMCMD_PASSWORD \
  +force_install_dir $INSTALL_DIR +app_update $STEAMCMD_APP_ID \
  $beta $betapassword $validate +quit

# Install MODS
echo "Installing 7DTD Mods"
cd $INSTALL_DIR; rm -rf Botman_Mods_A17.zip; wget http://botman.nz/Botman_Mods_A17.zip && unzip -o Botman_Mods_A17.zip
cd $INSTALL_DIR/Mods; rm -rf CSMM_Patrons.zip; wget -O CSMM_Patrons.zip https://confluence.catalysm.net/download/attachments/1114182/CSMM_Patrons_9.0.zip?api=v2
unzip -o CSMM_Patrons.zip
cd $INSTALL_DIR; rm -rf 7DTD-ScriptingMod && git clone https://github.com/djkrose/7DTD-ScriptingMod && cp -rp ScriptingMod Mods/
cp /COMPOPACK_35.zip $INSTALL_DIR && unzip COMPOPACK_35.zip && \
cp COMPOPACK_35\(for\ Alpha17exp_b233\)/data/Prefabs/* Data/Prefabs/ && \
rm -rf Data/Config/rwgmixer.xml && cp COMPOPACK_35\(for\ Alpha17exp_b233\)/data/Config/rwgmixer.xml Data/Config/
# CSMM Map Addon
wget -O map.js "https://confluence.catalysm.net/download/attachments/1114446/map.js?version=1&modificationDate=1548000113141&api=v2&download=true" && \
mv map.js $INSTALL_DIR/Mods/Allocs_WebAndMapRendering/webserver/js
#rm -rf 7dtd-ServerTools-12.7.zip; wget https://github.com/dmustanger/7dtd-ServerTools/releases/download/12.7/7dtd-ServerTools-12.7.zip

if [ -d /7dtd-auto-reveal-map ]; then
  echo "Copying in cloned copy of auto-reveal map"
  cp -rp /7dtd-auto-reveal-map $INSTALL_DIR
fi

echo "Applying CUSTOM CONFIGS against application default files" && /7dtd-APPLY-CONFIG.sh
chown steam:steam $INSTALL_DIR /home/steam -R
echo "Stopping 7DTD to kick off new world generation (if name changes)" && /stop_7dtd.sh
echo "Completed Installation."; touch /7dtd.initialized; exec "$@"