#!/bin/bash
#
# Virtual Radar Server (VRS) installation script.
# VRS Homepage:  http://www.virtualradarserver.co.uk/
#
# VERY BRIEF SUMMARY OF THIS SCRIPT:
#
# This script helps the novice user to install VRS.
# With just a few keystrokes, VRS and a few VRS plugins may be downloaded and installed with this script.
# (User will still need to manually configure VRS to fetch data from ADSB/MLAT receivers and perform other personalizations.)
# Operator flags and silhouette flags may also be downloaded and installed.
# A sample database file consisting of more detailed information of a few planes may be downloaded.
# As an option, the user may also enter the latitude and longitude of the center of the VRS webpage map.
# A directory structure will be created for the convenience of those who wish to enhance VRS' appearance and performance.
# For advanced users:
#  If the "Configuration.xml" and "PluginsConfiguration.txt" files from a previous VRS installation
#    are located in the same directory with this script, this script will incorporate those files
#    so the settings for the new installation of VRS will be configured exactly the same as the previous installation.
#  If a "BaseStation.sqb" file from a previous installation of VRS exists in the same directory with
#    this script, this script will automatically add the database file to the appropriate directory.
#
# Confirmed to work with VRS versions 2.4.2, 2.4.3 and 2.4.4 on Raspbian (Stretch & Buster - [Desktop & Lite]) & Lubuntu.
#
# The author of this script has nothing to do with the creation, development or support of Virtual Radar Server.
# Script credit and more information here:
#   https://github.com/mypiaware
#   https://github.com/mypiaware/virtual-radar-server-installation/blob/master/README.md


#######################################################################################################
########################################   Declare variables   ########################################
#######################################################################################################


# Declare directory and filename variables (Directories will later get created if not already existing.)
CONFIGURATIONFILENAME="Configuration.xml"            # The simple filename of VRS' configuration file.  (This value should not be changed.)
PLUGINCONFIGFILENAME="PluginsConfiguration.txt"      # The simple filename of VRS' plugin configuration file.  (This value should not be changed.)
DATABASEFILENAME="BaseStation.sqb"                   # The simple filename of VRS' database file.  (This value generally may not need to be changed.)
INSTALLERCONFIGFILENAME="InstallerConfiguration.xml" # The simple filename of the file that sets the VRS port value.  (This value should not be changed.)
ANNOUNCEMENTFILENAME="Announcement.html"             # The simple filename of the HTML used to optionally display a message at the top of the website.  (Value may be changed to any HTML filename.)
READMEFILENAME="README.txt"                          # The simple filename of the readme file to explain how to create an announcement message at the top of the website.

HOMEDIR=$( getent passwd "$USER" | cut -d: -f6 )  # Find the home directory of the user calling this script.

VRSROOTDIRECTORY="$HOMEDIR/VirtualRadarServer"        # An arbitrary directory to hold the installation and extras for VRS.
VRSINSTALLDIRECTORY="$VRSROOTDIRECTORY/Installation"  # An arbitrary directory to hold the installation of VRS.
EXTRASDIRECTORY="$VRSROOTDIRECTORY/VRS-Extras"        # An arbitrary root directory for all extra VRS files (custom web files, database file, operator flags, silhouettes.)

SHAREDIRECTORY="$HOMEDIR/.local/share/VirtualRadar"        # Only advanced users should change this SHAREDIRECTORY value.
CONFIGFILE="$SHAREDIRECTORY/$CONFIGURATIONFILENAME"        # The location and name of the main configuration file. (Only advanced users should change this CONFIGFILE value.)
PLUGINSCONFIGFILE="$SHAREDIRECTORY/$PLUGINCONFIGFILENAME"  # The location and name of the plugins configuration file. (Only advanced users should change this PLUGINSCONFIGFILE value.)

OPFLAGSDIRECTORY="$EXTRASDIRECTORY/OperatorFlags"    # An arbitrary directory to store the operator flag images.
PICTURESDIRECTORY="$EXTRASDIRECTORY/Pictures"        # An arbitrary directory to store photos of specific aircrafts.
SILHOUETTESDIRECTORY="$EXTRASDIRECTORY/Silhouettes"  # An arbitrary directory to store the silhouette images.
TILECACHEDIRECTORY="$EXTRASDIRECTORY/TileCache"      # An arbitrary directory to store the tile server map cached images from the Tile Server Cache Plugin.

CUSTOMCONTENTPLUGINDIRECTORY="$EXTRASDIRECTORY/CustomContent"                     # An arbitrary directory to store two directories for the Custom Content Plugin.
CUSTOMINJECTEDFILESDIRECTORY="$CUSTOMCONTENTPLUGINDIRECTORY/CustomInjectedFiles"  # An arbitrary directory to store files used by the Custom Content Plugin to inject into existing VRS web files.
CUSTOMWEBFILESDIRECTORY="$CUSTOMCONTENTPLUGINDIRECTORY/CustomWebFiles"            # An arbitrary directory to store custom VRS web files used by the Custom Content Plugin.

DATABASEMAINDIRECTORY="$EXTRASDIRECTORY/Databases"               # An arbitrary root directory to store two directories for the database file and the database backup file.
DATABASEDIRECTORY="$DATABASEMAINDIRECTORY/Database"              # An arbitrary directory to store the SQLite database file.
DATABASEBACKUPDIRECTORY="$DATABASEMAINDIRECTORY/DatabaseBackup"  # An arbitrary directory for the database file backup.

AUTORUNDIRECTORY="$EXTRASDIRECTORY/Autorun"      # An arbitrary directory to store the small script to run at system boot if desired to autorun VRS.
AUTORUNSCRIPT="$AUTORUNDIRECTORY/autorunvrs.sh"  # An arbitrary script to use if desiring to auto-start VRS.

DATABASEFILE="$DATABASEDIRECTORY/$DATABASEFILENAME"                   # An arbitrary location and name for the SQLite database file.
DATABASEBACKUPSCRIPT="$DATABASEBACKUPDIRECTORY/backupvrsdb.sh"        # An arbitrary location and name of the database file backup script.
DATABASEBACKUPFILE="$DATABASEBACKUPDIRECTORY/BaseStation_BACKUP.sqb"  # An arbitrary location and name of the database file's backup file.

STARTCOMMANDDIR="/usr/local/bin"                       # The location of the universal command to start VRS.  (This value should not be changed.)
STARTCOMMANDFILENAME="vrs"                             # An arbitrary simple filename of the universal command to start VRS.
STARTCOMMAND="$STARTCOMMANDDIR/$STARTCOMMANDFILENAME"  # The full path of the VRS start command.

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"  # Get directory of where this script is located.  (This value should not be changed.)
TEMPDIR="/tmp/vrs"  # An arbitrary directory where downloaded files are kept.


# List of all possible directories that will need to be created.
VRSDIRECTORIES=(
   "$VRSROOTDIRECTORY"
   "$VRSINSTALLDIRECTORY"
   "$SHAREDIRECTORY"
   "$EXTRASDIRECTORY"
   "$AUTORUNDIRECTORY"
   "$CUSTOMCONTENTPLUGINDIRECTORY"
   "$CUSTOMINJECTEDFILESDIRECTORY"
   "$CUSTOMWEBFILESDIRECTORY"
   "$DATABASEMAINDIRECTORY"
   "$DATABASEDIRECTORY"
   "$DATABASEBACKUPDIRECTORY"
   "$OPFLAGSDIRECTORY"
   "$PICTURESDIRECTORY"
   "$SILHOUETTESDIRECTORY"
   "$TILECACHEDIRECTORY"
   "$TEMPDIR"
)


