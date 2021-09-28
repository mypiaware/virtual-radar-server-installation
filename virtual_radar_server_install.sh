#!/bin/bash
#
# Virtual Radar Server installation script (ver 11.3)
# VRS Homepage:  http://www.virtualradarserver.co.uk
#
# VERY BRIEF SUMMARY OF THIS SCRIPT:
#
# This script helps the novice user to install VRS and have VRS up and running.
# With just a few keystrokes, VRS (& Mono) may get installed and start displaying planes on the VRS webpage.
# Operator flags, silhouette flags and a few sample aircraft photos may also be downloaded and installed.
# A sample database file consisting of more detailed information of a few planes may also be downloaded and installed.
# As an option, the user may also enter the latitude and longitude of the center of the VRS webpage map.
# As an option, the user may also enter a receiver.
# A watchdog script will be created as an option to ensure VRS is always running.
# A directory structure will be created for the convenience of those who wish to enhance the appearance and performance of VRS.
#
# This script has been confirmed to allow VRS version 2.4.4 (the latest stable release) to successfully run on:
#   Raspberry Pi OS Buster (32-bit -- Desktop & Lite), Debian, Fedora, openSUSE, MX Linux (if systemd is enabled), elementary OS, Manjaro and Arch Linux.
# Note that Raspberry Pi OS was recently known as Raspbian.
# An option is available to download and install a preview version of VRS.
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
EXTRASDIRECTORY="$VRSROOTDIRECTORY/VRS-Extras"        # An arbitrary root directory for all extra VRS files (custom web files, database file, operator flags, silhouettes, tile cache, etc.)

SHAREDIRECTORY="$HOMEDIR/.local/share/VirtualRadar"        # The location and name of the directory to hold customization files.  (This value should not be changed.)
CONFIGFILE="$SHAREDIRECTORY/$CONFIGURATIONFILENAME"        # The location and name of the main configuration file.  (This value should not be changed.)
PLUGINSCONFIGFILE="$SHAREDIRECTORY/$PLUGINCONFIGFILENAME"  # The location and name of the plugins configuration file.  (This value should not be changed.)

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

DATABASEFILE="$DATABASEDIRECTORY/$DATABASEFILENAME"                   # An arbitrary location and name for the SQLite database file.
DATABASEBACKUPSCRIPT="$DATABASEBACKUPDIRECTORY/backupvrsdb.sh"        # An arbitrary location and name of the database file backup script.
DATABASEBACKUPFILE="$DATABASEBACKUPDIRECTORY/BaseStation_BACKUP.sqb"  # An arbitrary location and name of the database file's backup file.

VRSWATCHDOGDIRECTORY="$EXTRASDIRECTORY/Watchdog"     # An arbitrary directory to hold the VRS watchdog script.
VRSWATCHDOGFILENAME="vrs_watchdog.sh"                # An arbitrary filename of the VRS watchdog script.
VRSWATCHDOGLOGDIRECTORY="$EXTRASDIRECTORY/Watchdog"  # An arbitrary directory to hold the log file created by the VRS watchdog script.
VRSWATCHDOGLOGFILENAME="vrs_watchdog.log"            # An arbitrary filename of the log file created by the VRS watchdog script.

STARTCOMMANDDIR="/usr/local/bin"                       # The location of the universal command to start VRS.  (This value should not be changed.)
STARTCOMMANDFILENAME="vrs"                             # An arbitrary simple filename of the universal command to start VRS.
STARTCOMMAND="$STARTCOMMANDDIR/$STARTCOMMANDFILENAME"  # The full path of the VRS start command.

SERVICEDIR="/etc/systemd/system"                      # Directory to store service file to run VRS in the background.  (This value should not be changed.)
SERVICEFILENAME="vrs"                                 # An arbitrary name of the service file to run VRS in the background.
SERVICEFILE="$SERVICEDIR/${SERVICEFILENAME}.service"  # The full path of the service file to run VRS in the background.

AIRCRAFTMARKERDIR="$CUSTOMWEBFILESDIRECTORY/images/markers"  # Directory to store updated aircraft markers.  (This value should not be changed.)

TEMPDIR="/tmp/vrs"  # An arbitrary directory where downloaded files are kept.


# List of all possible directories that will need to be created.
VRSDIRECTORIES=(
   "$VRSROOTDIRECTORY"
   "$VRSINSTALLDIRECTORY"
   "$EXTRASDIRECTORY"
   "$SHAREDIRECTORY"
   "$OPFLAGSDIRECTORY"
   "$PICTURESDIRECTORY"
   "$SILHOUETTESDIRECTORY"
   "$TILECACHEDIRECTORY"
   "$CUSTOMCONTENTPLUGINDIRECTORY"
   "$CUSTOMINJECTEDFILESDIRECTORY"
   "$CUSTOMWEBFILESDIRECTORY"
   "$DATABASEMAINDIRECTORY"
   "$DATABASEDIRECTORY"
   "$DATABASEBACKUPDIRECTORY"
   "$VRSWATCHDOGDIRECTORY"
   "$VRSWATCHDOGLOGDIRECTORY"
   "$TEMPDIR"
)


# Declare an array of URLs for all the VRS files of the stable version of VRS.
VRSFILES_STABLE=(
   "http://www.virtualradarserver.co.uk/Files/VirtualRadar.LanguagePack.tar.gz"  # Install language pack files first because the 'VirtualRadar.WebSite.resources.dll' file may be newer in the 'VirtualRadar.tar.gz' file.
   "http://www.virtualradarserver.co.uk/Files/VirtualRadar.tar.gz"
   "http://www.virtualradarserver.co.uk/Files/VirtualRadar.exe.config.tar.gz"
   "http://www.virtualradarserver.co.uk/Files/VirtualRadar.CustomContentPlugin.tar.gz"
   "http://www.virtualradarserver.co.uk/Files/VirtualRadar.DatabaseEditorPlugin.tar.gz"
   "http://www.virtualradarserver.co.uk/Files/VirtualRadar.DatabaseWriterPlugin.tar.gz"
   "http://www.virtualradarserver.co.uk/Files/VirtualRadar.TileServerCachePlugin.tar.gz"
   "http://www.virtualradarserver.co.uk/Files/VirtualRadar.WebAdminPlugin.tar.gz"
)


declare VRS_VERSION  # Declare a global variable that will hold user's choice of whether to install the stable or preview version.
declare LIBPNG_FIX   # Declare a global variable that will hold user's choice of whether or not to apply the 'libpng warning' fix.
declare PREVIEW245   # Declare a global variable that will hold the VRS preview 2.4.5 sub-version.
declare PREVIEW300   # Declare a global variable that will hold the VRS preview 3.0.0 sub-version.


function PREVIEW_URLS {  # These arrays must be in a function because it is not until later in the script when the variables in these URLs will be defined.
   # Declare an array of URLs for all the VRS files of the preview version (2.4.5) of VRS.  Very important to know this preview version is under testing and may have bugs.
   VRSFILES_PREVIEW245=(
      "https://github.com/vradarserver/vrs/releases/download/v2.4.5-preview-${PREVIEW245}-mono/VirtualRadar-2.4.5-preview-${PREVIEW245}.tar.gz"
      "https://github.com/vradarserver/vrs/releases/download/v2.4.5-preview-${PREVIEW245}-mono/LanguagePack-2.4.5-preview-${PREVIEW245}.tar.gz"
      "https://github.com/vradarserver/vrs/releases/download/v2.4.5-preview-${PREVIEW245}-mono/Plugin-CustomContent-2.4.5-preview-${PREVIEW245}.tar.gz"
      "https://github.com/vradarserver/vrs/releases/download/v2.4.5-preview-${PREVIEW245}-mono/Plugin-DatabaseEditor-2.4.5-preview-${PREVIEW245}.tar.gz"
      "https://github.com/vradarserver/vrs/releases/download/v2.4.5-preview-${PREVIEW245}-mono/Plugin-DatabaseWriter-2.4.5-preview-${PREVIEW245}.tar.gz"
      "https://github.com/vradarserver/vrs/releases/download/v2.4.5-preview-${PREVIEW245}-mono/Plugin-FeedFilter-2.4.5-preview-${PREVIEW245}.tar.gz"
      "https://github.com/vradarserver/vrs/releases/download/v2.4.5-preview-${PREVIEW245}-mono/Plugin-TileServerCache-2.4.5-preview-${PREVIEW245}.tar.gz"
      "https://github.com/vradarserver/vrs/releases/download/v2.4.5-preview-${PREVIEW245}-mono/Plugin-WebAdmin-2.4.5-preview-${PREVIEW245}.tar.gz"
      "http://www.virtualradarserver.co.uk/Files/VirtualRadar.exe.config.tar.gz"
   )
   # Declare an array of URLs for all the VRS files of the preview version (3.0.0) of VRS.  Very important to know this preview version is under testing and may have bugs.
   VRSFILES_PREVIEW300=(
      "https://github.com/vradarserver/vrs/releases/download/v3.0.0-preview-${PREVIEW300}-mono/VirtualRadar-3.0.0-preview-${PREVIEW300}.tar.gz"
      "https://github.com/vradarserver/vrs/releases/download/v3.0.0-preview-${PREVIEW300}-mono/LanguagePack-3.0.0-preview-${PREVIEW300}.tar.gz"
      "https://github.com/vradarserver/vrs/releases/download/v3.0.0-preview-${PREVIEW300}-mono/Plugin-CustomContent-3.0.0-preview-${PREVIEW300}.tar.gz"
      "https://github.com/vradarserver/vrs/releases/download/v3.0.0-preview-${PREVIEW300}-mono/Plugin-DatabaseEditor-3.0.0-preview-${PREVIEW300}.tar.gz"
      "https://github.com/vradarserver/vrs/releases/download/v3.0.0-preview-${PREVIEW300}-mono/Plugin-DatabaseWriter-3.0.0-preview-${PREVIEW300}.tar.gz"
      "https://github.com/vradarserver/vrs/releases/download/v3.0.0-preview-${PREVIEW300}-mono/Plugin-FeedFilter-3.0.0-preview-${PREVIEW300}.tar.gz"
      "https://github.com/vradarserver/vrs/releases/download/v3.0.0-preview-${PREVIEW300}-mono/Plugin-SqlServer-3.0.0-preview-${PREVIEW300}.tar.gz"
      "https://github.com/vradarserver/vrs/releases/download/v3.0.0-preview-${PREVIEW300}-mono/Plugin-TileServerCache-3.0.0-preview-${PREVIEW300}.tar.gz"
      "https://github.com/vradarserver/vrs/releases/download/v3.0.0-preview-${PREVIEW300}-mono/Plugin-WebAdmin-3.0.0-preview-${PREVIEW300}.tar.gz"
   )
}


# Declare URLs for operator flags, silhouettes and a database file. (Change any URL if better files are found elsewhere.)
OPFLAGSURL="http://www.woodair.net/SBS/Download/LOGO.zip"
SILHOUETTESURL="http://www.kinetic.co.uk/repo/SilhouettesLogos.zip"
DATABASEURL="https://github.com/mypiaware/virtual-radar-server-installation/raw/master/Downloads/Database/BaseStation.sqb"
PICTURESURL="https://github.com/mypiaware/virtual-radar-server-installation/raw/master/Downloads/Pictures/Pictures.zip"


# Declare URLs for updated aircraft markers.
AIRCRAFTMARKERURL_1="https://github.com/mypiaware/virtual-radar-server-installation/raw/master/Downloads/AircraftMarkers/Airplane.png"
AIRCRAFTMARKERURL_2="https://github.com/mypiaware/virtual-radar-server-installation/raw/master/Downloads/AircraftMarkers/AirplaneSelected.png"


# Declare a default port value. (User is given a choice to change it.  If a port has already been set from a previous installation, then set the already existing port value as the default.)
DEFAULTPORT="8090"
if [ -f "$SHAREDIRECTORY/$INSTALLERCONFIGFILENAME" ]; then
   EXISTINGPORT=$(<"$SHAREDIRECTORY/$INSTALLERCONFIGFILENAME")
   if [[ $EXISTINGPORT =~ \<WebServerPort\>([[:digit:]]+)\</WebServerPort\> ]]; then
      DEFAULTPORT=${BASH_REMATCH[1]}
   fi
