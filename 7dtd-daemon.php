#!/usr/bin/php
<?php
/*
7DTD Server Daemon
Used to start/stop the server software or autoreveal.
This daemon is meant to run-once and then look for touch files to determine if any action is needed.

Syntax:
./7dtd-daemon.php <absolute_path_to_7dtd_game_install_directory>

Touchfiles that this daemon uses:
 - server.expected_status, possible values: start,stop,restart,force_stop
 - auto-reveal.status, possible values: start,stop
 - auto-reveal.character, default: first, possible values: any character name
*/

// Error out if we were not provided a valid directory path
if(!is_dir(@$argv[1])) { echo "Invalid installation directory provided.\nSyntax: ./7dtd-daemon.php <absolute_path_to_7dtd_game_install_directory>\n"; exit; }

// Set the installation directory variable
$INSTALL_DIR=$argv[1];

// Loop until Infinity
while (1) {
// ####### MAIN BLOCK OF CODE ######## //  

# Set default on the three touch files, if they don't already exist 
if(!is_file($INSTALL_DIR.'/server.expected_status')) file_put_contents($INSTALL_DIR.'/server.expected_status','start');
if(!is_file($INSTALL_DIR.'/auto-reveal.status')) file_put_contents($INSTALL_DIR.'/auto-reveal.status','start');
if(!is_file($INSTALL_DIR.'/auto-reveal.character')) file_put_contents($INSTALL_DIR.'/auto-reveal.character','first');

// Read in the current values of the three touch files
$server_expected_status = trim(file_get_contents($INSTALL_DIR.'/server.expected_status'));
$autoreveal_status = trim(file_get_contents($INSTALL_DIR.'/auto-reveal.status'));
$autoreveal_character = trim(file_get_contents($INSTALL_DIR.'/auto-reveal.character'));

// If auto-reveal is installed, Switch for auto-reveal status
if(is_file($INSTALL_DIR.'/7dtd-auto-reveal-map/7dtd-autoreveal-map.sh')) switch($autoreveal_status) 
  {
    // If value is start, we should run through procedure for starting it
    case "start":
      // Make sure that it isnt already running
      $AUTOREVEAL_PID=exec("ps awwux | grep -v grep | grep expect | grep 7dtd-autoreveal-map.sh | awk '{print \$2}'");
      if($AUTOREVEAL_PID!='') { echo "ERROR: Can't start what is already running.\n$AUTOREVEAL_PID"; break; }
      
      // Make sure that the 7DTD server is started
      $SERVER_RUNNING_CHECK=exec('ps awwux | grep -v grep | grep 7DaysToDieServer.x86_64');
      if($SERVER_RUNNING_CHECK=='') { echo "ERROR: Can't start due to the 7DTD server not being found in the process list."; break; }
      
      // Make sure that between the start and stop log message the start is the last entry in the log
      // Will need to capture what those two log messages look like before I can code this part.
      
      // The Auto-Reveal character is set to "first", so we should run the initial Auto-Reveal script
      if($autoreveal_character=='first')
        {
          // Start the initial Auto-Reveal script, so it can poll and wait for the first character to connect
          exec("$INSTALL_DIR/7dtd-auto-reveal-map/7dtd-run-after-initial-start.sh $INSTALL_DIR &");
        }
      else // A character name was set, so we should directly run the script with that!
        {
          // Look up the currently generated MAP SIZE
          $RADIATION_BORDER_WIDTH=350;
          $MAPSIZE=exec("grep 'name=\"WorldGenSize\"' $INSTALL_DIR/serverconfig.xml | awk '{print $3}' | cut -d'\"' -f2");
          
          // Determine start & end coordinates
          $ENDING_COORD=($MAPSIZE / 2) - $RADIATION_BORDER_WIDTH;
          $STARTING_COORD=$ENDING_COORD*-1;
          
          // Gather the Telnet Port and password
          $TELNETPORT=exec("grep 'name=\"TelnetPort\"' $INSTALL_DIR/serverconfig.xml | awk '{print $3} | cut -d'\"' -f2");
          $TELNETPASSWORD=exec("grep 'name=\"TelnetPassword\"' $INSTALL_DIR/serverconfig.xml | awk '{print $3} | cut -d'\"' -f2");
          
          // Start the auto-reveal script
          exec("$INSTALL_DIR/7dtd-auto-reveal-map/7dtd-autoreveal-map.sh $TELNETPORT \"$TELNETPASSWORD\" \"$autoreveal_character\" $STARTING_COORD $ENDING_COORD");
        }
    break;
    
    // If value is stop, we should run through procedure for stopping it
    case "stop":
      // Look for the PID of the INITIAL AUTOREVEAL script, so we can kill it too
      $INITIAL_AUTOREVEAL_PID=exec("ps awwux | grep -v grep | grep expect | grep 7dtd-run-after-initial-start.sh | awk '{print \$2}'");
      // If we find it running, we should stop it, too
      if($INITIAL_AUTOREVEAL_PID!='') exec("kill -9 $INITIAL_AUTOREVEAL_PID");
      // There is no graceful way to stop this other than kill -9
      $AUTOREVEAL_PID=exec("ps awwux | grep -v grep | grep expect | grep 7dtd-autoreveal-map.sh | awk '{print \$2}'");
      if($AUTOREVEAL_PID!='') exec("kill -9 $AUTOREVEAL_PID");
    break;
    
    default:
      echo "ERROR: Contents of $INSTALL_DIR/auto-reveal.status should be: start or stop"; exit;
    break;    
  }

// If 7DTD Server is installed, Switch for server expected_status  
if(is_file($INSTALL_DIR.'/7DaysToDieServer.x86_64')) switch($server_expected_status)
  { 
    //case "start":
    // Make sure that the 7DTD server is currently stopped
    //$SERVER_RUNNING_CHECK=exec('ps awwux | grep -v grep | grep 7DaysToDieServer.x86_64');
    // Issue the run/start command
    //if($SERVER_RUNNING_CHECK=="") passthru("sudo -b -u steam nohup $INSTALL_DIR/7DaysToDieServer.x86_64 -configfile=$INSTALL_DIR/serverconfig.xml -logfile $INSTALL_DIR/7dtd.log -quit -batchmode -nographics -dedicated");
    //break;

    case "restart":
    case "stop":
    // Make sure that the 7DTD server is currently started
    $SERVER_RUNNING_CHECK=exec('ps awwux | grep -v grep | grep 7DaysToDieServer.x86_64');
    // Break out if 7DTD server is already stopped
    if($SERVER_RUNNING_CHECK=='') break;
    
    // Make sure that telnet port is up and listening
    $TELNETPORT=exec("grep 'name=\"TelnetPort\"' $INSTALL_DIR/serverconfig.xml | awk '{print $3} | cut -d'\"' -f2");
    $TELNET_CHECK=exec("netstat -anptu | grep LISTEN | grep $TELNETPORT");
    
    // send the two commands needed to save the world and shutdown the server
    exec("/7dtd-sendcmd.sh \"saveworld\"");
    exec("/7dtd-sendcmd.sh \"shutdown\"");
    
    // If we are restarting, we should set the touch file to start on next iteration, then sleep to give server a chance to shutdown
    if($server_exected_status=='restart')
      {
        file_put_contents($INSTALL_DIR.'/auto-reveal.status','stop'); // Ensure the Auto-Reveal script is stopped, since the 7DTD Stopped
        file_put_contents($INSTALL_DIR.'/server.expected_status','start'); // Set this script to start the server back up
        sleep(15); // Give the server a chance to stop, before continuing to next iteration starting it back up
      }
    break;

    // The hope and intention is that this should never be needed. But as the old saying goes:
    //    The road to hell is paved with good intentions....
    case "force_stop":
      // Kill the sudo process running the server daemon
      $SUDO_SERVER_PID=exec("ps awwux | grep -v grep | grep 7DaysToDieServer.x86_64 | grep sudo | awk '{print \$2}'");
      if($SUDO_SERVER_PID!='') { echo "Stopping SUDO Server PID: $SUDO_SERVER_PID\n"; exec("kill -9 $SUDO_SERVER_PID"); }
      // If the core server is still running, we should kill it manually too
      $SERVER_PID=exec("ps awwux | grep -v grep | grep 7DaysToDieServer.x86_64 | grep -v sudo | awk '{print \$2}'");
      if($SERVER_PID!='') { echo "Stopping Server Pid: $SERVER_PID\n"; exec("kill -9 $SERVER_PID"); }
      // We should set the Auto-Reveal script to stop too
      file_put_contents($INSTALL_DIR.'/auto-reveal.status','stop');
    break;    
  }
  
sleep(1);  
// ####### MAIN BLOCK OF CODE ######## //  
}

?>