# Declare an array of URLs for all the VRS files.
VRSFILES=(
   "http://www.virtualradarserver.co.uk/Files/VirtualRadar.LanguagePack.tar.gz"  # Install language pack files first because the 'VirtualRadar.WebSite.resources.dll' file may be newer in the 'VirtualRadar.tar.gz' file.
   "http://www.virtualradarserver.co.uk/Files/VirtualRadar.tar.gz"
   "http://www.virtualradarserver.co.uk/Files/VirtualRadar.exe.config.tar.gz"
   "http://www.virtualradarserver.co.uk/Files/VirtualRadar.CustomContentPlugin.tar.gz"
   "http://www.virtualradarserver.co.uk/Files/VirtualRadar.DatabaseEditorPlugin.tar.gz"
   "http://www.virtualradarserver.co.uk/Files/VirtualRadar.DatabaseWriterPlugin.tar.gz"
   "http://www.virtualradarserver.co.uk/Files/VirtualRadar.TileServerCachePlugin.tar.gz"
   "http://www.virtualradarserver.co.uk/Files/VirtualRadar.WebAdminPlugin.tar.gz"
)


# Declare URLs for operator flags, silhouettes and a database file. (Change any URL if better files are found elsewhere.)
OPFLAGSURL="http://www.woodair.net/SBS/Download/LOGO.zip"
SILHOUETTESURL="http://www.kinetic.co.uk/repo/SilhouettesLogos.zip"
DATABASEURL="https://github.com/mypiaware/virtual-radar-server-installation/raw/master/Downloads/Database/BaseStation.sqb"
PICTURESURL="https://github.com/mypiaware/virtual-radar-server-installation/raw/master/Downloads/Pictures/Pictures.zip"


# Declare a default port value. (User is given a choice to change it.  If a port has already been set from a previous installation, then set the already existing port value as the default.)
DEFAULTPORT="8090"
if [ -f "$SHAREDIRECTORY/$INSTALLERCONFIGFILENAME" ]; then
   EXISTINGPORT=$(<"$SHAREDIRECTORY/$INSTALLERCONFIGFILENAME")
   if [[ $EXISTINGPORT =~ \<WebServerPort\>([[:digit:]]+)\</WebServerPort\> ]]; then
      DEFAULTPORT=${BASH_REMATCH[1]}
   fi
fi


# Get the local IP address of this machine.
if [[ $(hostname -I) =~ ^([[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}) ]]; then
   LOCALIP=${BASH_REMATCH[1]}
fi


# Just to give some color to some text.
BLUE_COLOR='\033[1;34m'
GREEN_COLOR='\033[1;32m'
RED_COLOR='\033[1;31m'
ORANGE_COLOR='\033[0;33m'
NO_COLOR='\033[0m'


# Function ran after nearly every command in this script to report an error if one exists.
function ERROREXIT {
   if [ $? -ne 0 ]; then
      printf "${RED_COLOR}ERROR! $2${NO_COLOR}\n"       # Print the error message.
      printf "${RED_COLOR}Error Code: $1${NO_COLOR}\n"  # Print the error code.
      exit $1
   fi
}


######################################################################################################
########################################   Begin the script   ########################################
######################################################################################################


# Check if this script is ran as root. (It should not be ran as root.)
if [[ $EUID == 0 ]]; then
   printf "Do NOT run this script as root! (Do not use 'sudo' in the command.)\n"
   exit 1
fi


# Even though this script should not be ran as root, it will occasionally need root privileges.
# Non-Raspbian operating systems will prompt user for sudo privilege here.
sudo ls &> /dev/null  # Dummy command just to get a prompt for the user's password for the sake of using sudo.


# The "-ignore" parameter passed to this script will ignore the 3 custom files that may be included with this script.
# (This is a hidden feature of this script.)
PARAMETER=$1
PARAMETER=${PARAMETER,,} # Convert to lowercase
if [[ $PARAMETER == "-ignore" ]]; then IGNOREFILES=1; else IGNOREFILES=0; fi


# Print welcome screen and prompt user for the port number VRS should use.
printf "\n ${BLUE_COLOR}Virtual Radar Server${NO_COLOR}\n"
printf " ${BLUE_COLOR}http://www.virtualradarserver.co.uk${NO_COLOR}\n\n"
printf "This script downloads & installs:\n"
printf "  * Virtual Radar Server\n"
printf "  * Mono 4 (and Mono 4 fix)\n"
printf "  * Language Packs\n"
printf "  * Custom Content Plugin\n"
printf "  * Database Editor Plugin\n"
printf "  * Database Writer Plugin\n"
printf "  * Tile Server Cache Plugin\n"
printf "  * Web Admin Plugin\n\n"


# Check if this script sees any files from a previous installation.
if [[ $IGNOREFILES -eq 0 ]]; then
   if [[ ( -e "$SCRIPTDIR/$DATABASEFILENAME" && ! -e "$DATABASEFILE" ) || -e "$SCRIPTDIR/$CONFIGURATIONFILENAME" || -e "$SCRIPTDIR/$PLUGINCONFIGFILENAME" ]]; then
      printf "The following found files will be used with this installation script:\n"
      # For safety reasons, prevent any possible existing database file from getting overwritten by an possibly older database file.  It is assumed that an existing database should not be overwritten.
      if [ -f "$SCRIPTDIR/$DATABASEFILENAME" ] && ! [ -f "$DATABASEFILE" ]; then printf "  * $DATABASEFILENAME\n";      fi
      if [ -f "$SCRIPTDIR/$CONFIGURATIONFILENAME" ];                        then printf "  * $CONFIGURATIONFILENAME\n"; fi
      if [ -f "$SCRIPTDIR/$PLUGINCONFIGFILENAME" ];                         then printf "  * $PLUGINCONFIGFILENAME\n";  fi
      printf "\n";
   fi
fi


# Prompt user if the following sample files should be downloaded:  Operator Flags, Silhouettes and a database file.
while ! [[ $DL_OPF =~ ^[YyNn]$ ]]; do printf "Download & install operator flags? [yn]: "; read DL_OPF; done
while ! [[ $DL_SIL =~ ^[YyNn]$ ]]; do printf "Download & install silhouettes? [yn]: ";    read DL_SIL; done
while ! [[ $DL_PIC =~ ^[YyNn]$ ]]; do printf "Download & install pictures? [yn]: ";       read DL_PIC; done
if [ ! -e "$DATABASEFILE" ] && ( [ $IGNOREFILES -eq 1 ] || [ ! -e "$SCRIPTDIR/$DATABASEFILENAME" ] ); then  # For safety reasons, prevent any possible existing database file from getting overwritten by an possibly older database file.  It is assumed that an existing database should not be overwritten.
   while ! [[ $DL_DB =~ ^[YyNn]$ ]]; do printf "Download & install a sample database? [yn]: "; read DL_DB; done
fi
printf "\n"


# Prompt user for a port number VRS should use.
printf "Enter a port number for the Virtual Radar Server to use.\n"
printf "(Press [ENTER] to accept the default value of %s.)\n" $DEFAULTPORT
printf "Port Number [%s]: " $DEFAULTPORT; read PORT;
until [[ $PORT == "" || $PORT =~ ^[[:digit:]]+$ ]]; do printf "Port Number [%s]: " $DEFAULTPORT; read -r PORT; done
if [[ $PORT == "" ]]; then PORT=$DEFAULTPORT; fi
printf "Port Number Selected: ${ORANGE_COLOR}%s${NO_COLOR}\n\n" $PORT


# Offer a choice for localization of the VRS webpages.
printf "Select the default language to be displayed in the VRS webpages:\n\n"
PS3='Please choose your language of preference: '
LOCALE_CHOICES=("Chinese (China)" "English (Australia)" "English (Belize)" "English (Canada)" "English (Caribbean)" "English (India)"
"English (Ireland)" "English (Jamaica)" "English (Malaysia)" "English (New Zealand)" "English (Singapore)" "English (South Africa)"
"English (Trinidad and Tobago)" "English (United Kingdom)" "English (United States)" "French (Belgium)" "French (Canada)" "French (France)"
"French (Luxembourg)" "French (Monaco)" "French (Switzerland)" "German (Germany)" "Portuguese (Brazil)" "Russian (Russia)" "Quit")
select LANG_COUNTRY in "${LOCALE_CHOICES[@]}"
do
   case $LANG_COUNTRY in
      "Chinese (China)")               LOCALIZATION="zh-CN";  break;;
      "English (Australia)")           LOCALIZATION="en-AU";  break;;
      "English (Belize)")              LOCALIZATION="en-BZ";  break;;
      "English (Canada)")              LOCALIZATION="en-CA";  break;;
      "English (Caribbean)")           LOCALIZATION="en-029"; break;;
      "English (India)")               LOCALIZATION="en-IN";  break;;
      "English (Ireland)")             LOCALIZATION="en-IE";  break;;
      "English (Jamaica)")             LOCALIZATION="en-JM";  break;;
      "English (Malaysia)")            LOCALIZATION="en-MY";  break;;
      "English (New Zealand)")         LOCALIZATION="en-NZ";  break;;
      "English (Singapore)")           LOCALIZATION="en-SG";  break;;
      "English (South Africa)")        LOCALIZATION="en-ZA";  break;;
      "English (Trinidad and Tobago)") LOCALIZATION="en-TT";  break;;
      "English (United Kingdom)")      LOCALIZATION="en-GB";  break;;
      "English (United States)")       LOCALIZATION="en-US";  break;;
      "French (Belgium)")              LOCALIZATION="fr-BE";  break;;
      "French (Canada)")               LOCALIZATION="fr-CA";  break;;
      "French (France)")               LOCALIZATION="fr-FR";  break;;
      "French (Luxembourg)")           LOCALIZATION="fr-LU";  break;;
      "French (Monaco)")               LOCALIZATION="fr-MC";  break;;
      "French (Switzerland)")          LOCALIZATION="fr-CH";  break;;
      "German (Germany)")              LOCALIZATION="de-DE";  break;;
      "Portuguese (Brazil)")           LOCALIZATION="pt-BR";  break;;
      "Russian (Russia)")              LOCALIZATION="ru-RU";  break;;
      "Quit")                          exit;;
   esac
