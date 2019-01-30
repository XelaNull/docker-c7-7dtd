#!/bin/bash
export INSTALL_DIR=/data/7DTD

# Ensure critical environmental variables are present
if [[ -z $STEAMCMD_LOGIN ]] || [[ -z $STEAMCMD_PASSWORD ]] || \
   [[ -z $STEAMCMD_APP_ID ]]|| [[ -z $INSTALL_DIR ]]; then
  echo "Missing one of the environmental variables: STEAMCMD_LOGIN, STEAMCMD_PASSWORD, STEAMCMD_APP_ID, INSTALL_DIR"
  exit 1
fi
set -e

# Set up the installation directory
[[ ! -d $INSTALL_DIR ]] && mkdir $INSTALL_DIR
chown steam:steam $INSTALL_DIR /home/steam -R

[ -z "$STEAMCMD_NO_VALIDATE" ]   && validate="validate"
[ -n "$STEAMCMD_BETA" ]          && beta="-beta $STEAMCMD_BETA"
[ -n "$STEAMCMD_BETA_PASSWORD" ] && betapassword="-betapassword $STEAMCMD_BETA_PASSWORD"

echo "Running steamcmd"
sudo -u steam /home/steam/steamcmd.sh +login $STEAMCMD_LOGIN $STEAMCMD_PASSWORD \
  +force_install_dir $INSTALL_DIR \
  +app_update $STEAMCMD_APP_ID $beta $betapassword $validate \
  +quit

# Install MODS
cd $INSTALL_DIR && wget http://botman.nz/Botman_Mods_A17.zip && unzip Botman_Mods_A17.zip
cd $INSTALL_DIR/Mods && wget -O CSMM_Patrons.zip https://confluence.catalysm.net/download/attachments/1114182/CSMM_Patrons_8.9.2.zip?api=v2
unzip CSMM_Patrons.zip
git clone https://github.com/djkrose/7DTD-ScriptingMod
wget https://github.com/dmustanger/7dtd-ServerTools/releases/download/12.7/7dtd-ServerTools-12.7.zip

# Move into place any .defaults files
rm -rf /data/7DTD/serverconfig.xml && cp /serverconfig.xml.default /data/7DTD/serverconfig.xml
rm -rf /data/7DTD/Data/Config/rwgmixer.xml && cp /rwgmixer.xml.default /data/7DTD/Data/Config/rwgmixer.xml
rm -rf /data/7DTD/Data/Prefabs/skyscraper_01.xml && cp /skyscraper_01.xml.default /data/7DTD/Data/Prefabs/skyscraper_01.xml
rm -rf /data/7DTD/Data/Prefabs/skyscraper_02.xml && cp /skyscraper_02.xml.default /data/7DTD/Data/Prefabs/skyscraper_02.xml
rm -rf /data/7DTD/Data/Prefabs/skyscraper_03.xml && cp /skyscraper_03.xml.default /data/7DTD/Data/Prefabs/skyscraper_03.xml
rm -rf /data/7DTD/Data/Prefabs/skyscraper_04.xml && cp /skyscraper_04.xml.default /data/7DTD/Data/Prefabs/skyscraper_04.xml
chown steam:steam $INSTALL_DIR /home/steam -R
echo "Completed Installation."
/stop_7dtd.sh
exec "$@"