fi


# Options for the VRS command.
VRSCMD_GUI="gui"
VRSCMD_NOGUI="nogui"
VRSCMD_STARTPROCESS="startbg"
VRSCMD_STOPPROCESS="stopbg"
VRSCMD_ENABLE="enable"
VRSCMD_DISABLE="disable"
VRSCMD_WEBADMIN="webadmin"
VRSCMD_LOG="log"


# Get the local IP address of this machine.
declare LOCALIP
LOCALIP=$(ip route get 1.2.3.4 | awk '{printf "%s",$7}')
if [[ "$LOCALIP" =~ ([[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}) ]]; then
   LOCALIP=${BASH_REMATCH[1]}
else
   printf "\n\nWarning! Could not determine local IP address!\n"
fi


# Determine the location of 'bash'.
declare BASHLOCATION
BASHLOCATION="$(which bash)"


# Just to give some color to some text.
BOLD_FONT='\033[1m'
RED_COLOR='\033[1;31m'
GREEN_COLOR='\033[1;32m'
ORANGE_COLOR='\033[0;33m'
BLUE_COLOR='\033[1;34m'
CYAN_COLOR='\033[0;36m'
NO_COLOR='\033[0m'


# Determine operating system.
declare OPERATINGSYSTEMVERSION  # Declare a global variable that will hold the version of the operating system.
if grep -qEi 'opensuse' /etc/os-release; then
   OPERATINGSYSTEMVERSION="opensuse"
elif grep -qEi 'CentOS Stream 8' /etc/os-release; then
   OPERATINGSYSTEMVERSION="centos8"
elif grep -qEi 'fedora' /etc/os-release; then
   OPERATINGSYSTEMVERSION="fedora"
elif grep -qEi 'manjaro' /etc/os-release; then
   OPERATINGSYSTEMVERSION="manjaro"
elif grep -qEi 'arch linux' /etc/os-release; then
   OPERATINGSYSTEMVERSION="archlinux"
elif grep -qEi 'elementary OS' /etc/os-release; then
   OPERATINGSYSTEMVERSION="elementaryos"
elif grep -qEi 'debian|buntu' /etc/os-release; then
   OPERATINGSYSTEMVERSION="debian"
else OPERATINGSYSTEMVERSION="unknown"
fi


# If VRS is installed on Raspberry Pi OS, then it is not necessary to use 'sudo crontab -e', but 'crontab -e' can simply be used instead.
if grep -qEi 'ID=raspb' /etc/os-release; then CRONCMD="crontab -e"; else CRONCMD="sudo crontab -e"; fi


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


# Immediately stop the script only if the operating system could not be determined AND Mono and/or other necessary software are not already installed.
if ! which mono >/dev/null 2>&1 || ! which unzip >/dev/null 2>&1; then
   if [[ $OPERATINGSYSTEMVERSION == "unknown" ]]; then
      printf "${RED_COLOR}FATAL ERROR! This operating system is not yet supported or identified!${NO_COLOR}\n"
      printf "Try installing Mono and/or unzip manually and then rerun this script again.\n"
      printf "More help:\n"
      printf "https://github.com/mypiaware/virtual-radar-server-installation#advanced-users\n"
      exit 1
   fi
fi


# Check if this script is ran as root. (It should not be ran as root.)
if [[ $EUID == 0 ]]; then
   printf "Do NOT run this script as root! (Do not use 'sudo' in the command.)\n"
   exit 2
fi


# Print welcome screen.
printf "\n${BLUE_COLOR}"
printf "%0.s_" {1..64}
printf "\n\n"
printf " Virtual Radar Server\n"
printf " http://www.virtualradarserver.co.uk\n\n"
printf "${NO_COLOR}${BOLD_FONT}"
printf "This script downloads & installs:\n"
printf "  * Virtual Radar Server\n"
printf "  * Mono (and VRS Mono fix)\n"
printf "  * Language Packs\n"
printf "  * Custom Content Plugin\n"
printf "  * Database Editor Plugin\n"
printf "  * Database Writer Plugin\n"
printf "  * Tile Server Cache Plugin\n"
printf "  * Web Admin Plugin\n"
printf "  * Feed Filter Plugin${NO_COLOR} (only with either preview version of VRS)${BOLD_FONT}\n"
printf "  * SQLServer Plugin${NO_COLOR} (only with preview version 3.0.0 of VRS)\n\n"
printf "Need help with this installation script?:\n"
printf "https://github.com/mypiaware/virtual-radar-server-installation\n\n"


# User should press [Enter] key to begin.
printf "${GREEN_COLOR}Press [ENTER] to continue...${NO_COLOR}"; read -p ""
printf "\n"


# Check which - if any - preview versions are available.
declare PREVIEW_AVAILABLE
printf "Checking for the latest available preview versions of VRS..."
if ! which wget >/dev/null 2>&1; then printf "\n${RED_COLOR}FATAL ERROR! The program 'wget' needs to be installed before continuing!${NO_COLOR}\n"; exit 3; fi
LIMITCHECK=10  # To be safe, this value should be at least +5 the 'INITIALCHECK' value below.
INITIALCHECK=5
for (( PREVIEW245=$INITIALCHECK; PREVIEW245<=$LIMITCHECK; PREVIEW245++ )); do
   PREVIEW_URLS  # Calling this function simply fills in the variable values that are in the URLs.
   URLTOCHECK="${VRSFILES_PREVIEW245[0]}"  # Checking just the first element in the array should suffice.
   wget --spider $URLTOCHECK >/dev/null 2>&1  # Not downloading, but simply checking if the URL exists.
   if [[ $? -eq 0 ]]; then PREVIEW_AVAILABLE=1; break; fi
   if [[ $PREVIEW245 -eq $LIMITCHECK ]]; then PREVIEW_AVAILABLE=0; break; fi
done
if [[ $PREVIEW_AVAILABLE =~ [1] ]]; then  # Only check for the other preview version if the first preview version was found.
   LIMITCHECK=11  # To be safe, this value should be at least +5 the 'INITIALCHECK' value below.
   INITIALCHECK=6
   for (( PREVIEW300=$INITIALCHECK; PREVIEW300<=$LIMITCHECK; PREVIEW300++ )); do
      PREVIEW_URLS  # Calling this function simply fills in the variable values that are in the URLs.
      URLTOCHECK="${VRSFILES_PREVIEW300[0]}"  # Checking just the first element in the array should suffice.
      wget --spider $URLTOCHECK >/dev/null 2>&1  # Not downloading, but simply checking if the URL exists.
      if [[ $? -eq 0 ]]; then PREVIEW_AVAILABLE=1; break; fi
      if [[ $PREVIEW300 -eq $LIMITCHECK ]]; then PREVIEW_AVAILABLE=0; break; fi
   done
fi
printf "\n\n"


# This is used in two places below.
function STABLE_CHOSEN {
   VRS_VERSION="Stable (2.4.4)"
   VRSFILES=("${VRSFILES_STABLE[@]}")
   printf "Version set to install:  ${ORANGE_COLOR}$VRS_VERSION${NO_COLOR}\n"
}


# Report and possibly end script if a preview version was unable to be determined.
if [[ $PREVIEW_AVAILABLE =~ [0] ]]; then
   printf "${RED_COLOR}Unable to determine available preview versions!${NO_COLOR}\n"
   while ! [[ $ONLYSTABLE =~ ^[YyNn]$ ]]; do printf "Continue by installing the stable version? [y/n]: "; read ONLYSTABLE; done  # Use 'ONLYSTABLE' variable in a section below.
   printf "\n"
   if   [[ $ONLYSTABLE =~ [Yy] ]]; then
      STABLE_CHOSEN
   elif [[ $ONLYSTABLE =~ [Nn] ]]; then
      printf "Maybe wait later for preview versions to become available.\n"
      printf "Or, wait until a fix to this script can be made.\n"
      exit 4
   fi
fi


# Prompt user to either install the latest stable version or the preview version.  (Only if preview versions are available.)
if [[ $PREVIEW_AVAILABLE =~ [1] ]]; then  # Only run this portion if the preview versions have been identified.
   PREVIEW_URLS  # Call the function above to complete the URLs for the preview files now that the preview sub-version variables ('PREVIEW245' & 'PREVIEW300') have been determined.
   printf "Install a stable or a preview version of VRS?\n";
   printf "  1. Stable (ver 2.4.4)\n"
   printf "  2. Preview (ver 2.4.5-preview-$PREVIEW245)\n"
   printf "  3. Preview (ver 3.0.0-preview-$PREVIEW300)\n"
   while ! [[ $VRS_CHOICE =~ ^[123]$ ]]; do printf "Choice [123]: "; read VRS_CHOICE; done
   printf "\n"
   if [[ $VRS_CHOICE =~ 1 ]]; then
      STABLE_CHOSEN
   elif [[ $VRS_CHOICE =~ [23] ]]; then
      if [[ $VRS_CHOICE =~ 2 ]]; then
         VRS_VERSION="Preview (ver 2.4.5-preview-$PREVIEW245)"
         VRSFILES=("${VRSFILES_PREVIEW245[@]}")
      elif [[ $VRS_CHOICE =~ 3 ]]; then
         VRS_VERSION="Preview (ver 3.0.0-preview-$PREVIEW300)"
         VRSFILES=("${VRSFILES_PREVIEW300[@]}")
      fi
      printf "Version set to install:  ${ORANGE_COLOR}$VRS_VERSION${NO_COLOR}\n\n"
      printf "${RED_COLOR}"
      printf " *************************** WARNING ****************************\n"
      printf "          A preview version has been selected to install.\n"
      printf "     The preview version is under testing and may contain bugs!\n"
      printf " Please consider this when choosing to install a preview version.\n"
      printf " *************************** WARNING ****************************\n"
      printf "${NO_COLOR}"
   fi
fi
printf "\n"


# Prompt user if the following sample files should be downloaded:  Operator Flags, Silhouettes, sample Pictures and a database file.
while ! [[ $DL_OPF =~ ^[YyNn]$ ]]; do printf "Download & install operator flags (airline logos)? [yn]: "; read DL_OPF; done
while ! [[ $DL_SIL =~ ^[YyNn]$ ]]; do printf "Download & install silhouettes? [yn]: ";                    read DL_SIL; done
while ! [[ $DL_PIC =~ ^[YyNn]$ ]]; do printf "Download & install pictures? [yn]: ";                       read DL_PIC; done
# For safety reasons, prevent any possible existing database file from getting overwritten by a possibly older database file.  It is assumed that an existing database should not be overwritten.
if [[ ! -f "$DATABASEFILE" ]]; then
   while ! [[ $DL_DB =~ ^[YyNn]$ ]]; do printf "Download & install a sample database? [yn]: "; read DL_DB; done
fi
printf "\n"


# Prompt user if wanting a fix for the 'libpng warning' messages for the stable version.
if [[ $VRS_VERSION =~ "Stable" ]]; then
   printf "Apply 'libpng warning' message fix? (Recommended)\n"
   while ! [[ $LIBPNG_FIX =~ ^[YyNn]$ ]]; do printf "Choice [yn]: "; read LIBPNG_FIX; done
   printf "\n'libpng warning' fix selection:  "
   if [[ $LIBPNG_FIX =~ [Yy] ]]; then printf "${ORANGE_COLOR}Yes${NO_COLOR}\n"
   else                               printf "${ORANGE_COLOR}No${NO_COLOR}\n"
   fi
   printf "\n"
fi


# Prompt user for a port number VRS should use.
printf "Enter a port number for the Virtual Radar Server to use.\n"
printf "(Press [ENTER] to accept the default value of %s.)\n" $DEFAULTPORT
printf "  Port Number: "; read VRSPORT;
until [[ $VRSPORT == "" || ( $VRSPORT =~ ^\s*([1-9][0-9]{1,4})\s*$ && $VRSPORT -le 65535 ) ]]; do printf "  Port Number: "; read -r VRSPORT; done
VRSPORT=${BASH_REMATCH[1]}
if [[ $VRSPORT == "" ]]; then VRSPORT=$DEFAULTPORT; fi
printf "\nPort Number Selected: ${ORANGE_COLOR}%s${NO_COLOR}\n\n" $VRSPORT


# Offer a choice for localization of the VRS webpages.
printf "Select the default language to be displayed in the VRS webpages:\n\n"
PS3='Please choose the language of preference: '
LOCALE_CHOICES=("Chinese (China)" "English (Australia)" "English (Belize)" "English (Canada)" "English (Caribbean)" "English (India)"
"English (Ireland)" "English (Jamaica)" "English (Malaysia)" "English (New Zealand)" "English (Singapore)" "English (South Africa)"
"English (Trinidad and Tobago)" "English (United Kingdom)" "English (United States)" "French (Belgium)" "French (Canada)" "French (France)"
"French (Luxembourg)" "French (Monaco)" "French (Switzerland)" "German (Germany)" "Portuguese (Brazil)" "Russian (Russia)")
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


# Add option for user to enter a receiver.
printf "OPTIONAL: Enter receiver information.\n"
while ! [[ $ENTER_RECEIVER =~ ^[YyNn]$ ]]; do printf "Do you wish to add a receiver? [yn]: "; read ENTER_RECEIVER; done
if [[ $ENTER_RECEIVER =~ [Yy] ]]; then
   shopt -s nocasematch  # Make REGEX case insensitive
   while true; do
      while ! [[ $RECEIVER_NAME_ENTRY =~ ^\s*(([^[:space:]]|[ ]){1,50})\s*$ ]]; do printf "  Enter Receiver Name: "; read RECEIVER_NAME_ENTRY; done
      if [[ -f "$CONFIGFILE" ]]; then
         CONFIGTEXT=$(<"$CONFIGFILE")
         if [[ $CONFIGTEXT =~ \<Receiver\>.*\<Name\>$RECEIVER_NAME_ENTRY\</Name\>.*\</Receiver\> ]]; then
            printf "${RED_COLOR}Receiver name already exists!${NO_COLOR}\n"
            RECEIVER_NAME_ENTRY=""
         else
            break;
         fi
      else
         break
      fi
   done
   shopt -u nocasematch  # Return REGEX case to sensitive
   printf "  Choose the type of data source:\n"
   printf "      1. AVR or Beast Raw Feed\n"
   printf "      2. BaseStation\n"
   printf "      3. Compressed VRS\n"
   printf "      4. Aircraft List (JSON)\n"
   printf "      5. Plane Finder Radar\n"
   printf "      6. SBS-3 Raw Feed\n"
   while ! [[ $RECEIVER_SOURCE_SELECTION =~ ^\s*([1-6])\s*$ ]]; do printf "    Enter Selection [1-6]: "; read RECEIVER_SOURCE_SELECTION; done
   RECEIVER_SOURCE_SELECTION=${BASH_REMATCH[1]}
   if [[ $RECEIVER_SOURCE_SELECTION == 1 ]]; then RECEIVER_SOURCE_ENTRY="AVR or Beast Raw Feed"; fi
   if [[ $RECEIVER_SOURCE_SELECTION == 2 ]]; then RECEIVER_SOURCE_ENTRY="BaseStation"; fi
   if [[ $RECEIVER_SOURCE_SELECTION == 3 ]]; then RECEIVER_SOURCE_ENTRY="Compressed VRS"; fi
   if [[ $RECEIVER_SOURCE_SELECTION == 4 ]]; then RECEIVER_SOURCE_ENTRY="Aircraft List (JSON)"; fi
   if [[ $RECEIVER_SOURCE_SELECTION == 5 ]]; then RECEIVER_SOURCE_ENTRY="Plane Finder Radar"; fi
   if [[ $RECEIVER_SOURCE_SELECTION == 6 ]]; then RECEIVER_SOURCE_ENTRY="SBS-3 Raw Feed"; fi
   while true; do
      while ! [[ $RECEIVER_ADDRESS_ENTRY =~ ^\s*([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})\s*$ ]]; do printf "  Enter Receiver IP Address: "; read RECEIVER_ADDRESS_ENTRY; done
      RECEIVER_ADDRESS_ENTRY=${BASH_REMATCH[1]}
      while ! [[ $RECEIVER_PORT_ENTRY =~ ^\s*([1-9][0-9]{1,4})\s*$ && $RECEIVER_PORT_ENTRY -le 65535 ]]; do printf "  Enter Receiver IP Port: "; read RECEIVER_PORT_ENTRY; done
      RECEIVER_PORT_ENTRY=${BASH_REMATCH[1]}
      #  This is a little sloppy because BASH REGEX can only be greedy!  But, this *should* be good enough assuming there will always be an 'Address' & 'Port' entry in this order for every receiver.
      if [[ $CONFIGTEXT =~ \<Receiver\>.*\<Address\>$RECEIVER_ADDRESS_ENTRY\</Address\>[[:space:]]*\<Port\>$RECEIVER_PORT_ENTRY\</Port\>.*\</Receiver\> ]]; then
         printf "${RED_COLOR}A receiver is already configured to use: $RECEIVER_ADDRESS_ENTRY:$RECEIVER_PORT_ENTRY${NO_COLOR}\n"
         RECEIVER_ADDRESS_ENTRY=""
         RECEIVER_PORT_ENTRY=""
      else
         break;
      fi
   done
   printf "\n"
   printf "Receiver name:         ${ORANGE_COLOR}%s${NO_COLOR}\n" "$RECEIVER_NAME_ENTRY"
   printf "Receiver source type:  ${ORANGE_COLOR}%s${NO_COLOR}\n" "$RECEIVER_SOURCE_ENTRY"
   printf "Receiver address:      ${ORANGE_COLOR}%s${NO_COLOR}\n" "$RECEIVER_ADDRESS_ENTRY"
   printf "Receiver port:         ${ORANGE_COLOR}%s${NO_COLOR}\n" "$RECEIVER_PORT_ENTRY"
   # The "Configuration.xml" file will need the source type entered as such:
   if [[ $RECEIVER_SOURCE_SELECTION == 1 ]]; then RECEIVER_SOURCE_ENTRY="Beast"; fi
   if [[ $RECEIVER_SOURCE_SELECTION == 2 ]]; then RECEIVER_SOURCE_ENTRY="Port30003"; fi
   if [[ $RECEIVER_SOURCE_SELECTION == 3 ]]; then RECEIVER_SOURCE_ENTRY="CompressedVRS"; fi
   if [[ $RECEIVER_SOURCE_SELECTION == 4 ]]; then RECEIVER_SOURCE_ENTRY="AircraftListJson"; fi
   if [[ $RECEIVER_SOURCE_SELECTION == 5 ]]; then RECEIVER_SOURCE_ENTRY="PlaneFinder"; fi
   if [[ $RECEIVER_SOURCE_SELECTION == 6 ]]; then RECEIVER_SOURCE_ENTRY="Sbs3"; fi
   printf "\nNote: More receivers may be added in the VRS settings after VRS is installed.\n"
fi
printf "\n"


# Even though this script should not be ran as root, it will occasionally need root privileges.
# Non-Raspbian operating systems will prompt user for sudo privilege here.
sudo ls &> /dev/null  # Dummy command just to get a prompt for the user's password for the sake of using sudo.
printf "\n"


# User only needs to press [Enter] key to start the VRS installation.
printf "No more user input necessary.\n"
printf "${GREEN_COLOR}Press [ENTER] to begin the VRS installation...${NO_COLOR}"; read -p ""
printf "\n"


#############################################################################################
#############################  Installation of VRS begins here  #############################
#############################################################################################


# Attempt to install Mono and/or other necessary software only if the software is not already installed.
if [[ $OPERATINGSYSTEMVERSION == "opensuse" ]]; then        # Possibly install/update Mono and other necessary software on openSUSE.
   if ! rpm -q unzip          >/dev/null 2>&1; then sudo zypper install -y unzip; fi
   if ! rpm -q mono-complete  >/dev/null 2>&1; then sudo zypper install -y mono-complete; fi
elif [[ $OPERATINGSYSTEMVERSION == "centos8" ]]; then       # Possibly install/update Mono and other necessary software on CentOS 8 Stream.
   if ! rpm -q libcanberra-gtk2 >/dev/null 2>&1; then sudo dnf install -y libcanberra-gtk2; fi
   if ! rpm -q unzip            >/dev/null 2>&1; then sudo dnf install -y unzip; fi
   if ! rpm -q mono-complete    >/dev/null 2>&1; then
      sudo rpm --import 'http://pool.sks-keyservers.net/pks/lookup?op=get&search=0x3fa7e0328081bff6a14da29aa6a19b38d3d831ef'
      sudo dnf config-manager --add-repo https://download.mono-project.com/repo/centos8-stable.repo
      sudo dnf install -y mono-complete
   fi
elif [[ $OPERATINGSYSTEMVERSION == "fedora" ]]; then        # Possibly install/update Mono and other necessary software on Fedora.
   if ! rpm -q unzip         >/dev/null 2>&1; then sudo dnf install -y unzip; fi
   if ! rpm -q mono-complete >/dev/null 2>&1; then sudo dnf install -y mono-complete; fi
elif [[ $OPERATINGSYSTEMVERSION == "manjaro" ]]; then       # Possibly install/update Mono and other necessary software on Manjaro.
   if ! pacman -Q gtk-engine-murrine >/dev/null 2>&1 ||
      ! pacman -Q unzip              >/dev/null 2>&1 ||
      ! pacman -Q mono               >/dev/null 2>&1; then
         sudo pacman -Syy --noconfirm
         sudo pacman -S --noconfirm gtk-engine-murrine  # Prevents `Unable to locate theme engine in module_path: "murrine"` error message from appearing.
         sudo pacman -S --noconfirm unzip
         sudo pacman -S --noconfirm mono
   fi
elif [[ $OPERATINGSYSTEMVERSION == "archlinux" ]]; then     # Assume many things need to be installed on Arch Linux.
   if ! pacman -Q gtk2     >/dev/null 2>&1 ||
      ! pacman -Q iproute2 >/dev/null 2>&1 ||
      ! pacman -Q sed      >/dev/null 2>&1 ||
      ! pacman -Q tar      >/dev/null 2>&1 ||
      ! pacman -Q unzip    >/dev/null 2>&1 ||
      ! pacman -Q which    >/dev/null 2>&1 ||
      ! pacman -Q wget     >/dev/null 2>&1 ||
      ! pacman -Q glibc    >/dev/null 2>&1 ||
      ! pacman -Q mono     >/dev/null 2>&1; then
         sudo pacman -Syy --noconfirm
         sudo pacman -S --noconfirm gtk2 iproute2 sed tar unzip which wget glibc mono  # GLIBC_2.33 necessary for 'tar' command.
   fi
elif [[ $OPERATINGSYSTEMVERSION == "elementaryos" ]]; then  # Possibly install/update Mono and other necessary software on elementary OS.
   if ! dpkg -s gtk2-engines-pixbuf    >/dev/null 2>&1 ||
      ! dpkg -s libcanberra-gtk-module >/dev/null 2>&1 ||
      ! dpkg -s unzip                  >/dev/null 2>&1 ||
      ! dpkg -s mono-complete          >/dev/null 2>&1; then
         sudo apt update -y
         sudo apt install -y gtk2-engines-pixbuf     # Prevents `Unable to locate theme engine in module_path: "pixmap"` error message from appearing.
         sudo apt install -y libcanberra-gtk-module  # Prevents `Failed to load module "canberra-gtk-module"` error message from appearing.
         sudo apt install -y mono-complete
         # export MONO_WINFORMS_XIM_STYLE=disabled   # Prevents `Could not get XIM` error message from appearing.  Must be executed outside of this script.
   fi
elif [[ $OPERATINGSYSTEMVERSION == "debian" ]]; then        # Possibly install/update Mono and other necessary software on Debian-based operating systems. (Includes Raspberry Pi OS, Ubuntu and MX Linux.)
   if ! dpkg -s libcanberra-gtk-module >/dev/null 2>&1 ||
      ! dpkg -s unzip                  >/dev/null 2>&1 ||
      ! dpkg -s mono-complete          >/dev/null 2>&1; then
         sudo apt update -y
         sudo apt install -y libcanberra-gtk-module  # Prevents `Failed to load module "canberra-gtk-module"` error message from appearing.
         sudo apt install -y unzip
         sudo apt install -y mono-complete
   fi
fi


# In the event the user ran this script again and a different version of VRS was chosen to install.
# Regardless, this should be safe to do as the files in the installation directory should never be altered in any way.
rm -rf "$VRSINSTALLDIRECTORY"


# Good time to make sure directories of interest are present (create if not already present).
for NEWDIRECTORY in "${VRSDIRECTORIES[@]}"; do
   if [ ! -d "$NEWDIRECTORY" ]; then
      mkdir -p "$NEWDIRECTORY" >/dev/null 2>&1;
      if [[ $? -ne 0 ]]; then sudo mkdir -p "$NEWDIRECTORY"; fi;  ERROREXIT 10 "Failed to create $NEWDIRECTORY!"  # Use 'sudo' only if necessary."
   fi
done


# Download/extract files from the VRS website to install VRS and the VRS plugins.
for URL in "${VRSFILES[@]}"; do
   REGEX="\/([^/]*)$"
   [[ $URL =~ $REGEX ]]
   FILENAME="${BASH_REMATCH[1]}"
   if [ ! -f "$TEMPDIR/$FILENAME" ]; then wget -P "$TEMPDIR" "$URL"; fi;  ERROREXIT 11 "Failed to download $FILENAME!"
   tar -xf "$TEMPDIR/$FILENAME" -C "$VRSINSTALLDIRECTORY";                ERROREXIT 12 "Failed to untar $FILENAME!"
done


# Function to download & extract addon files (operator flags, silhouettes, pictures, sample database file).
function UNPACK {
   local ID="$1"
   local URL="$2"
   local DIRECTORYPATH="$3"

   # Download and extract files to the appropriate directory.  (There is a possibility some of these extraction commands may need to be altered based on the compressed file that is downloaded.)
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


# Download & extract addon files (operator flags, silhouettes, pictures, sample database file).
if [[ $DL_OPF =~ [Yy] ]]; then UNPACK "OperatorFlagsFolder" "$OPFLAGSURL"      "$OPFLAGSDIRECTORY";     fi
if [[ $DL_SIL =~ [Yy] ]]; then UNPACK "SilhouettesFolder"   "$SILHOUETTESURL"  "$SILHOUETTESDIRECTORY"; fi
if [[ $DL_PIC =~ [Yy] ]]; then UNPACK "Pictures"            "$PICTURESURL"     "$PICTURESDIRECTORY";    fi
if [[ $DL_DB  =~ [Yy] ]]; then UNPACK "DatabaseFileName"    "$DATABASEURL"     "$DATABASEDIRECTORY";    fi


# Download & install updated Airplane Markers to fix the 'libpng warning' messages with the stable version (if user chose to do so).
if [[ $LIBPNG_FIX =~ [Yy] ]]; then
   mkdir -p "$AIRCRAFTMARKERDIR"
   if ! [[ -f "$TEMPDIR/Airplane.png" ]];         then wget -P "$TEMPDIR" "$AIRCRAFTMARKERURL_1";  ERROREXIT 17 "Failed to download 'Airplane.png'!"; fi
   if ! [[ -f "$TEMPDIR/AirplaneSelected.png" ]]; then wget -P "$TEMPDIR" "$AIRCRAFTMARKERURL_2";  ERROREXIT 18 "Failed to download 'AirplaneSelected.png'!"; fi
   cp "$TEMPDIR/Airplane.png"         "$AIRCRAFTMARKERDIR";  ERROREXIT 19 "Failed to copy 'Airplane.png'!"
   cp "$TEMPDIR/AirplaneSelected.png" "$AIRCRAFTMARKERDIR";  ERROREXIT 20 "Failed to copy 'AirplaneSelected.png'!"
else
   if [[ -f "$AIRCRAFTMARKERDIR/Airplane.png" ]];         then rm "$AIRCRAFTMARKERDIR/Airplane.png";          ERROREXIT 21 "Failed to delete 'Airplane.png'!"; fi
   if [[ -f "$AIRCRAFTMARKERDIR/AirplaneSelected.png" ]]; then rm "$AIRCRAFTMARKERDIR/AirplaneSelected.png";  ERROREXIT 22 "Failed to delete 'AirplaneSelected.png'!"; fi
fi


# Create an initial "Configuration.xml" file (if not already existing).
if ! [ -f "$CONFIGFILE" ]; then
   touch "$CONFIGFILE";                                                                                                                             ERROREXIT 23 "Failed to create $CONFIGFILE!"
   echo "<?xml version=\"1.0\" encoding=\"utf-8\"?>"                                                                              > "$CONFIGFILE";  ERROREXIT 24 "Failed to edit $CONFIGFILE!"
   echo "<Configuration xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\">" >> "$CONFIGFILE";
   echo "  <BaseStationSettings>"                                                                                                >> "$CONFIGFILE";
   echo "  </BaseStationSettings>"                                                                                               >> "$CONFIGFILE";
   echo "  <GoogleMapSettings>"                                                                                                  >> "$CONFIGFILE";
   echo "    <WebSiteReceiverId>1</WebSiteReceiverId>"                                                                           >> "$CONFIGFILE";
   echo "    <ClosestAircraftReceiverId>1</ClosestAircraftReceiverId>"                                                           >> "$CONFIGFILE";
   echo "    <FlightSimulatorXReceiverId>1</FlightSimulatorXReceiverId>"                                                         >> "$CONFIGFILE";
   echo "  </GoogleMapSettings>"                                                                                                 >> "$CONFIGFILE";
   echo "  <Receivers>"                                                                                                          >> "$CONFIGFILE";
   echo "  </Receivers>"                                                                                                         >> "$CONFIGFILE";
   echo "</Configuration>"                                                                                                       >> "$CONFIGFILE";
fi


# Function to fill in the directory/file paths in the "Configuration.xml" file (operator flags, silhouettes, pictures, sample database file).
function EDITCONFIGFILE {
   local SETTINGID="$1"
   local DIRECTORYPATH="$2"
   if grep -q "<$SETTINGID>.*</$SETTINGID>" "$CONFIGFILE"; then  # If SETTINGID is already existing, modify its value.
      sed -i "s|<$SETTINGID>.*</$SETTINGID>|<$SETTINGID>$DIRECTORYPATH</$SETTINGID>|" "$CONFIGFILE";                       ERROREXIT 25 "Failed to edit $CONFIGFILE!"
   else  # If SETTINGID is not already existing, create it with the appropriate value.
      sed -i "s|<BaseStationSettings>|<BaseStationSettings>\n    <$SETTINGID>$DIRECTORYPATH</$SETTINGID>|" "$CONFIGFILE";  ERROREXIT 26 "Failed to edit $CONFIGFILE!"
   fi
}


# Fill in the paths in the "Configuration.xml" file for the addon directories/files (operator flags, silhouettes, pictures, sample database file).
EDITCONFIGFILE "PicturesFolder"      "$PICTURESDIRECTORY"
EDITCONFIGFILE "SilhouettesFolder"   "$SILHOUETTESDIRECTORY"
EDITCONFIGFILE "OperatorFlagsFolder" "$OPFLAGSDIRECTORY"
EDITCONFIGFILE "DatabaseFileName"    "$DATABASEFILE"


# If user has entered location coordinates then set these coordinate values in the "Configuration.xml" file.
if [[ $ENTER_GPS =~ [Yy] ]]; then
   # Set longitude.
   if grep -q "<InitialMapLongitude>.*</InitialMapLongitude>" "$CONFIGFILE"; then  # If InitialMapLongitude already existing, modify its value.
      sed -i "s|<InitialMapLongitude>.*</InitialMapLongitude>|<InitialMapLongitude>$COORDINATE_LON</InitialMapLongitude>|" "$CONFIGFILE"; ERROREXIT 27 "Failed to edit $CONFIGFILE!"
   else  # If InitialMapLongitude is not already existing, create it with the appropriate value.
      sed -i "s|<GoogleMapSettings>|<GoogleMapSettings>\n    <InitialMapLongitude>$COORDINATE_LON</InitialMapLongitude>|" "$CONFIGFILE";  ERROREXIT 28 "Failed to edit $CONFIGFILE!"
   fi
   # Set latitude.
   if grep -q "<InitialMapLatitude>.*</InitialMapLatitude>" "$CONFIGFILE"; then  # If InitialMapLatitude already existing, modify its value.
      sed -i "s|<InitialMapLatitude>.*</InitialMapLatitude>|<InitialMapLatitude>$COORDINATE_LAT</InitialMapLatitude>|" "$CONFIGFILE";     ERROREXIT 29 "Failed to edit $CONFIGFILE!"
   else  # If InitialMapLatitude is not already existing, create it with the appropriate value.
      sed -i "s|<GoogleMapSettings>|<GoogleMapSettings>\n    <InitialMapLatitude>$COORDINATE_LAT</InitialMapLatitude>|" "$CONFIGFILE";    ERROREXIT 30 "Failed to edit $CONFIGFILE!"
   fi
fi


# If user has chosen to enter a receiver, then create the receiver.
if [[ $ENTER_RECEIVER =~ [Yy] ]]; then
   CONFIGTEXT=$(<"$CONFIGFILE")
   # If a receiver has already been entered, then find the next largest 'UniqueId' to assign to this new receiver.
   if grep -q "<Receiver>" "$CONFIGFILE"; then
      if [[ $CONFIGTEXT =~ (\<Receivers\>.*\</Receivers\>) ]]; then
         OIFS="$IFS"
         IFS=$'\n' read -a RECEIVERS_ARRAY -d '' <<< "${BASH_REMATCH[1]}"
         IFS="$OIFS"
      fi
      RECEIVERIDS=()  # Array to hold all of the current 'UniqueID's.
      for i in "${RECEIVERS_ARRAY[@]}"; do
         if [[ $i =~ \<UniqueId\>([0-9]+)\</UniqueId\> ]]; then
            RECEIVERIDS+=(${BASH_REMATCH[1]})
         fi
      done
      MAX=${RECEIVERIDS[0]}
      for N in "${RECEIVERIDS[@]}" ; do ((N > MAX)) && MAX=$N; done
      ((MAX++))
      RECEIVER_UNIQUEID=$MAX  # This is the next largest 'UniqueId'.
   else
      RECEIVER_UNIQUEID=1
   fi
   # Enter the receiver settings.
   RECEIVER_SETTINGS=" \
     <Enabled>true</Enabled>\n \
     <UniqueId>$RECEIVER_UNIQUEID</UniqueId>\n \
     <Name>$RECEIVER_NAME_ENTRY</Name>\n \
     <DataSource>$RECEIVER_SOURCE_ENTRY</DataSource>\n \
     <Address>$RECEIVER_ADDRESS_ENTRY</Address>\n \
     <Port>$RECEIVER_PORT_ENTRY</Port>\n"
   sed -i "s|<Receivers>|<Receivers>\n    <Receiver>\n$RECEIVER_SETTINGS    </Receiver>|" "$CONFIGFILE";                                                              ERROREXIT 31 "Failed to edit $CONFIGFILE!"
   # Set three global receiver settings if not already set.
   sed -i "s|<WebSiteReceiverId>.*</WebSiteReceiverId>|<WebSiteReceiverId>$RECEIVER_UNIQUEID</WebSiteReceiverId>|" "$CONFIGFILE";                                     ERROREXIT 32 "Failed to edit $CONFIGFILE!"
   sed -i "s|<ClosestAircraftReceiverId>.*</ClosestAircraftReceiverId>|<ClosestAircraftReceiverId>$RECEIVER_UNIQUEID</ClosestAircraftReceiverId>|" "$CONFIGFILE";     ERROREXIT 33 "Failed to edit $CONFIGFILE!"
   sed -i "s|<FlightSimulatorXReceiverId>.*</FlightSimulatorXReceiverId>|<FlightSimulatorXReceiverId>$RECEIVER_UNIQUEID</FlightSimulatorXReceiverId>|" "$CONFIGFILE"; ERROREXIT 34 "Failed to edit $CONFIGFILE!"
fi


# Create a file to allow for a different port to be used by the VRS.
touch "$SHAREDIRECTORY/$INSTALLERCONFIGFILENAME";                                                                                                                                ERROREXIT 35 "Failed to create $INSTALLERCONFIGFILENAME!"
echo "<?xml version=\"1.0\" encoding=\"utf-8\" ?>"                                                                                 > "$SHAREDIRECTORY/$INSTALLERCONFIGFILENAME"; ERROREXIT 36 "Failed to edit $INSTALLERCONFIGFILENAME!"
echo "<InstallerSettings xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\">" >> "$SHAREDIRECTORY/$INSTALLERCONFIGFILENAME";
echo "    <WebServerPort>$VRSPORT</WebServerPort>"                                                                                >> "$SHAREDIRECTORY/$INSTALLERCONFIGFILENAME";
echo "</InstallerSettings>"                                                                                                       >> "$SHAREDIRECTORY/$INSTALLERCONFIGFILENAME";


# Create an HTML file and an accompanying readme file to create messages that may appear at the top of the website.
if ! [ -f "$CUSTOMINJECTEDFILESDIRECTORY/$ANNOUNCEMENTFILENAME" ]; then
   touch "$CUSTOMINJECTEDFILESDIRECTORY/$ANNOUNCEMENTFILENAME";                                                       ERROREXIT 37 "Failed to create $ANNOUNCEMENTFILENAME!"
   echo '<!--'                                              > "$CUSTOMINJECTEDFILESDIRECTORY/$ANNOUNCEMENTFILENAME";  ERROREXIT 38 "Failed to edit $ANNOUNCEMENTFILENAME!"
   echo "<div style=\""                                    >> "$CUSTOMINJECTEDFILESDIRECTORY/$ANNOUNCEMENTFILENAME";
   echo "   color: red;"                                   >> "$CUSTOMINJECTEDFILESDIRECTORY/$ANNOUNCEMENTFILENAME";
   echo "   text-align: center;"                           >> "$CUSTOMINJECTEDFILESDIRECTORY/$ANNOUNCEMENTFILENAME";
   echo "   font-weight: bold;"                            >> "$CUSTOMINJECTEDFILESDIRECTORY/$ANNOUNCEMENTFILENAME";
   echo "   font-size: 1em"                                >> "$CUSTOMINJECTEDFILESDIRECTORY/$ANNOUNCEMENTFILENAME";
   echo "\">"                                              >> "$CUSTOMINJECTEDFILESDIRECTORY/$ANNOUNCEMENTFILENAME";
   echo "This text will be at the top of the VRS website!" >> "$CUSTOMINJECTEDFILESDIRECTORY/$ANNOUNCEMENTFILENAME";
   echo "</div>"                                           >> "$CUSTOMINJECTEDFILESDIRECTORY/$ANNOUNCEMENTFILENAME";
   echo "-->"                                              >> "$CUSTOMINJECTEDFILESDIRECTORY/$ANNOUNCEMENTFILENAME";
fi
if ! [ -f "$CUSTOMINJECTEDFILESDIRECTORY/$READMEFILENAME" ]; then
   touch "$CUSTOMINJECTEDFILESDIRECTORY/$READMEFILENAME";                                                                                                         ERROREXIT 39 "Failed to create $READMEFILENAME!"
   echo "Any text in the \"$ANNOUNCEMENTFILENAME\" file will be placed at the very top of the VRS web page."  > "$CUSTOMINJECTEDFILESDIRECTORY/$READMEFILENAME";  ERROREXIT 40 "Failed to edit $READMEFILENAME!"
   echo "The text could be used to provide the website visitors an announcement."                            >> "$CUSTOMINJECTEDFILESDIRECTORY/$READMEFILENAME";
   echo "This text will be at the top of both the desktop and mobile version of the website."                >> "$CUSTOMINJECTEDFILESDIRECTORY/$READMEFILENAME";
   echo ""                                                                                                   >> "$CUSTOMINJECTEDFILESDIRECTORY/$READMEFILENAME";
   echo "For example, the following text could be placed at the top:"                                        >> "$CUSTOMINJECTEDFILESDIRECTORY/$READMEFILENAME";
   echo "\"Server will perform a reboot at 12:00am (UTC).\""                                                 >> "$CUSTOMINJECTEDFILESDIRECTORY/$READMEFILENAME";
   echo ""                                                                                                   >> "$CUSTOMINJECTEDFILESDIRECTORY/$READMEFILENAME";
   echo "Because this is an HTML file, standard HTML tags may be used with the text."                        >> "$CUSTOMINJECTEDFILESDIRECTORY/$READMEFILENAME";
   echo "For example, the following usage of HTML tags will help enhance this text:"                         >> "$CUSTOMINJECTEDFILESDIRECTORY/$READMEFILENAME";
   echo "<b><font color=\"red\">This text is both bold and in a red color!</font></b>"                       >> "$CUSTOMINJECTEDFILESDIRECTORY/$READMEFILENAME";
fi


# Enable & configure the Custom Content Plugin to find the ANNOUNCEMENTFILENAME file to inject into 'desktop.html' and 'mobile.html' VRS files.
# Enable & configure the Custom Content Plugin to look in the CUSTOMWEBFILESDIRECTORY directory for any custom web files.
INJECTIONFILEPATHNAME="$CUSTOMINJECTEDFILESDIRECTORY/$ANNOUNCEMENTFILENAME"
INJECTIONFILE="${INJECTIONFILEPATHNAME//\//%2f}";           ERROREXIT 41 "Failed to create the $INJECTIONFILE variable!"    # Replace '/' with '%2f' HTML character code.
INJECTIONFOLDER="${CUSTOMINJECTEDFILESDIRECTORY//\//%2f}";  ERROREXIT 42 "Failed to create the $INJECTIONFOLDER variable!"  # Replace '/' with '%2f' HTML character code.
SITEROOTFOLDER="${CUSTOMWEBFILESDIRECTORY//\//%2f}";        ERROREXIT 43 "Failed to create the $SITEROOTFOLDER variable!"   # Replace '/' with '%2f' HTML character code.
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
%3c%2fOptions%3e";  ERROREXIT 44 "Failed to create the CUSTOMCONTENTTEMPLATE variable!"
if ! [ -f "$PLUGINSCONFIGFILE" ]; then
   touch "$PLUGINSCONFIGFILE";  ERROREXIT 45 "Failed to create $PLUGINSCONFIGFILE!"
fi
if ! grep -q "VirtualRadar.Plugin.CustomContent.Options" "$PLUGINSCONFIGFILE"; then  # If no CustomContent setting is present at all, then create the setting from scratch.
   echo -e "$CUSTOMCONTENTTEMPLATE" >> "$PLUGINSCONFIGFILE";  ERROREXIT 46 "Failed to edit $PLUGINSCONFIGFILE!"
else
   sed -i -r "s/VirtualRadar\.Plugin\.CustomContent\.Options.*/$CUSTOMCONTENTTEMPLATE/" "$PLUGINSCONFIGFILE";  ERROREXIT 47 "Failed to edit $PLUGINSCONFIGFILE!"
fi


# Configure the Tile Server Cache Plugin to use the TILECACHEDIRECTORY directory.
TILECACHEPATH="${TILECACHEDIRECTORY//\//%2f}";  ERROREXIT 48 "Failed to create the $TILECACHEPATH variable!"  # Replace '/' with '%2f' HTML character code.
TILECACHETEMPLATE="\
VirtualRadar.Plugin.TileServerCache.Options=%7b%22DataVersion%22%3a0%2c\
%22IsPluginEnabled%22%3afalse%2c\
%22IsOfflineModeEnabled%22%3afalse%2c\
%22CacheFolderOverride%22%3a%22${TILECACHEPATH}%22%2c\
%22UseDefaultCacheFolder%22%3afalse%2c\
%22TileServerTimeoutSeconds%22%3a30%2c\
%22CacheMapTiles%22%3atrue%2c\
%22CacheLayerTiles%22%3atrue%7d";  ERROREXIT 49 "Failed to create the TILECACHETEMPLATE variable!"
if ! [ -f "$PLUGINSCONFIGFILE" ]; then
   touch "$PLUGINSCONFIGFILE";  ERROREXIT 50 "Failed to create $PLUGINSCONFIGFILE!"
fi
if ! grep -q "VirtualRadar.Plugin.TileServerCache.Options" "$PLUGINSCONFIGFILE"; then  # If no Tile Server Cache Plugin setting is present at all, then create the setting from scratch.
   echo -e "$TILECACHETEMPLATE" >> "$PLUGINSCONFIGFILE";  ERROREXIT 51 "Failed to edit $PLUGINSCONFIGFILE!"
else
   sed -i -r "s/VirtualRadar\.Plugin\.TileServerCache\.Options.*/$TILECACHETEMPLATE/" "$PLUGINSCONFIGFILE";  ERROREXIT 52 "Failed to edit $PLUGINSCONFIGFILE!"
fi


# Change global localization from 'en-GB' to a custom default localization (for example: 'en-US') set by the user at the start of this script.
cp "$VRSINSTALLDIRECTORY/Web/desktop.html"       "$CUSTOMWEBFILESDIRECTORY";            ERROREXIT 53 "Failed to copy $VRSINSTALLDIRECTORY/Web/desktop.html!"
cp "$VRSINSTALLDIRECTORY/Web/desktopReport.html" "$CUSTOMWEBFILESDIRECTORY";            ERROREXIT 54 "Failed to copy $VRSINSTALLDIRECTORY/Web/desktopReport.html!"
cp "$VRSINSTALLDIRECTORY/Web/mobile.html"        "$CUSTOMWEBFILESDIRECTORY";            ERROREXIT 55 "Failed to copy $VRSINSTALLDIRECTORY/Web//mobile.html!"
cp "$VRSINSTALLDIRECTORY/Web/mobileReport.html"  "$CUSTOMWEBFILESDIRECTORY";            ERROREXIT 56 "Failed to copy $VRSINSTALLDIRECTORY/Web/mobileReport.html!"
cp "$VRSINSTALLDIRECTORY/Web/fsx.html"           "$CUSTOMWEBFILESDIRECTORY";            ERROREXIT 57 "Failed to copy $VRSINSTALLDIRECTORY/Web/fsx.html!"
sed -i -e "s/'en-GB'/'$LOCALIZATION'/g" "$CUSTOMWEBFILESDIRECTORY/desktop.html";        ERROREXIT 58 "Failed to edit $CUSTOMWEBFILESDIRECTORY/desktop.html!"
sed -i -e "s/'en-GB'/'$LOCALIZATION'/g" "$CUSTOMWEBFILESDIRECTORY/desktopReport.html";  ERROREXIT 59 "Failed to edit $CUSTOMWEBFILESDIRECTORY/desktopReport.html!"
sed -i -e "s/'en-GB'/'$LOCALIZATION'/g" "$CUSTOMWEBFILESDIRECTORY/mobile.html";         ERROREXIT 60 "Failed to edit $CUSTOMWEBFILESDIRECTORY/mobile.html!"
sed -i -e "s/'en-GB'/'$LOCALIZATION'/g" "$CUSTOMWEBFILESDIRECTORY/mobileReport.html";   ERROREXIT 61 "Failed to edit $CUSTOMWEBFILESDIRECTORY/mobileReport.html!"
sed -i -e "s/'en-GB'/'$LOCALIZATION'/g" "$CUSTOMWEBFILESDIRECTORY/fsx.html";            ERROREXIT 62 "Failed to edit $CUSTOMWEBFILESDIRECTORY/fsx.html!"


# Create a script to help backup the database file. (A cron job can later be set to automatically run the script at any time interval.)
touch "$DATABASEBACKUPSCRIPT";                                                                   ERROREXIT 63 "Failed to create $DATABASEBACKUPSCRIPT!"
echo "#!/bin/bash"                                                   > "$DATABASEBACKUPSCRIPT";  ERROREXIT 64 "Failed to edit $DATABASEBACKUPSCRIPT!"
echo "# Use this script to routinely backup the VRS database file." >> "$DATABASEBACKUPSCRIPT";
echo "mkdir -p \"$DATABASEBACKUPDIRECTORY\""                        >> "$DATABASEBACKUPSCRIPT";
echo "cp \"$DATABASEFILE\" \"$DATABASEBACKUPFILE\""                 >> "$DATABASEBACKUPSCRIPT";
echo "exit"                                                         >> "$DATABASEBACKUPSCRIPT";


# Create a service file to run VRS in the background.
if which mono >/dev/null 2>&1; then MONOLOCATION="$(which mono)"; else MONOLOCATION="/usr/bin/mono"; fi  # Assume Mono is installed at '/usr/bin/mono' unless determined to be somewhere else.
if which rm   >/dev/null 2>&1; then RMLOCATION="$(which rm)";     else MONOLOCATION="/usr/bin/rm";   fi  # Assume rm   is installed at '/usr/bin/rm'   unless determined to be somewhere else.
sudo touch $SERVICEFILE;        ERROREXIT 65 "Failed to create $SERVICEFILE!"
sudo chmod 777 "$SERVICEFILE";  ERROREXIT 66 "The 'chmod' command failed on $SERVICEFILE!"
echo "[Unit]"                                                                     > "$SERVICEFILE";  ERROREXIT 67 "Failed to edit $SERVICEFILE!"
echo "Description=VRS background process"                                        >> "$SERVICEFILE";
echo ""                                                                          >> "$SERVICEFILE";
echo "[Service]"                                                                 >> "$SERVICEFILE";
echo "User=$USER"                                                                >> "$SERVICEFILE";
echo "ExecStartPre=$RMLOCATION -f \"$DATABASEFILE-journal\""                     >> "$SERVICEFILE";
echo "ExecStart=$MONOLOCATION \"$VRSINSTALLDIRECTORY/VirtualRadar.exe\" -nogui"  >> "$SERVICEFILE";
echo ""                                                                          >> "$SERVICEFILE";
echo "[Install]"                                                                 >> "$SERVICEFILE";
echo "WantedBy=multi-user.target"                                                >> "$SERVICEFILE";
sudo chmod 755 "$SERVICEFILE";        ERROREXIT 68 "The 'chmod' command failed on $SERVICEFILE!"
sudo chown root:root "$SERVICEFILE";  ERROREXIT 69 "The 'chown' command failed on $SERVICEFILE!"
sudo systemctl daemon-reload;         ERROREXIT 70 "The 'systemctl daemon-reload' command failed"


# Create the VRS watchdog script to be used by a cron job and an accompanying README file.
touch "$TEMPDIR/$VRSWATCHDOGFILENAME";  ERROREXIT 71 "Failed to create $TEMPDIR/$VRSWATCHDOGFILENAME!"
echo "#!/bin/bash"                                                                                                                                                                     > "$TEMPDIR/$VRSWATCHDOGFILENAME";  ERROREXIT 72 "Failed to edit $TEMPDIR/$VRSWATCHDOGFILENAME!"
echo ""                                                                                                                                                                               >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "# Virtual Radar Server (VRS) watchdog script to be ran as a cron job."                                                                                                          >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo ""                                                                                                                                                                               >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "# Change the following three variables as desired."                                                                                                                             >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "LOG_DIR=\"$VRSWATCHDOGLOGDIRECTORY\"  # Directory to contain the log file (gets created if not already existing)."                                                              >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "LOG_NAME=\"$VRSWATCHDOGLOGFILENAME\"  # Name of the log file."                                                                                                                  >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "WAITSECS=120  # Amount of time (in seconds) after first detecting VRS is not running before starting VRS again."                                                                >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "              # To be safe, the value of 'WAITSECS' should never be less than 60."                                                                                              >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo ""                                                                                                                                                                               >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "##############################################################################################################################"                                                 >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "# Do not alter any part of the script below."                                                                                                                                   >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "##############################################################################################################################"                                                 >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo ""                                                                                                                                                                               >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "VRS_EXE=\"$VRSINSTALLDIRECTORY/VirtualRadar.exe\"  # Full path of the VRS executable."                                                                                          >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "VRS_START=\"$STARTCOMMANDDIR/$STARTCOMMANDFILENAME -$VRSCMD_STARTPROCESS\"  # The command to start VRS as a background process."                                                >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "JOURNAL_FILE=\"$DATABASEDIRECTORY/$DATABASEFILENAME-journal\"  # A temp file for the $DATABASEFILENAME file."                                                                   >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "LOG_FILE=\"\$LOG_DIR/\$LOG_NAME\"  # Full path of the VRS watchdog log file."                                                                                                   >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "PID_DIR=\"$TEMPDIR\"  # Temp directory to store the PID file."                                                                                                                  >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "PID_FILE=\"\$PID_DIR/watchdog.pid\"  # A temp file used to determine if this VRS watchdog script is already running."                                                           >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "MYUSERNAME=\"$USER\"  # The username of the account running VRS."                                                                                                               >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "DATE_TIME=\$(date \"+%Y-%m-%d %H:%M:%S\")  # YYYY-MM-DD HH:MM:SS"                                                                                                               >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo ""                                                                                                                                                                               >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "# Exit if the VRS executable is not found."                                                                                                                                     >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "if ! [ -f \"\$VRS_EXE\" ]; then exit; fi"                                                                                                                                       >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo ""                                                                                                                                                                               >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "# Exit from this VRS watchdog script if another instance of this script is already running."                                                                                    >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "if [ -f \"\$PID_FILE\" ]; then exit; fi"                                                                                                                                        >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo ""                                                                                                                                                                               >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "# Create the directory to contain the VRS watchdog log file if it is not already existing."                                                                                     >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "if ! [ -d \"\$LOG_DIR\" ]; then mkdir -p \"\$LOG_DIR\"; fi"                                                                                                                     >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo ""                                                                                                                                                                               >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "# Create the VRS watchdog log file if it is not already existing."                                                                                                              >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "if ! [ -f \"\$LOG_FILE\" ]; then"                                                                                                                                               >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "   touch \"\$LOG_FILE\""                                                                                                                                                        >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "   sudo chown \$MYUSERNAME:users \"\$LOG_FILE\"  # Prevents log file being owned by root if 'sudo crontab -e' is used."                                                         >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "   printf \"%s - VRS watchdog log file was successfully created.\n\" \"\$DATE_TIME\" > \"\$LOG_FILE\""                                                                          >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "fi"                                                                                                                                                                             >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo ""                                                                                                                                                                               >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "# Check for the rare situation of an empty VRS watchdog log file getting created."                                                                                              >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "if ! [ -s \"\$LOG_FILE\" ]; then"                                                                                                                                               >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "   printf \"%s - VRS watchdog log file was successfully created.\n\" \"\$DATE_TIME\" > \"\$LOG_FILE\""                                                                          >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "fi"                                                                                                                                                                             >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo ""                                                                                                                                                                               >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "# Check if VRS needs to be started again, and note it in the VRS watchdog log file if VRS is started again."                                                                    >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "if ! pgrep -f \"\$VRS_EXE\"; then"                                                                                                                                              >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "   trap \"rm -f \$PID_FILE\" INT TERM EXIT  # Delete the PID file whenever this script exits."                                                                                  >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "   mkdir -p \"\$PID_DIR\"; sudo sync \"\$PID_DIR\""                                                                                                                             >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "   sudo chown \$MYUSERNAME:users \"\$PID_DIR\"  # Prevents the PID directory being owned by root if 'sudo crontab -e' is used."                                                 >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "   touch \"\$PID_FILE\"; sudo sync \"\$PID_FILE\""                                                                                                                              >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "   sudo chown \$MYUSERNAME:users \"\$PID_FILE\"  # Prevents PID file being owned by root if 'sudo crontab -e' is used."                                                         >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "   printf \"%s - PID: %s\n\" \"\$DATE_TIME\" \"$(echo \$\$)\" > \"\$PID_FILE\""                                                                                                 >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "   printf \"%s - VRS watchdog script has detected that VRS is not running. (Will keep checking every second for %s seconds.)\n\" \"\$DATE_TIME\" \$WAITSECS >> \"\$LOG_FILE\""  >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "   sync \"\$LOG_FILE\""                                                                                                                                                         >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "   LIMIT_REACHED=0"                                                                                                                                                             >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "   STARTTIME=\$(date +%s)  # Epoch time"                                                                                                                                        >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "   while ! pgrep -f \"\$VRS_EXE\"; do"                                                                                                                                          >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "      if [ \$((\$(date +%s)-STARTTIME)) -ge \$WAITSECS ]; then"                                                                                                                 >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "         LIMIT_REACHED=1"                                                                                                                                                       >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "         DATE_TIME=\$(date \"+%Y-%m-%d %H:%M:%S\")  # YYYY-MM-DD HH:MM:SS"                                                                                                      >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "         rm -f \"\$JOURNAL_FILE\"  # Make sure this file (if existing) is deleted otherwise the $DATABASEFILENAME file will not update."                                        >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "         eval \"\$VRS_START\""                                                                                                                                                  >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "         VRSEXITCODE=\$?"                                                                                                                                                       >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "         sleep 1"                                                                                                                                                               >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "         if pgrep -f \"\$VRS_EXE\" && [[ \$VRSEXITCODE -eq 0 ]]; then"                                                                                                          >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "            printf \"%s - VRS watchdog script has started VRS.\n\" \"\$DATE_TIME\" >> \"\$LOG_FILE\""                                                                           >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "         else"                                                                                                                                                                  >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "            printf \"%s - ERROR! VRS watchdog script was not able to start VRS! (VRS error code: \$VRSEXITCODE)\n\" \"\$DATE_TIME\" >> \"\$LOG_FILE\""                          >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "         fi"                                                                                                                                                                    >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "         break"                                                                                                                                                                 >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "      fi"                                                                                                                                                                       >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "      sleep 1"                                                                                                                                                                  >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "   done"                                                                                                                                                                        >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "   if pgrep -f \"\$VRS_EXE\" && [[ \$LIMIT_REACHED -eq 0 ]]; then"                                                                                                              >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "      DATE_TIME=\$(date \"+%Y-%m-%d %H:%M:%S\")  # YYYY-MM-DD HH:MM:SS"                                                                                                         >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "      printf \"%s - VRS was started, but not by the VRS watchdog script.\n\" \"\$DATE_TIME\" >> \"\$LOG_FILE\""                                                                 >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "   fi"                                                                                                                                                                          >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "fi"                                                                                                                                                                             >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo ""                                                                                                                                                                               >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "sync \"\$LOG_FILE\""                                                                                                                                                            >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo ""                                                                                                                                                                               >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
echo "exit"                                                                                                                                                                           >> "$TEMPDIR/$VRSWATCHDOGFILENAME"
cp "$TEMPDIR/$VRSWATCHDOGFILENAME" "$VRSWATCHDOGDIRECTORY" >/dev/null 2>&1;
if [[ $? -ne 0 ]]; then sudo cp "$TEMPDIR/$VRSWATCHDOGFILENAME" "$VRSWATCHDOGDIRECTORY"; fi;    ERROREXIT 73 "Failed to copy $TEMPDIR/$VRSWATCHDOGFILENAME!"  # Use 'sudo' only if necessary."
touch "$TEMPDIR/Watchdog_README";                                                               ERROREXIT 74 "Failed to create $TEMPDIR/Watchdog_README!"
echo "Command to create a cron job entry:"                                                                    > "$TEMPDIR/Watchdog_README";  ERROREXIT 75 "Failed to edit $TEMPDIR/Watchdog_README!"
echo "$CRONCMD"                                                                                              >> "$TEMPDIR/Watchdog_README"
echo ""                                                                                                      >> "$TEMPDIR/Watchdog_README"
echo "Example of a cron job entry to run the '$VRSWATCHDOGFILENAME' script every minute:"                    >> "$TEMPDIR/Watchdog_README"
echo "*/1 * * * * $BASHLOCATION \"$VRSWATCHDOGDIRECTORY/$VRSWATCHDOGFILENAME\""                              >> "$TEMPDIR/Watchdog_README"
echo ""                                                                                                      >> "$TEMPDIR/Watchdog_README"
echo "For further instructions and help regarding this VRS watchdog script, please visit:"                   >> "$TEMPDIR/Watchdog_README"
echo "https://github.com/mypiaware/virtual-radar-server-installation/blob/master/README.md#watchdog-script"  >> "$TEMPDIR/Watchdog_README"
cp "$TEMPDIR/Watchdog_README" "$VRSWATCHDOGDIRECTORY/README" >/dev/null 2>&1;
if [[ $? -ne 0 ]]; then sudo cp "$TEMPDIR/Watchdog_README" "$VRSWATCHDOGDIRECTORY/README"; fi;  ERROREXIT 76 "Failed to copy $TEMPDIR/$VRSWATCHDOGFILENAME!"  # Use 'sudo' only if necessary."


# Find largest length of the VRS command options.
VRSCMD_GUI_LEN=${#VRSCMD_GUI}
VRSCMD_NOGUI_LEN=${#VRSCMD_NOGUI}
VRSCMD_STARTPROCESS_LEN=${#VRSCMD_STARTPROCESS}
VRSCMD_STOPPROCESS_LEN=${#VRSCMD_STOPPROCESS}
VRSCMD_ENABLE_LEN=${#VRSCMD_ENABLE}
VRSCMD_DISABLE_LEN=${#VRSCMD_DISABLE}
VRSCMD_WEBADMIN_LEN=${#VRSCMD_WEBADMIN}
VRSCMD_LOG_LEN=${#VRSCMD_LOG}
if [[ $VRSCMD_GUI_LEN          -gt $VRSCMD_NOGUI_LEN ]]; then ARGLENGTH=${#VRSCMD_GUI}; else ARGLENGTH=${#VRSCMD_NOGUI}; fi
if [[ $VRSCMD_STARTPROCESS_LEN -gt $ARGLENGTH        ]]; then ARGLENGTH=${#VRSCMD_STARTPROCESS}; fi
if [[ $VRSCMD_STOPPROCESS_LEN  -gt $ARGLENGTH        ]]; then ARGLENGTH=${#VRSCMD_STOPPROCESS};  fi
if [[ $VRSCMD_ENABLE_LEN       -gt $ARGLENGTH        ]]; then ARGLENGTH=${#VRSCMD_ENABLE};       fi
if [[ $VRSCMD_DISABLE_LEN      -gt $ARGLENGTH        ]]; then ARGLENGTH=${#VRSCMD_DISABLE};      fi
if [[ $VRSCMD_WEBADMIN_LEN     -gt $ARGLENGTH        ]]; then ARGLENGTH=${#VRSCMD_WEBADMIN};     fi
if [[ $VRSCMD_LOG_LEN          -gt $ARGLENGTH        ]]; then ARGLENGTH=${#VRSCMD_LOG};          fi


# Create a universal command to start/stop VRS.
if ! [ -f "$STARTCOMMAND" ]; then sudo touch "$STARTCOMMAND"; fi;  ERROREXIT 77 "Failed to create $STARTCOMMAND!"
sudo chmod 777 "$STARTCOMMAND";                                    ERROREXIT 78 "The 'chmod' command failed on  $STARTCOMMAND!"
if which mono >/dev/null 2>&1; then MONOLOCATION="$(which mono)"; else MONOLOCATION="/usr/bin/mono"; fi  # Assume Mono is installed at '/usr/bin/mono' unless determined to be somewhere else.
echo "#!/bin/bash"                                                                                                                                                                                                                                                                > "$STARTCOMMAND";  ERROREXIT 79 "Failed to edit $STARTCOMMAND!"
echo "# Use this script as a global command to start/stop VRS."                                                                                                                                                                                                                  >> "$STARTCOMMAND";
echo ""                                                                                                                                                                                                                                                                          >> "$STARTCOMMAND";
echo "function COMMANDHELP {"                                                                                                                                                                                                                                                    >> "$STARTCOMMAND";
echo "   printf \"Usage: vrs -option\n\""                                                                                                                                                                                                                                        >> "$STARTCOMMAND";
echo "   printf -- \"Options:\n\""                                                                                                                                                                                                                                               >> "$STARTCOMMAND";
echo "   printf -- \" -%-${ARGLENGTH}s  Start VRS with a GUI in a GUI desktop environment\n\" \"$VRSCMD_GUI\""                                                                                                                                                                   >> "$STARTCOMMAND";
echo "   printf -- \" -%-${ARGLENGTH}s  Start VRS without a GUI\n\" \"$VRSCMD_NOGUI\""                                                                                                                                                                                           >> "$STARTCOMMAND";
echo "   printf -- \" -%-${ARGLENGTH}s  Start VRS as a background service\n\" \"$VRSCMD_STARTPROCESS\""                                                                                                                                                                          >> "$STARTCOMMAND";
echo "   printf -- \" -%-${ARGLENGTH}s  Stop VRS if running as a background service\n\" \"$VRSCMD_STOPPROCESS\""                                                                                                                                                                 >> "$STARTCOMMAND";
echo "   printf -- \" -%-${ARGLENGTH}s  Allow VRS to start at every system boot as a background service\n\" \"$VRSCMD_ENABLE\""                                                                                                                                                  >> "$STARTCOMMAND";
echo "   printf -- \" -%-${ARGLENGTH}s  Disable VRS from starting at every system boot\n\" \"$VRSCMD_DISABLE\""                                                                                                                                                                  >> "$STARTCOMMAND";
echo "   printf -- \" -%-${ARGLENGTH}s  Create username & password for Web Admin & also start VRS\n\" \"$VRSCMD_WEBADMIN\""                                                                                                                                                      >> "$STARTCOMMAND";
echo "   printf -- \" -%-${ARGLENGTH}s  View history log of VRS running as a background service\n\" \"$VRSCMD_LOG\""                                                                                                                                                             >> "$STARTCOMMAND";
echo "   printf -- \" -%-${ARGLENGTH}s  Display this help menu\n\" \"?\""                                                                                                                                                                                                        >> "$STARTCOMMAND";
echo "}"                                                                                                                                                                                                                                                                         >> "$STARTCOMMAND";
echo ""                                                                                                                                                                                                                                                                          >> "$STARTCOMMAND";
echo "LOCALIP=\$(ip route get 1.2.3.4 | awk '{printf \"%s\",\$7}')"                                                                                                                                                                                                              >> "$STARTCOMMAND";
echo "if [[ \"\$LOCALIP\" =~ ([[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}) ]]; then"                                                                                                                                                                  >> "$STARTCOMMAND";
echo "   LOCALIP=\${BASH_REMATCH[1]}"                                                                                                                                                                                                                                            >> "$STARTCOMMAND";
echo "fi"                                                                                                                                                                                                                                                                        >> "$STARTCOMMAND";
echo ""                                                                                                                                                                                                                                                                          >> "$STARTCOMMAND";
echo "VRSPORT=8080"                                                                                                                                                                                                                                                              >> "$STARTCOMMAND";
echo "if [ -f \"$SHAREDIRECTORY/$INSTALLERCONFIGFILENAME\" ]; then"                                                                                                                                                                                                              >> "$STARTCOMMAND";
echo "   XMLTEXT=\$(<\"$SHAREDIRECTORY/$INSTALLERCONFIGFILENAME\")"                                                                                                                                                                                                              >> "$STARTCOMMAND";
echo "   if [[ \$XMLTEXT =~ \<WebServerPort\>([[:digit:]]+)\</WebServerPort\> ]]; then"                                                                                                                                                                                          >> "$STARTCOMMAND";
echo "      VRSPORT=\${BASH_REMATCH[1]}"                                                                                                                                                                                                                                         >> "$STARTCOMMAND";
echo "   fi"                                                                                                                                                                                                                                                                     >> "$STARTCOMMAND";
echo "fi"                                                                                                                                                                                                                                                                        >> "$STARTCOMMAND";
echo ""                                                                                                                                                                                                                                                                          >> "$STARTCOMMAND";
echo "if [[ \$# -eq 1 ]]; then"                                                                                                                                                                                                                                                  >> "$STARTCOMMAND";
echo "   if [[ \$1 == \"-h\" || \$1 == \"-help\" || \$1 == \"-?\" ]]; then COMMANDHELP; exit 100"                                                                                                                                                                                >> "$STARTCOMMAND";
echo "   elif ! [[ \$1 == \"-$VRSCMD_GUI\" || \$1 == \"-$VRSCMD_NOGUI\" || \$1 == \"-$VRSCMD_STARTPROCESS\" || \$1 == \"-$VRSCMD_STOPPROCESS\" || \$1 == \"-$VRSCMD_ENABLE\" || \$1 == \"-$VRSCMD_DISABLE\" || \$1 == \"-$VRSCMD_WEBADMIN\" || \$1 == \"-$VRSCMD_LOG\" ]]; then" >> "$STARTCOMMAND";
echo "      printf \"${BOLD_FONT}ERROR: Invalid option!${NO_COLOR}\n\n\"; COMMANDHELP; exit 1"                                                                                                                                                                                   >> "$STARTCOMMAND";
echo "   elif [[ \$1 == \"-$VRSCMD_ENABLE\" ]]; then"                                                                                                                                                                                                                            >> "$STARTCOMMAND";
echo "      sudo systemctl enable $SERVICEFILENAME.service >/dev/null 2>&1"                                                                                                                                                                                                      >> "$STARTCOMMAND";
echo "      if [[ \$? -ne 0 ]]; then printf \"Error trying to enable VRS at boot!\n\"; exit 2"                                                                                                                                                                                   >> "$STARTCOMMAND";
echo "      else                    printf \"VRS enabled to start at every system boot.\n\"; exit 0; fi"                                                                                                                                                                         >> "$STARTCOMMAND";
echo "   elif [[ \$1 == \"-$VRSCMD_DISABLE\" ]]; then"                                                                                                                                                                                                                           >> "$STARTCOMMAND";
echo "      sudo systemctl disable $SERVICEFILENAME.service >/dev/null 2>&1"                                                                                                                                                                                                     >> "$STARTCOMMAND";
echo "      if [[ \$? -ne 0 ]]; then printf \"Error trying to disable VRS at boot!\n\"; exit 3"                                                                                                                                                                                  >> "$STARTCOMMAND";
echo "      else                    printf \"VRS disabled from starting at every system boot.\n\"; exit 0; fi"                                                                                                                                                                   >> "$STARTCOMMAND";
echo "   elif [[ \$1 == \"-$VRSCMD_STOPPROCESS\" ]]; then"                                                                                                                                                                                                                       >> "$STARTCOMMAND";
echo "      if systemctl is-active --quiet $SERVICEFILENAME.service; then"                                                                                                                                                                                                       >> "$STARTCOMMAND";
echo "         sudo systemctl stop $SERVICEFILENAME.service"                                                                                                                                                                                                                     >> "$STARTCOMMAND";
echo "         if [[ \$? -ne 0 ]]; then printf \"Error trying to stop VRS!\n\"; exit 4"                                                                                                                                                                                          >> "$STARTCOMMAND";
echo "         else                    printf \"VRS has stopped.\n\"; exit 0; fi"                                                                                                                                                                                                >> "$STARTCOMMAND";
echo "      elif pgrep -f '$VRSINSTALLDIRECTORY/VirtualRadar.exe' >/dev/null; then"                                                                                                                                                                                              >> "$STARTCOMMAND";
echo "         printf \"Cannot stop VRS. VRS is running, but not as a service.\n\"; exit 5"                                                                                                                                                                                      >> "$STARTCOMMAND";
echo "      elif ! pgrep -f '$VRSINSTALLDIRECTORY/VirtualRadar.exe' >/dev/null; then"                                                                                                                                                                                            >> "$STARTCOMMAND";
echo "         printf \"VRS is already stopped.\n\"; exit 101"                                                                                                                                                                                                                   >> "$STARTCOMMAND";
echo "      else printf \"Unknown error occurred! EXIT CODE: 6\n\"; exit 6"                                                                                                                                                                                                      >> "$STARTCOMMAND";
echo "      fi"                                                                                                                                                                                                                                                                  >> "$STARTCOMMAND";
echo "   elif [[ \$1 == \"-$VRSCMD_LOG\" ]]; then"                                                                                                                                                                                                                               >> "$STARTCOMMAND";
echo "      sudo journalctl -u $SERVICEFILENAME.service --lines=all --no-hostname --no-pager"                                                                                                                                                                                    >> "$STARTCOMMAND";
echo "      if [[ \$? -ne 0 ]]; then printf \"Error trying to get log of VRS!\n\"; exit 7; else exit 0; fi"                                                                                                                                                                      >> "$STARTCOMMAND";
echo "   elif ! pgrep -f '$VRSINSTALLDIRECTORY/VirtualRadar.exe' >/dev/null; then"                                                                                                                                                                                               >> "$STARTCOMMAND";
echo "      rm -f \"$DATABASEFILE-journal\""                                                                                                                                                                                                                                     >> "$STARTCOMMAND";
echo "      if [[ \$1 == \"-$VRSCMD_GUI\" ]]; then"                                                                                                                                                                                                                              >> "$STARTCOMMAND";
echo "         $MONOLOCATION \"$VRSINSTALLDIRECTORY/VirtualRadar.exe\""                                                                                                                                                                                                          >> "$STARTCOMMAND";
echo "         if [[ \$? -ne 0 ]]; then printf \"Error trying to start VRS!\n\"; exit 8; else exit 0; fi"                                                                                                                                                                        >> "$STARTCOMMAND";
echo "      elif [[ \$1 == \"-$VRSCMD_NOGUI\" ]]; then"                                                                                                                                                                                                                          >> "$STARTCOMMAND";
echo "         $MONOLOCATION \"$VRSINSTALLDIRECTORY/VirtualRadar.exe\" -nogui"                                                                                                                                                                                                   >> "$STARTCOMMAND";
echo "         if [[ \$? -ne 0 ]]; then printf \"Error trying to start VRS!\n\"; exit 9; else exit 0; fi"                                                                                                                                                                        >> "$STARTCOMMAND";
echo "      elif [[ \$1 == \"-$VRSCMD_STARTPROCESS\" ]]; then"                                                                                                                                                                                                                   >> "$STARTCOMMAND";
echo "         sudo systemctl restart $SERVICEFILENAME.service"                                                                                                                                                                                                                  >> "$STARTCOMMAND";
echo "         if [[ \$? -ne 0 ]]; then printf \"Error trying to start VRS!\n\"; exit 10"                                                                                                                                                                                        >> "$STARTCOMMAND";
echo "         else                    printf \"VRS has started as a background process.\n\"; exit 0; fi"                                                                                                                                                                        >> "$STARTCOMMAND";
echo "      elif [[ \$1 == \"-$VRSCMD_WEBADMIN\" ]]; then"                                                                                                                                                                                                                       >> "$STARTCOMMAND";
echo "         while [[ \${#WAUSERNAME[@]} -ne 1 && WAUSERNAME[0] != \"\" ]]; do printf \"Create Web Admin username: \"; read -r -a WAUSERNAME; done"                                                                                                                            >> "$STARTCOMMAND";
echo "         while [[ \${#WAPASSWORD[@]} -ne 1 && WAPASSWORD[0] != \"\" ]]; do printf \"Create Web Admin password: \"; read -r -a WAPASSWORD; done"                                                                                                                            >> "$STARTCOMMAND";
echo "         printf \"\nAccess the VRS Web Admin on a local device with this URL:\n   http://%s:%s/VirtualRadar/WebAdmin/Index.html\n\n\" $LOCALIP $VRSPORT"                                                                                                                   >> "$STARTCOMMAND";
echo "         $MONOLOCATION \"$VRSINSTALLDIRECTORY/VirtualRadar.exe\" -nogui -createAdmin:\$WAUSERNAME -password:\$WAPASSWORD"                                                                                                                                                  >> "$STARTCOMMAND";
echo "         if [[ \$? -ne 0 ]]; then printf \"Error trying to start VRS!\n\"; exit 11; else exit 0; fi"                                                                                                                                                                       >> "$STARTCOMMAND";
echo "      else printf \"Unknown error occurred! EXIT CODE: 12\n\"; exit 12"                                                                                                                                                                                                    >> "$STARTCOMMAND";
echo "      fi"                                                                                                                                                                                                                                                                  >> "$STARTCOMMAND";
echo "   elif pgrep -f '$VRSINSTALLDIRECTORY/VirtualRadar.exe' >/dev/null; then"                                                                                                                                                                                                 >> "$STARTCOMMAND";
echo "      if [[ \$1 == \"-$VRSCMD_GUI\" || \$1 == \"-$VRSCMD_NOGUI\" || \$1 == \"-$VRSCMD_STARTPROCESS\" || \$1 == \"-$VRSCMD_WEBADMIN\" ]]; then"                                                                                                                             >> "$STARTCOMMAND";
echo "         printf \"VRS is already running!\n\"; exit 102"                                                                                                                                                                                                                   >> "$STARTCOMMAND";
echo "      fi"                                                                                                                                                                                                                                                                  >> "$STARTCOMMAND";
echo "   else printf \"Unknown error occurred! EXIT CODE: 13\n\"; exit 13"                                                                                                                                                                                                       >> "$STARTCOMMAND";
echo "   fi"                                                                                                                                                                                                                                                                     >> "$STARTCOMMAND";
echo "elif [[ \$# -ge 1 ]]; then"                                                                                                                                                                                                                                                >> "$STARTCOMMAND";
echo "   printf \"${BOLD_FONT}ERROR: Too many options!${NO_COLOR}\n\n\"; COMMANDHELP; exit 14"                                                                                                                                                                                   >> "$STARTCOMMAND";
echo "elif [[ \$# -eq 0 ]]; then"                                                                                                                                                                                                                                                >> "$STARTCOMMAND";
echo "   printf \"${BOLD_FONT}Status:${NO_COLOR} \";"                                                                                                                                                                                                                            >> "$STARTCOMMAND";
echo "   if pgrep -f '$VRSINSTALLDIRECTORY/VirtualRadar.exe' >/dev/null; then"                                                                                                                                                                                                   >> "$STARTCOMMAND";
echo "      printf \"${GREEN_COLOR}VRS is running.${NO_COLOR}\n\n\""                                                                                                                                                                                                             >> "$STARTCOMMAND";
echo "   else"                                                                                                                                                                                                                                                                   >> "$STARTCOMMAND";
echo "      printf \"${RED_COLOR}VRS is not running.${NO_COLOR}\n\n\""                                                                                                                                                                                                           >> "$STARTCOMMAND";
echo "   fi"                                                                                                                                                                                                                                                                     >> "$STARTCOMMAND";
echo "   printf \"${CYAN_COLOR}View the VRS webpage:${NO_COLOR}\n\""                                                                                                                                                                                                             >> "$STARTCOMMAND";
echo "   printf \"  ${BOLD_FONT}http://%s:%s/VirtualRadar/\n\n${NO_COLOR}\" \$LOCALIP \$VRSPORT"                                                                                                                                                                                 >> "$STARTCOMMAND";
echo "   printf \"${CYAN_COLOR}Access the optional Web Admin GUI on a local network device:${NO_COLOR}\n\""                                                                                                                                                                      >> "$STARTCOMMAND";
echo "   printf \"  ${BOLD_FONT}http://%s:%s/VirtualRadar/WebAdmin/Index.html\n\n${NO_COLOR}\" \$LOCALIP \$VRSPORT"                                                                                                                                                              >> "$STARTCOMMAND";
echo "   COMMANDHELP; exit 103"                                                                                                                                                                                                                                                  >> "$STARTCOMMAND";
echo "else printf \"Unknown error occurred! EXIT CODE: 15\n\"; exit 15"                                                                                                                                                                                                          >> "$STARTCOMMAND";
echo "fi"                                                                                                                                                                                                                                                                        >> "$STARTCOMMAND";
echo ""                                                                                                                                                                                                                                                                          >> "$STARTCOMMAND";
echo "printf \"Unknown error occurred! EXIT CODE: 99\n\"; exit 99"                                                                                                                                                                                                               >> "$STARTCOMMAND";
sudo chmod 755 "$STARTCOMMAND";        ERROREXIT 80 "The 'chmod' command failed on  $STARTCOMMAND!"
sudo chown root:root "$STARTCOMMAND";  ERROREXIT 81 "The 'chown' command failed on  $STARTCOMMAND!"


######################################################################################################
###################################   Print helpful instructions   ###################################
######################################################################################################


printf "\n\n"
printf "${GREEN_COLOR}%s${NO_COLOR}\n"  "-----------------------"
printf "${GREEN_COLOR}HELPFUL THINGS TO KNOW:${NO_COLOR}\n"
printf "${GREEN_COLOR}%s${NO_COLOR}\n\n" "-----------------------"

printf "${ORANGE_COLOR}VRS version installed:${NO_COLOR}\n"
printf "   %s\n\n" "$VRS_VERSION"

printf "${ORANGE_COLOR}VRS was installed here:${NO_COLOR}\n"
printf "   %s\n\n" "$VRSINSTALLDIRECTORY"

printf "${ORANGE_COLOR}All of VRS user custom files/directories may be found here:${NO_COLOR}\n"
printf "   %s\n"   "$SHAREDIRECTORY"
printf "   %s\n\n" "$EXTRASDIRECTORY"

if [[ $VRS_VERSION =~ "Stable" ]]; then
   printf "${ORANGE_COLOR}'libpng warning' fix applied?:${NO_COLOR}\n"
   if [[ $LIBPNG_FIX =~ [Yy] ]]; then printf "   %s\n\n" "Yes"; fi
   if [[ $LIBPNG_FIX =~ [Nn] ]]; then printf "   %s\n\n" "No"; fi
fi

if [ -f "$DATABASEBACKUPSCRIPT" ]; then
   printf "${ORANGE_COLOR}A cron job may be set to routinely backup the database file:${NO_COLOR}\n"
   printf "  Use this command to enter a cron job:   crontab -e\n"
   printf "  Here is an example cron job to backup the database at every 3:00 AM:\n"
   printf "    0 3 * * * $BASHLOCATION \"%s\"\n\n" "$DATABASEBACKUPSCRIPT"
fi

printf "${ORANGE_COLOR}A cron job may be set to check status of VRS and restart VRS if necessary:${NO_COLOR}\n"
printf "  Use this command to enter a cron job:   $CRONCMD\n"
printf "  Here is an example cron job to check the status of VRS every minute:\n"
printf "    */1 * * * * $BASHLOCATION \"%s\"\n\n" "$VRSWATCHDOGDIRECTORY/$VRSWATCHDOGFILENAME"

printf "${ORANGE_COLOR}To view the VRS map:${NO_COLOR}\n"
if [[ $DISPLAY == "" ]]; then
   printf "  View VRS on local network:  http://%s:%s/VirtualRadar\n\n" $LOCALIP $VRSPORT
else
   printf "  View VRS on this machine:   http://127.0.0.1:%s/VirtualRadar\n" $VRSPORT
   printf "  View VRS on local network:  http://%s:%s/VirtualRadar\n\n" $LOCALIP $VRSPORT
fi

printf "${ORANGE_COLOR}To access the optional Web Admin GUI on a local network device:${NO_COLOR}\n"
printf "  http://%s:%s/VirtualRadar/WebAdmin/Index.html\n\n" $LOCALIP $VRSPORT

printf "${ORANGE_COLOR}More detailed information regarding this installation script here:${NO_COLOR}\n"
printf "  https://github.com/mypiaware/virtual-radar-server-installation\n\n"

# Script ends with instructions on how to use the 'vrs' command.
printf "\n"
printf "${GREEN_COLOR}Virtual Radar Server installation is complete!${NO_COLOR}\n"
printf "\n"
printf "Press [ENTER] now to view the '${BOLD_FONT}vrs${NO_COLOR}' command options and exit..."; read -p ""
printf "\n\n"
eval "$STARTCOMMANDFILENAME" -?
printf "\n"

exit 0