done
printf "\nLocalization has been set to:  ${ORANGE_COLOR}%s${NO_COLOR}\n\n" "$LANG_COUNTRY"


# Add option for user to enter longitude & latitude coordinates of the center of the VRS webpage map.
printf "OPTIONAL: Enter longitude and latitude coordinates of the center of the map.\n"
while ! [[ $ENTER_GPS =~ ^[YyNn]$ ]]; do printf "Do you wish to enter coordinates? [yn]: "; read ENTER_GPS; done
if [[ $ENTER_GPS =~ [Yy] ]]; then
   while ! [[ $COORDINATE_LON =~ ^\s*(([-+]?180(\.0*)?))\s*$ || $COORDINATE_LON =~ ^\s*([-+]?(1?[0-7]?|[89]?)?[0-9]{1}(\.[0-9]*)?)\s*$ ]]; do printf "  Enter Longitude [-180.0 to +180.0]: "; read COORDINATE_LON; done
   COORDINATE_LON=${BASH_REMATCH[1]}
   if [[ $COORDINATE_LON =~ \.$ ]];    then COORDINATE_LON="${COORDINATE_LON}0";  fi  # Any number ending with a decimal should have a '0' appended to it.
   if ! [[ $COORDINATE_LON =~ \. ]];   then COORDINATE_LON="${COORDINATE_LON}.0"; fi  # Any number without a decimal should have a '.0' appended to it.
   if [[ $COORDINATE_LON =~ ^[0-9] ]]; then COORDINATE_LON="+${COORDINATE_LON}";  fi  # Just for the sake of temporarily printing a '+' in front of a positive number to the screen.
   while ! [[ $COORDINATE_LAT =~ ^\s*([-+]?90(\.0*)?)\s*$ || $COORDINATE_LAT =~ ^\s*([-+]?[0-8]?[0-9]{1}(\.[0-9]*)?)\s*$ ]]; do printf "  Enter Latitude  [ -90.0 to +90.0 ]: "; read COORDINATE_LAT; done
   COORDINATE_LAT=${BASH_REMATCH[1]}
   if [[ $COORDINATE_LAT =~ \.$ ]];    then COORDINATE_LAT="${COORDINATE_LAT}0";  fi  # Any number ending with a decimal should have a '0' appended to it.
   if ! [[ $COORDINATE_LAT =~ \. ]];   then COORDINATE_LAT="${COORDINATE_LAT}.0"; fi  # Any number without a decimal should have a '.0' appended to it.
   if [[ $COORDINATE_LAT =~ ^[0-9] ]]; then COORDINATE_LAT="+${COORDINATE_LAT}";  fi  # Just for the sake of temporarily printing a '+' in front of a positive number to the screen.
   # The following is just for the purpose of lining up the decimal points when printed to the screen.
   LONDEC="$(echo "$COORDINATE_LON" | grep -aob '\.' | grep -oE '[0-9]+')"
   LATDEC="$(echo "$COORDINATE_LAT" | grep -aob '\.' | grep -oE '[0-9]+')"
   if [[ $LONDEC -gt $LATDEC ]]; then
      NUMSPACES="$(($LONDEC-$LATDEC))"
      PADDEDSPACES=$(printf '%0.s ' $(seq 1 $NUMSPACES))
      COORDINATE_LAT=$PADDEDSPACES$COORDINATE_LAT
   elif [[ $LATDEC -gt $LONDEC ]]; then
      NUMSPACES="$(($LATDEC-$LONDEC))"
      PADDEDSPACES=$(printf '%0.s ' $(seq 1 $NUMSPACES))
      COORDINATE_LON=$PADDEDSPACES$COORDINATE_LON
   fi
   printf "\n"
   printf "Longitude set to: ${ORANGE_COLOR}%s${NO_COLOR}\n" "$COORDINATE_LON"
   printf "Latitude set to:  ${ORANGE_COLOR}%s${NO_COLOR}\n" "$COORDINATE_LAT"
   if [[ $COORDINATE_LON =~ ^[+]?(.+) ]]; then COORDINATE_LON=${BASH_REMATCH[1]}; fi  # Remove any '+' at the beginning because VRS does not accept the '+' symbol.
   if [[ $COORDINATE_LAT =~ ^[+]?(.+) ]]; then COORDINATE_LAT=${BASH_REMATCH[1]}; fi  # Remove any '+' at the beginning because VRS does not accept the '+' symbol.
