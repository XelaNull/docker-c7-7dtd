#!/bin/bash

/replace.sh $INSTALL_DIR/Data/Prefabs/skyscraper_01.xml downtown "commercial,downtown" Zoning
/replace.sh $INSTALL_DIR/Data/Prefabs/skyscraper_02.xml downtown "commercial,downtown" Zoning
/replace.sh $INSTALL_DIR/Data/Prefabs/skyscraper_03.xml downtown "commercial,downtown" Zoning
/replace.sh $INSTALL_DIR/Data/Prefabs/skyscraper_04.xml downtown "commercial,downtown" Zoning

/replace.sh $INSTALL_DIR/serverconfig.xml "My Game Host" "Darkness" ServerName
/replace.sh $INSTALL_DIR/serverconfig.xml "8" "24" ServerMaxPlayerCount
/replace.sh $INSTALL_DIR/serverconfig.xml "0" "2" 'name="ServerAdminSlots"'
/replace.sh $INSTALL_DIR/serverconfig.xml "A 7 Days to Die server" "An experimental 7DTD Server. Don't Join!" ServerDescription
/replace.sh $INSTALL_DIR/serverconfig.xml "Navezgane" "RWG" GameWorld
/replace.sh $INSTALL_DIR/serverconfig.xml "asdf" "On the 7th day" 'name="WorldGenSeed"'
/replace.sh $INSTALL_DIR/serverconfig.xml "4096" "8192" 'name="WorldGenSize"'
/replace.sh $INSTALL_DIR/serverconfig.xml "2" "3" GameDifficulty
/replace.sh $INSTALL_DIR/serverconfig.xml "3" "2" ZombieMoveNight
/replace.sh $INSTALL_DIR/serverconfig.xml "false" "true" BuildCreate
/replace.sh $INSTALL_DIR/serverconfig.xml "false" "true" ControlPanelEnabled
/replace.sh $INSTALL_DIR/serverconfig.xml "CHANGEME" "sanity" ControlPanelPassword
/replace.sh $INSTALL_DIR/serverconfig.xml 'value=""' 'value="sanity"' TelnetPassword
/replace.sh $INSTALL_DIR/serverconfig.xml "100" "120" LootAbundance
/replace.sh $INSTALL_DIR/serverconfig.xml "30" "3" LootRespawnDays
/replace.sh $INSTALL_DIR/serverconfig.xml "72" "36" AirDropFrequency
/replace.sh $INSTALL_DIR/serverconfig.xml "60" "70" MaxSpawnedZombies
/replace.sh $INSTALL_DIR/serverconfig.xml "50" "60" MaxSpawnedAnimals
/replace.sh $INSTALL_DIR/serverconfig.xml "true" "false" EACEnabled
/replace.sh $INSTALL_DIR/serverconfig.xml 'value=""' 'value="This is an experimental server. Do not play here."' ServerLoginConfirmationText

/replace.sh $INSTALL_DIR/Data/Config/rwgmixer.xml "0.25,0.5" "0.25,0.75" "0.25,0.5" # pine_forest
/replace.sh $INSTALL_DIR/Data/Config/rwgmixer.xml "0,0.25" ".15,0.3" "0,0.25" # snow
/replace.sh $INSTALL_DIR/Data/Config/rwgmixer.xml "0.5,0.65" "0.1,0.2" "0.5,0.65" # wasteland
/replace.sh $INSTALL_DIR/Data/Config/rwgmixer.xml "0.65,0.75" "0,0.1" "0.65,0.75" # burnt_forest
/replace.sh $INSTALL_DIR/Data/Config/rwgmixer.xml "0.75,1" "0.25,.5" '"0.75,1"' # desert