fi
printf "\n"


# User only needs to press [Enter] key to start the VRS installation.
printf "No more user input necessary.\n"
printf "${GREEN_COLOR}Press [ENTER] to begin the VRS installation...${NO_COLOR}"; read -p ""
printf "\n"


#############################################################################################
#############################  Installation of VRS begins here  #############################
#############################################################################################


# VRS installation begins with the installation of Mono 4.
if ! [[ $(which mono) ]]; then
   sudo apt-get update
   sudo apt-get -y install mono-complete
fi


# Good time to make sure directories of interest are present (create if not already present).
for NEWDIRECTORY in "${VRSDIRECTORIES[@]}"; do
   if [ ! -d "$NEWDIRECTORY" ]; then mkdir -p "$NEWDIRECTORY"; fi; ERROREXIT 10 "Failed to create $NEWDIRECTORY!"
done


# Download/extract files from the VRS website to install VRS and the VRS plugins.
for URL in "${VRSFILES[@]}"; do
   REGEX="\/([^/]*)$"
   [[ $URL =~ $REGEX ]]
   FILENAME=${BASH_REMATCH[1]}
   if [ ! -f "$TEMPDIR/$FILENAME" ]; then wget -P "$TEMPDIR" "$URL"; fi;  ERROREXIT 11 "Failed to download $FILENAME!"
   tar -xf "$TEMPDIR/$FILENAME" -C "$VRSINSTALLDIRECTORY";                ERROREXIT 12 "Failed to untar $FILENAME!"
done


# Function to download & extract addon files (operator flags, silhouettes, pictures, database file).
function UNPACK {
   local ID="$1"
   local URL="$2"
   local DIRECTORYPATH="$3"

   # Download and extract files to the appropriate directory.
   local REGEX="\/([^/]*)$"
   [[ $URL =~ $REGEX ]]
   local FILENAME=${BASH_REMATCH[1]}
   if [ ! -f "$TEMPDIR/$FILENAME" ]; then wget -P "$TEMPDIR" "$URL"; fi
   if [ $? -ne 0 ]; then printf "Failed to download %s!\n" "$FILENAME"; printf "${RED_COLOR}Press [ENTER] to continue with the VRS installation...${NO_COLOR}"; read -p ""
   else
      if [ $ID == "OperatorFlagsFolder" ]; then
         unzip -j -o -qq "$TEMPDIR/$FILENAME" "[A-Z][A-Z][A-Z].bmp" -d "$DIRECTORYPATH";  ERROREXIT 13 "Failed to unzip $FILENAME!"  # The "*.bmp" may need to be changed if a different compressed file is used.
      fi
      if [ $ID == "SilhouettesFolder" ]; then
         unzip -j -o -qq "$TEMPDIR/$FILENAME" "*.bmp" -d "$DIRECTORYPATH";  ERROREXIT 14 "Failed to unzip $FILENAME!"  # The "*.bmp" may need to be changed if a different compressed file is used.
      fi
      if [ $ID == "Pictures" ]; then
         unzip -j -o -qq "$TEMPDIR/$FILENAME" "*.*" -d "$DIRECTORYPATH";    ERROREXIT 15 "Failed to unzip $FILENAME!"
      fi
      if [ $ID == "DatabaseFileName" ]; then
         mv "$TEMPDIR/BaseStation.sqb" "$DIRECTORYPATH/$DATABASEFILENAME";  ERROREXIT 16 "Failed to move $FILENAME!"   # Be sure the downloaded file's name is actually "BaseStation.sqb".
         printf "\n"
      fi
   fi
}


# Download & extract addon files (operator flags, silhouettes, a sample database file).
if [[ $DL_OPF =~ [Yy] ]]; then UNPACK "OperatorFlagsFolder" "$OPFLAGSURL"      "$OPFLAGSDIRECTORY";     fi
if [[ $DL_SIL =~ [Yy] ]]; then UNPACK "SilhouettesFolder"   "$SILHOUETTESURL"  "$SILHOUETTESDIRECTORY"; fi
if [[ $DL_PIC =~ [Yy] ]]; then UNPACK "Pictures"            "$PICTURESURL"     "$PICTURESDIRECTORY";    fi
if [[ $DL_DB  =~ [Yy] ]]; then UNPACK "DatabaseFileName"    "$DATABASEURL"     "$DATABASEDIRECTORY";    fi


# Create an initial "Configuration.xml" file (if not already existing).
if ! [ -f "$CONFIGFILE" ]; then
   touch "$CONFIGFILE";                                                                                                                            ERROREXIT 17 "Failed to create $CONFIGFILE!"
   echo "<?xml version=\"1.0\" encoding=\"utf-8\"?>"                                                                              > "$CONFIGFILE"; ERROREXIT 18 "Failed to edit $CONFIGFILE!"
   echo "<Configuration xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\">" >> "$CONFIGFILE"; ERROREXIT 19 "Failed to edit $CONFIGFILE!"
   echo "  <BaseStationSettings>"                                                                                                >> "$CONFIGFILE"; ERROREXIT 20 "Failed to edit $CONFIGFILE!"
   echo "  </BaseStationSettings>"                                                                                               >> "$CONFIGFILE"; ERROREXIT 21 "Failed to edit $CONFIGFILE!"
   echo "  <GoogleMapSettings>"                                                                                                  >> "$CONFIGFILE"; ERROREXIT 22 "Failed to edit $CONFIGFILE!"
   echo "  </GoogleMapSettings>"                                                                                                 >> "$CONFIGFILE"; ERROREXIT 23 "Failed to edit $CONFIGFILE!"
   echo "</Configuration>"                                                                                                       >> "$CONFIGFILE"; ERROREXIT 24 "Failed to edit $CONFIGFILE!"
fi


# Function to fill in the directory/file paths in the initial "Configuration.xml" file created above (operator flags, silhouettes, database file, pictures).
function EDITCONFIGFILE {
   local ID="$1"
   local DIRECTORYPATH="$2"
   if grep -q "<$ID>.*</$ID>" "$CONFIGFILE"; then  # If ID already existing, modify its value.
      sed -i "s|<$ID>.*</$ID>|<$ID>$DIRECTORYPATH</$ID>|" "$CONFIGFILE";                                     ERROREXIT 25 "Failed to edit $CONFIGFILE!"
   else  # If ID not already existing, create it with the appropriate value.
      sed -i "s|<BaseStationSettings>|<BaseStationSettings>\n    <$ID>$DIRECTORYPATH</$ID>|" "$CONFIGFILE";  ERROREXIT 26 "Failed to edit $CONFIGFILE!"
   fi
}


# Fill in the paths in the "Configuration.xml" file for the addon directories/files (operator flags, silhouettes, database file, pictures).
EDITCONFIGFILE "PicturesFolder"      "$PICTURESDIRECTORY"
EDITCONFIGFILE "SilhouettesFolder"   "$SILHOUETTESDIRECTORY"
EDITCONFIGFILE "OperatorFlagsFolder" "$OPFLAGSDIRECTORY"
EDITCONFIGFILE "DatabaseFileName"    "$DATABASEFILE"


# If user has entered location coordinates then set these coordinate values in the "Configuration.xml" file.
if [[ $ENTER_GPS =~ [Yy] ]]; then
   # Set longitude.
   if grep -q "<InitialMapLongitude>.*</InitialMapLongitude>" "$CONFIGFILE"; then  # If InitialMapLongitude already existing, modify its value.
      sed -i "s|<InitialMapLongitude>.*</InitialMapLongitude>|<InitialMapLongitude>$COORDINATE_LON</InitialMapLongitude>|" "$CONFIGFILE"; ERROREXIT 27 "Failed to edit $CONFIGFILE!"
   else  # If InitialMapLongitude not already existing, create it with the appropriate value.
      sed -i "s|<GoogleMapSettings>|<GoogleMapSettings>\n    <InitialMapLongitude>$COORDINATE_LON</InitialMapLongitude>|" "$CONFIGFILE";  ERROREXIT 28 "Failed to edit $CONFIGFILE!"
   fi
   # Set latitude.
   if grep -q "<InitialMapLatitude>.*</InitialMapLatitude>" "$CONFIGFILE"; then  # If InitialMapLatitude already existing, modify its value.
      sed -i "s|<InitialMapLatitude>.*</InitialMapLatitude>|<InitialMapLatitude>$COORDINATE_LAT</InitialMapLatitude>|" "$CONFIGFILE";     ERROREXIT 29 "Failed to edit $CONFIGFILE!"
   else  # If InitialMapLatitude not already existing, create it with the appropriate value.
      sed -i "s|<GoogleMapSettings>|<GoogleMapSettings>\n    <InitialMapLatitude>$COORDINATE_LAT</InitialMapLatitude>|" "$CONFIGFILE";    ERROREXIT 30 "Failed to edit $CONFIGFILE!"
   fi
fi


# Create a file to allow for a different port to be used by the VRS.
touch "$SHAREDIRECTORY/$INSTALLERCONFIGFILENAME";                                                                                                                                ERROREXIT 31 "Failed to create $INSTALLERCONFIGFILENAME!"
echo "<?xml version=\"1.0\" encoding=\"utf-8\" ?>"                                                                                 > "$SHAREDIRECTORY/$INSTALLERCONFIGFILENAME"; ERROREXIT 32 "Failed to edit $INSTALLERCONFIGFILENAME!"
echo "<InstallerSettings xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\">" >> "$SHAREDIRECTORY/$INSTALLERCONFIGFILENAME"; ERROREXIT 33 "Failed to edit $INSTALLERCONFIGFILENAME!"
echo "    <WebServerPort>$PORT</WebServerPort>"                                                                                   >> "$SHAREDIRECTORY/$INSTALLERCONFIGFILENAME"; ERROREXIT 34 "Failed to edit $INSTALLERCONFIGFILENAME!"  # The custom port is written in this line.
echo "</InstallerSettings>"                                                                                                       >> "$SHAREDIRECTORY/$INSTALLERCONFIGFILENAME"; ERROREXIT 35 "Failed to edit $INSTALLERCONFIGFILENAME!"


# Create an HTML file and an accompanying readme file to create messages that may appear at the top of the website.
if ! [ -f "$CUSTOMINJECTEDFILESDIRECTORY/$ANNOUNCEMENTFILENAME" ]; then
   touch "$CUSTOMINJECTEDFILESDIRECTORY/$ANNOUNCEMENTFILENAME";                                                      ERROREXIT 36 "Failed to create $ANNOUNCEMENTFILENAME!"
   echo '<!--'                                              > "$CUSTOMINJECTEDFILESDIRECTORY/$ANNOUNCEMENTFILENAME"; ERROREXIT 37 "Failed to edit $ANNOUNCEMENTFILENAME!"
   echo "<div style=\""                                    >> "$CUSTOMINJECTEDFILESDIRECTORY/$ANNOUNCEMENTFILENAME"; ERROREXIT 38 "Failed to edit $ANNOUNCEMENTFILENAME!"
   echo "   color: red;"                                   >> "$CUSTOMINJECTEDFILESDIRECTORY/$ANNOUNCEMENTFILENAME"; ERROREXIT 39 "Failed to edit $ANNOUNCEMENTFILENAME!"
   echo "   text-align: center;"                           >> "$CUSTOMINJECTEDFILESDIRECTORY/$ANNOUNCEMENTFILENAME"; ERROREXIT 40 "Failed to edit $ANNOUNCEMENTFILENAME!"
   echo "   font-weight: bold;"                            >> "$CUSTOMINJECTEDFILESDIRECTORY/$ANNOUNCEMENTFILENAME"; ERROREXIT 41 "Failed to edit $ANNOUNCEMENTFILENAME!"
   echo "   font-size: 1em"                                >> "$CUSTOMINJECTEDFILESDIRECTORY/$ANNOUNCEMENTFILENAME"; ERROREXIT 42 "Failed to edit $ANNOUNCEMENTFILENAME!"
   echo "\">"                                              >> "$CUSTOMINJECTEDFILESDIRECTORY/$ANNOUNCEMENTFILENAME"; ERROREXIT 43 "Failed to edit $ANNOUNCEMENTFILENAME!"
   echo "This text will be at the top of the VRS website!" >> "$CUSTOMINJECTEDFILESDIRECTORY/$ANNOUNCEMENTFILENAME"; ERROREXIT 44 "Failed to edit $ANNOUNCEMENTFILENAME!"
   echo "</div>"                                           >> "$CUSTOMINJECTEDFILESDIRECTORY/$ANNOUNCEMENTFILENAME"; ERROREXIT 45 "Failed to edit $ANNOUNCEMENTFILENAME!"
   echo "-->"                                              >> "$CUSTOMINJECTEDFILESDIRECTORY/$ANNOUNCEMENTFILENAME"; ERROREXIT 46 "Failed to edit $ANNOUNCEMENTFILENAME!"
fi
if ! [ -f "$CUSTOMINJECTEDFILESDIRECTORY/$READMEFILENAME" ]; then
   touch "$CUSTOMINJECTEDFILESDIRECTORY/$READMEFILENAME";                                                                                                         ERROREXIT 47 "Failed to create $READMEFILENAME!"
   echo "Any text in the \"$ANNOUNCEMENTFILENAME\" file will be placed at the very top of the VRS web page."  > "$CUSTOMINJECTEDFILESDIRECTORY/$READMEFILENAME";  ERROREXIT 48 "Failed to edit $READMEFILENAME!"
   echo "The text could be used to provide the website visitors an announcement."                            >> "$CUSTOMINJECTEDFILESDIRECTORY/$READMEFILENAME";  ERROREXIT 49 "Failed to edit $READMEFILENAME!"
   echo "This text will be at the top of both the desktop and mobile version of the website."                >> "$CUSTOMINJECTEDFILESDIRECTORY/$READMEFILENAME";  ERROREXIT 50 "Failed to edit $READMEFILENAME!"
   echo ""                                                                                                   >> "$CUSTOMINJECTEDFILESDIRECTORY/$READMEFILENAME";  ERROREXIT 51 "Failed to edit $READMEFILENAME!"
   echo "For example, the following text could be placed at the top:"                                        >> "$CUSTOMINJECTEDFILESDIRECTORY/$READMEFILENAME";  ERROREXIT 52 "Failed to edit $READMEFILENAME!"
   echo "\"Server will perform a reboot at 12:00am (UTC).\""                                                 >> "$CUSTOMINJECTEDFILESDIRECTORY/$READMEFILENAME";  ERROREXIT 53 "Failed to edit $READMEFILENAME!"
   echo ""                                                                                                   >> "$CUSTOMINJECTEDFILESDIRECTORY/$READMEFILENAME";  ERROREXIT 54 "Failed to edit $READMEFILENAME!"
   echo "Because this is an HTML file, standard HTML tags may be used with the text."                        >> "$CUSTOMINJECTEDFILESDIRECTORY/$READMEFILENAME";  ERROREXIT 55 "Failed to edit $READMEFILENAME!"
   echo "For example, the following usage of HTML tags will help enhance this text:"                         >> "$CUSTOMINJECTEDFILESDIRECTORY/$READMEFILENAME";  ERROREXIT 56 "Failed to edit $READMEFILENAME!"
   echo "<b><font color=\"red\">This text is both bold and in a red color!</font></b>"                       >> "$CUSTOMINJECTEDFILESDIRECTORY/$READMEFILENAME";  ERROREXIT 57 "Failed to edit $READMEFILENAME!"
fi


# Enable & configure the Custom Content Plugin to find the ANNOUNCEMENTFILENAME file to inject into 'desktop.html' and 'mobile.html' VRS files.
# Enable & configure the Custom Content Plugin to look in the CUSTOMWEBFILESDIRECTORY directory for any custom web files.
INJECTIONFILEPATHNAME="$CUSTOMINJECTEDFILESDIRECTORY/$ANNOUNCEMENTFILENAME"
INJECTIONFILE="${INJECTIONFILEPATHNAME//\//%2f}";           ERROREXIT 58 "Failed to create the $INJECTIONFILE variable!"    # Replace '/' with '%2f' HTML character code.
INJECTIONFOLDER="${CUSTOMINJECTEDFILESDIRECTORY//\//%2f}";  ERROREXIT 59 "Failed to create the $INJECTIONFOLDER variable!"  # Replace '/' with '%2f' HTML character code.
SITEROOTFOLDER="${CUSTOMWEBFILESDIRECTORY//\//%2f}";        ERROREXIT 60 "Failed to create the $SITEROOTFOLDER variable!"   # Replace '/' with '%2f' HTML character code.
CUSTOMCONTENTTEMPLATE="\
VirtualRadar.Plugin.CustomContent.Options=%3c%3fxml+version%3d%221.0%22%3f%3e%0a\
%3cOptions+xmlns%3axsd%3d%22http%3a%2f%2fwww.w3.org%2f2001%2fXMLSchema%22+xmlns%3axsi%3d%22http%3a%2f%2fwww.w3.org%2f2001%2fXMLSchema-instance%22%3e%0a\
++%3cDataVersion%3e0%3c%2fDataVersion%3e%0a\
++%3cEnabled%3etrue%3c%2fEnabled%3e%0a\
++%3cInjectSettings%3e%0a\
++++%3cInjectSettings%3e%0a\
++++++%3cEnabled%3etrue%3c%2fEnabled%3e%0a\
++++++%3cPathAndFile%3e%2fdesktop.html%3c%2fPathAndFile%3e%0a\
++++++%3cInjectionLocation%3eBody%3c%2fInjectionLocation%3e%0a\
++++++%3cStart%3etrue%3c%2fStart%3e%0a\
++++++%3cFile%3e${INJECTIONFILE}%3c%2fFile%3e%0a\
++++%3c%2fInjectSettings%3e%0a\
++++%3cInjectSettings%3e%0a\
++++++%3cEnabled%3etrue%3c%2fEnabled%3e%0a\
++++++%3cPathAndFile%3e%2fmobile.html%3c%2fPathAndFile%3e%0a\
++++++%3cInjectionLocation%3eBody%3c%2fInjectionLocation%3e%0a\
++++++%3cStart%3etrue%3c%2fStart%3e%0a\
++++++%3cFile%3e${INJECTIONFILE}%3c%2fFile%3e%0a\
++++%3c%2fInjectSettings%3e%0a\
++%3c%2fInjectSettings%3e%0a\
++%3cDefaultInjectionFilesFolder%3e${INJECTIONFOLDER}%3c%2fDefaultInjectionFilesFolder%3e%0a\
++%3cSiteRootFolder%3e${SITEROOTFOLDER}%3c%2fSiteRootFolder%3e%0a\
++%3cResourceImagesFolder+%2f%3e%0a\
%3c%2fOptions%3e";  ERROREXIT 61 "Failed to create the CUSTOMCONTENTTEMPLATE variable!"
if ! [ -e "$PLUGINSCONFIGFILE" ]; then
   touch "$PLUGINSCONFIGFILE";  ERROREXIT 62 "Failed to create $PLUGINSCONFIGFILE!"
fi
if ! grep -q "VirtualRadar.Plugin.CustomContent.Options" "$PLUGINSCONFIGFILE"; then  # If no CustomContent setting is present at all, then create the setting from scratch.
   echo -e "$CUSTOMCONTENTTEMPLATE" >> "$PLUGINSCONFIGFILE";  ERROREXIT 63 "Failed to edit $PLUGINSCONFIGFILE!"
else
   sed -i -r "s/VirtualRadar\.Plugin\.CustomContent\.Options.*/$CUSTOMCONTENTTEMPLATE/" "$PLUGINSCONFIGFILE"; ERROREXIT 64 "Failed to edit $PLUGINSCONFIGFILE!"
fi


# Configure the Tile Server Cache Plugin to use the TILECACHEDIRECTORY directory.
TILECACHEPATH="${TILECACHEDIRECTORY//\//%2f}"; ERROREXIT 65 "Failed to create the $TILECACHEPATH variable!"  # Replace '/' with '%2f' HTML character code.
TILECACHETEMPLATE="\
VirtualRadar.Plugin.TileServerCache.Options=%7b%22DataVersion%22%3a0%2c\
%22IsPluginEnabled%22%3afalse%2c\
%22IsOfflineModeEnabled%22%3afalse%2c\
%22CacheFolderOverride%22%3a%22${TILECACHEPATH}%22%2c\
%22UseDefaultCacheFolder%22%3afalse%2c\
%22TileServerTimeoutSeconds%22%3a30%2c\
%22CacheMapTiles%22%3atrue%2c\
%22CacheLayerTiles%22%3atrue%7d";  ERROREXIT 66 "Failed to create the TILECACHETEMPLATE variable!"
if ! [ -e "$PLUGINSCONFIGFILE" ]; then
   touch "$PLUGINSCONFIGFILE";  ERROREXIT 67 "Failed to create $PLUGINSCONFIGFILE!"
fi
if ! grep -q "VirtualRadar.Plugin.TileServerCache.Options" "$PLUGINSCONFIGFILE"; then  # If no Tile Server Cache Plugin setting is present at all, then create the setting from scratch.
   echo -e "$TILECACHETEMPLATE" >> "$PLUGINSCONFIGFILE";  ERROREXIT 68 "Failed to edit $PLUGINSCONFIGFILE!"
else
   sed -i -r "s/VirtualRadar\.Plugin\.TileServerCache\.Options.*/$TILECACHETEMPLATE/" "$PLUGINSCONFIGFILE"; ERROREXIT 69 "Failed to edit $PLUGINSCONFIGFILE!"
fi


# Change global localization from 'en-GB' to a custom default localization (for example: 'en-US') defined earlier in the script.
cp "$VRSINSTALLDIRECTORY/Web/desktop.html"       "$CUSTOMWEBFILESDIRECTORY";            ERROREXIT 70 "Failed to copy $VRSINSTALLDIRECTORY/Web/desktop.html!"
cp "$VRSINSTALLDIRECTORY/Web/desktopReport.html" "$CUSTOMWEBFILESDIRECTORY";            ERROREXIT 71 "Failed to copy $VRSINSTALLDIRECTORY/Web/desktopReport.html!"
cp "$VRSINSTALLDIRECTORY/Web/mobile.html"        "$CUSTOMWEBFILESDIRECTORY";            ERROREXIT 72 "Failed to copy $VRSINSTALLDIRECTORY/Web//mobile.html!"
cp "$VRSINSTALLDIRECTORY/Web/mobileReport.html"  "$CUSTOMWEBFILESDIRECTORY";            ERROREXIT 73 "Failed to copy $VRSINSTALLDIRECTORY/Web/mobileReport.html!"
cp "$VRSINSTALLDIRECTORY/Web/fsx.html"           "$CUSTOMWEBFILESDIRECTORY";            ERROREXIT 74 "Failed to copy $VRSINSTALLDIRECTORY/Web/fsx.html!"
sed -i -e "s/'en-GB'/'$LOCALIZATION'/g" "$CUSTOMWEBFILESDIRECTORY/desktop.html";        ERROREXIT 75 "Failed to edit $CUSTOMWEBFILESDIRECTORY/desktop.html!"
sed -i -e "s/'en-GB'/'$LOCALIZATION'/g" "$CUSTOMWEBFILESDIRECTORY/desktopReport.html";  ERROREXIT 76 "Failed to edit $CUSTOMWEBFILESDIRECTORY/desktopReport.html!"
sed -i -e "s/'en-GB'/'$LOCALIZATION'/g" "$CUSTOMWEBFILESDIRECTORY/mobile.html";         ERROREXIT 77 "Failed to edit $CUSTOMWEBFILESDIRECTORY/mobile.html!"
sed -i -e "s/'en-GB'/'$LOCALIZATION'/g" "$CUSTOMWEBFILESDIRECTORY/mobileReport.html";   ERROREXIT 78 "Failed to edit $CUSTOMWEBFILESDIRECTORY/mobileReport.html!"
sed -i -e "s/'en-GB'/'$LOCALIZATION'/g" "$CUSTOMWEBFILESDIRECTORY/fsx.html";            ERROREXIT 79 "Failed to edit $CUSTOMWEBFILESDIRECTORY/fsx.html!"


# Create a script to help backup the database file. (A cron job can later be set to automatically run the script at any time interval.)
touch "$DATABASEBACKUPSCRIPT";                                                                     ERROREXIT 80 "Failed to create $DATABASEBACKUPSCRIPT!"
echo "#!/bin/bash"                                                     > "$DATABASEBACKUPSCRIPT";  ERROREXIT 81 "Failed to edit $DATABASEBACKUPSCRIPT!"
echo "# Use this script to routinely backup the VRS database file.\n" >> "$DATABASEBACKUPSCRIPT";  ERROREXIT 82 "Failed to edit $DATABASEBACKUPSCRIPT!"
echo "mkdir -p \"$DATABASEBACKUPDIRECTORY\""                          >> "$DATABASEBACKUPSCRIPT";  ERROREXIT 83 "Failed to edit $DATABASEBACKUPSCRIPT!"
echo "cp \"$DATABASEFILE\" \"$DATABASEBACKUPFILE\""                   >> "$DATABASEBACKUPSCRIPT";  ERROREXIT 84 "Failed to edit $DATABASEBACKUPSCRIPT!"
echo "exit"                                                           >> "$DATABASEBACKUPSCRIPT";  ERROREXIT 85 "Failed to edit $DATABASEBACKUPSCRIPT!"


# Create a script to use if desiring to autorun VRS.
touch "$AUTORUNSCRIPT";                                                            ERROREXIT 86 "Failed to create $AUTORUNSCRIPT!"
echo "#!/bin/bash"                                            > "$AUTORUNSCRIPT";  ERROREXIT 87 "Failed to edit $AUTORUNSCRIPT!"
echo "# Use this script in a cron job to autostart VRS."     >> "$AUTORUNSCRIPT";  ERROREXIT 88 "Failed to edit $AUTORUNSCRIPT!"
echo "mono \"$VRSINSTALLDIRECTORY/VirtualRadar.exe\" -nogui" >> "$AUTORUNSCRIPT";  ERROREXIT 89 "Failed to edit $AUTORUNSCRIPT!"
echo "exit"                                                  >> "$AUTORUNSCRIPT";  ERROREXIT 90 "Failed to edit $AUTORUNSCRIPT!"
chmod +x "$AUTORUNSCRIPT";                                                         ERROREXIT 91 "The 'chmod' command failed on $AUTORUNSCRIPT!"


# Function to copy any custom files user may have from a previous installation of VRS.
function COPYCUSTOMFILES {
   local FILE="$1"
   local FILENAME="$2"
   local DESTINATIONDIR="$3"
   cp "$FILE" "$DESTINATIONDIR"
   if [ $? -ne 0 ]; then printf "${RED_COLOR}Failed to copy %s!${NO_COLOR}\n"      "$FILENAME";
   else                  printf "'${GREEN_COLOR}%s' has been copied.${NO_COLOR}\n" "$FILENAME";
   fi
}


# Copy any custom files user may have alongside this script from a previous installation of VRS.  (Do this only if the '-ignore' parameter was not passed to this script.)
if [[ $IGNOREFILES -eq 0 ]]; then
   printf "\n"
   if [ -f "$SCRIPTDIR/$CONFIGURATIONFILENAME" ]; then COPYCUSTOMFILES "$SCRIPTDIR/$CONFIGURATIONFILENAME" "$CONFIGURATIONFILENAME" "$SHAREDIRECTORY"; fi
   if [ -f "$SCRIPTDIR/$PLUGINCONFIGFILENAME" ];  then COPYCUSTOMFILES "$SCRIPTDIR/$PLUGINCONFIGFILENAME"  "$PLUGINCONFIGFILENAME"  "$SHAREDIRECTORY"; fi
   # For safety reasons, prevent any possible existing database file from getting overwritten by an possibly older database file.  It is assumed that an existing database should not be overwritten.
   if ! [ -f "$DATABASEFILE" ] && [ -f "$SCRIPTDIR/$DATABASEFILENAME" ]; then COPYCUSTOMFILES "$SCRIPTDIR/$DATABASEFILENAME" "$DATABASEFILENAME" "$DATABASEDIRECTORY"; fi
fi


# Create a universal command to start VRS.
if ! [ -f "$STARTCOMMAND" ]; then sudo touch "$STARTCOMMAND"; fi;                    ERROREXIT 92  "Failed to create $STARTCOMMAND!"
sudo chmod 666 "$STARTCOMMAND";                                                      ERROREXIT 93  "The 'chmod' command failed on  $STARTCOMMAND!"
echo "#!/bin/bash"                                               > "$STARTCOMMAND";  ERROREXIT 94  "Failed to edit $STARTCOMMAND!"
echo "# Use this script as a global command to start VRS."      >> "$STARTCOMMAND";  ERROREXIT 95  "Failed to edit $STARTCOMMAND!"
echo "if [[ \$DISPLAY == \"\" ]]; then"                         >> "$STARTCOMMAND";  ERROREXIT 96  "Failed to edit $STARTCOMMAND!"
echo "   mono \"$VRSINSTALLDIRECTORY/VirtualRadar.exe\" -nogui" >> "$STARTCOMMAND";  ERROREXIT 97  "Failed to edit $STARTCOMMAND!"
echo "else"                                                     >> "$STARTCOMMAND";  ERROREXIT 98  "Failed to edit $STARTCOMMAND!"
echo "   mono \"$VRSINSTALLDIRECTORY/VirtualRadar.exe\" \$1"    >> "$STARTCOMMAND";  ERROREXIT 99  "Failed to edit $STARTCOMMAND!"
echo "fi"                                                       >> "$STARTCOMMAND";  ERROREXIT 100 "Failed to edit $STARTCOMMAND!"
echo "exit"                                                     >> "$STARTCOMMAND";  ERROREXIT 101 "Failed to edit $STARTCOMMAND!"
sudo chmod 755 "$STARTCOMMAND";                                                      ERROREXIT 102 "The 'chmod' command failed on  $STARTCOMMAND!"
sudo chown root:root "$STARTCOMMAND";                                                ERROREXIT 103 "The 'chown' command failed on  $STARTCOMMAND!"


######################################################################################################
###################################   Print helpful instructions   ###################################
######################################################################################################


printf "\n\n"
printf "${GREEN_COLOR}%s${NO_COLOR}\n"  "-----------------------"
printf "${GREEN_COLOR}HELPFUL THINGS TO KNOW:${NO_COLOR}\n"
printf "${GREEN_COLOR}%s${NO_COLOR}\n\n" "-----------------------"

printf "${ORANGE_COLOR}VRS was installed here:${NO_COLOR}  %s\n"
printf "   %s\n\n" "$VRSINSTALLDIRECTORY"

printf "${ORANGE_COLOR}VRS user custom files/directories may be found here:${NO_COLOR}\n"
printf "   %s\n\n" "$EXTRASDIRECTORY"

printf "${ORANGE_COLOR}Future installations of VRS:${NO_COLOR}\n"
printf "  After VRS has been fully configured, save these three files for future\n"
printf "  use with this script so this script can automatically configure VRS.\n"
printf "  If any of these files are present along with this installation script,\n"
printf "  the script will automatically incorporate these files so that VRS will\n"
printf "  be up and running with the same configuration as the previous installation.\n"
printf "    ${BLUE_COLOR}*${NO_COLOR} %s\n"   "$CONFIGFILE"
printf "    ${BLUE_COLOR}*${NO_COLOR} %s\n"   "$PLUGINSCONFIGFILE"
printf "    ${BLUE_COLOR}*${NO_COLOR} %s\n\n" "$DATABASEFILE"

if [ -f "$DATABASEBACKUPSCRIPT" ]; then
   printf "${ORANGE_COLOR}A cron job may be set to routinely backup the database file:${NO_COLOR}\n"
   printf "  Use this command to set up a cron job:   crontab -e\n"
   printf "  The cron job will then utilize this following command:\n"
   printf "    bash \"$DATABASEBACKUPSCRIPT\"\n\n"
   printf "${ORANGE_COLOR}The database backup file will be:${NO_COLOR}\n"
   printf "  %s\n\n" "$DATABASEBACKUPFILE"
fi

if [ -f "$AUTORUNSCRIPT" ]; then
   printf "${ORANGE_COLOR}A cron job may be set to autorun VRS at system boot:${NO_COLOR}\n"
   printf "  Use this command to set up a cron job:   crontab -e\n"
   printf "  Use this entire line for the cron job:\n"
   printf "    @reboot \"$AUTORUNSCRIPT\"\n\n"
fi

printf "${ORANGE_COLOR}To view the VRS map:${NO_COLOR}\n"
if [[ $DISPLAY == "" ]]; then
   printf "  View VRS on local network:  http://%s:%s/VirtualRadar\n\n" $LOCALIP $PORT
else
   printf "  View VRS on this machine:   http://127.0.0.1:%s/VirtualRadar\n" $PORT
   printf "  View VRS on local network:  http://%s:%s/VirtualRadar\n\n" $LOCALIP $PORT
fi

printf "${ORANGE_COLOR}To access the optional Web Admin GUI on a local network device:${NO_COLOR}\n"
printf "  http://%s:%s/VirtualRadar/WebAdmin/Index.html\n\n" $LOCALIP $PORT

printf "${ORANGE_COLOR}Use this command to start VRS:${NO_COLOR}  %s\n\n" "$STARTCOMMANDFILENAME"

printf "${ORANGE_COLOR}More detailed information regarding this installation script here:${NO_COLOR}\n"
printf "  https://github.com/mypiaware/virtual-radar-server-installation/blob/master/README.md\n\n"

# Provide option to start VRS now, set Web Admin username/password, or exit.
printf "\n"
printf "${GREEN_COLOR}Virtual Radar Server installation is complete!${NO_COLOR}\n"
printf "What would you like to do?:\n"
printf " 1. Start VRS now\n"
if [[ $DISPLAY == "" ]]; then
   printf " 2. Create username & password for the VRS Web Admin & start VRS Web Admin\n"
   printf " 3. Exit\n\n"
   while ! [[ $OPTION =~ ^[123]$ ]]; do printf "Enter choice: "; read -r OPTION; done
   if [[ $OPTION =~ 1 ]]; then mono "$VRSINSTALLDIRECTORY/VirtualRadar.exe" -nogui
   elif [[ $OPTION =~ 2 ]]; then
      while [[ ${#USERNAME[@]} -ne 1 && USERNAME[0] != "" ]]; do printf "Create Web Admin username: "; read -r -a USERNAME; done
      while [[ ${#PASSWORD[@]} -ne 1 && PASSWORD[0] != "" ]]; do printf "Create Web Admin password: "; read -r -a PASSWORD; done
      printf "\nAccess the VRS Web Admin on a local device with this URL:\n   http://%s:%s/VirtualRadar/WebAdmin/Index.html\n\n" $LOCALIP $PORT
      mono "$VRSINSTALLDIRECTORY/VirtualRadar.exe" -nogui -createAdmin:$USERNAME -password:$PASSWORD
   elif [[ $OPTION =~ 3 ]]; then exit 0;
   fi
else
   printf " 2. Exit\n\n"
   while ! [[ $OPTION =~ ^[12]$ ]]; do printf "Enter choice: "; read -r OPTION; done
   if   [[ $OPTION =~ 1 ]]; then mono "$VRSINSTALLDIRECTORY/VirtualRadar.exe"
   elif [[ $OPTION =~ 2 ]]; then exit 0;
   fi
fi


exit 0
